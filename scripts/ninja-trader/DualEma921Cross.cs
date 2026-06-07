#region Using declarations
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
using NinjaTrader.NinjaScript.DrawingTools;
#endregion

// ============================================================================
// Dual EMA 9/21 Cross + 200 EMA Trend Filter + Close Confirmation
// NinjaTrader 8 port of the TradingView Pine v6 indicator.
//
// AUTOMATION (TradeSaber Predator X):
//   Predator reads ENTRY signals from NinjaTrader Draw Objects whose tag is
//   "TAG" + CurrentBar (bar number at the END). The confirmed entries below
//   use:   Draw.ArrowUp  tag = "BuyArrow"  + CurrentBar
//          Draw.ArrowDown tag = "SellArrow" + CurrentBar
//   Point Predator's Custom Signal at the "BuyArrow" / "SellArrow" tags.
//
//   The BuySignal / SellSignal PLOTS (transparent) are provided only for
//   Predator filters/stops, Strategy Builder, and Data Box verification.
//   They are NOT the entry trigger for Predator.
//
// Logic preserved 1:1 from the Pine script:
//   - Fast/Slow/Trend EMAs (9 / 21 / 200)
//   - Longs only when a 9/21 cross-up occurs ABOVE the 200 EMA
//   - Shorts only when a 9/21 cross-down occurs BELOW the 200 EMA
//   - After a filtered cross, the entry stays "pending" until price closes
//     beyond the signal candle's close by N ticks within a time window.
//     Only then does the confirmed BUY/SELL fire. Opposite signals cancel.
// ============================================================================

namespace NinjaTrader.NinjaScript.Indicators
{
	public class DualEma921Cross : Indicator
	{
		// ── Indicator references ─────────────────────────────────────────
		private EMA emaFast;
		private EMA emaSlow;
		private EMA emaTrend;

		// ── Persistent state for pending signals (mirrors Pine `var`) ─────
		private bool     pendingLong;
		private bool     pendingShort;
		private double   longBreakLevel  = double.NaN;
		private double   shortBreakLevel = double.NaN;
		private DateTime longSignalTime;
		private DateTime shortSignalTime;

		protected override void OnStateChange()
		{
			if (State == State.SetDefaults)
			{
				Description					= "9/21 EMA cross filtered by the 200 EMA with an N-tick close-confirmation gate. Confirmed entries are drawn as Predator X-compatible arrow signals.";
				Name						= "DualEma921Cross";
				Calculate					= Calculate.OnBarClose;   // non-repainting; signal locks at bar close
				IsOverlay					= true;
				DisplayInDataBox			= true;
				DrawOnPricePanel			= true;
				PaintPriceMarkers			= true;
				IsSuspendedWhileInactive	= true;

				// ── Inputs: EMA lengths ──
				EmaFastLength				= 9;
				EmaSlowLength				= 21;
				EmaTrendLength				= 200;

				// ── Inputs: breakout confirmation ──
				TickOffset					= 2;   // ticks beyond signal close required to confirm
				ConfirmWindowMins			= 5;   // confirmation window in minutes

				// ── Inputs: automation / display ──
				ShowPendingMarkers			= true; // hide for a clean automation chart

				// ── Inputs: colors ──
				BullishColor				= Brushes.Green;
				BearishColor				= Brushes.Red;
				TrendEmaColor				= Brushes.Orange;
				EntryColor					= Brushes.Aqua;

				// Plot 0 = Fast EMA, 1 = Slow EMA, 2 = Trend EMA
				AddPlot(new Stroke(Brushes.Green,  2), PlotStyle.Line, "FastEMA");
				AddPlot(new Stroke(Brushes.Green,  2), PlotStyle.Line, "SlowEMA");
				AddPlot(new Stroke(Brushes.Orange, 3), PlotStyle.Line, "TrendEMA");

				// Plot 3 = BuySignal, 4 = SellSignal (transparent: for filters/Strategy Builder/Data Box)
				AddPlot(new Stroke(Brushes.Transparent, 1), PlotStyle.Dot, "BuySignal");
				AddPlot(new Stroke(Brushes.Transparent, 1), PlotStyle.Dot, "SellSignal");
			}
			else if (State == State.Configure)
			{
				BarsRequiredToPlot = 1; // need the prior bar for crossover detection
			}
			else if (State == State.DataLoaded)
			{
				emaFast  = EMA(Close, EmaFastLength);
				emaSlow  = EMA(Close, EmaSlowLength);
				emaTrend = EMA(Close, EmaTrendLength);

				Plots[2].Brush = TrendEmaColor; // apply user trend color to 200 EMA

				pendingLong  = false;
				pendingShort = false;
			}
		}

		protected override void OnBarUpdate()
		{
			if (CurrentBar < 1)
				return;

			// ── EMA values / plots ───────────────────────────────────────
			Values[0][0] = emaFast[0];
			Values[1][0] = emaSlow[0];
			Values[2][0] = emaTrend[0];

			// Color fast/slow EMAs by short-term trend (isBullish)
			bool isBullish = emaFast[0] > emaSlow[0];
			PlotBrushes[0][0] = isBullish ? BullishColor : BearishColor;
			PlotBrushes[1][0] = isBullish ? BullishColor : BearishColor;

			// ── 200 EMA trend filter ─────────────────────────────────────
			bool aboveTrendEma = Close[0] > emaTrend[0];
			bool belowTrendEma = Close[0] < emaTrend[0];

			// ── Crossover signals (filtered by 200 EMA) ──────────────────
			bool bullishCross = CrossAbove(emaFast, emaSlow, 1) && aboveTrendEma;
			bool bearishCross = CrossBelow(emaFast, emaSlow, 1) && belowTrendEma;

			TimeSpan confirmWindow = TimeSpan.FromMinutes(ConfirmWindowMins);

			// ── Set pending state on a new filtered crossover ────────────
			if (bullishCross)
			{
				pendingLong    = true;
				longBreakLevel = Close[0] + TickOffset * TickSize;
				longSignalTime = Time[0];
				pendingShort   = false;   // cancel opposite pending
			}

			if (bearishCross)
			{
				pendingShort    = true;
				shortBreakLevel = Close[0] - TickOffset * TickSize;
				shortSignalTime = Time[0];
				pendingLong     = false;  // cancel opposite pending
			}

			// ── Check for confirmation or expiry ─────────────────────────
			bool longConfirmed  = false;
			bool shortConfirmed = false;

			if (pendingLong)
			{
				if (Close[0] >= longBreakLevel && (Time[0] - longSignalTime) <= confirmWindow)
				{
					longConfirmed = true;
					pendingLong   = false;
				}
				else if ((Time[0] - longSignalTime) > confirmWindow)
				{
					pendingLong = false;   // expired — no entry
				}
			}

			if (pendingShort)
			{
				if (Close[0] <= shortBreakLevel && (Time[0] - shortSignalTime) <= confirmWindow)
				{
					shortConfirmed = true;
					pendingShort   = false;
				}
				else if ((Time[0] - shortSignalTime) > confirmWindow)
				{
					pendingShort = false;  // expired — no entry
				}
			}

			// ── Signal plots (for Predator filters/stops, Strategy Builder, Data Box) ──
			Values[3][0] = longConfirmed  ? 1 : 0;   // BuySignal
			Values[4][0] = shortConfirmed ? 1 : 0;   // SellSignal

			// ── Drawing offsets ──────────────────────────────────────────
			double off = 4 * TickSize;

			// ── Pending markers (optional; not used by automation) ───────
			if (ShowPendingMarkers)
			{
				if (bullishCross)
					Draw.TriangleUp(this, "bullCross" + CurrentBar, false, 0, Low[0] - off, BullishColor);

				if (bearishCross)
					Draw.TriangleDown(this, "bearCross" + CurrentBar, false, 0, High[0] + off, BearishColor);

				if (pendingLong)
					Draw.Dot(this, "longLvl" + CurrentBar, false, 0, longBreakLevel, BullishColor);

				if (pendingShort)
					Draw.Dot(this, "shortLvl" + CurrentBar, false, 0, shortBreakLevel, BearishColor);
			}

			// ── CONFIRMED ENTRY SIGNALS (Predator X reads these) ─────────
			//     Tag format = "TAG" + CurrentBar  →  required by Predator.
			if (longConfirmed)
			{
				Draw.ArrowUp(this, "BuyArrow" + CurrentBar, false, 0, Low[0] - off, EntryColor);
				Draw.Text(this, "BuyText" + CurrentBar, "BUY", 0, Low[0] - (off * 2.5), EntryColor);
			}

			if (shortConfirmed)
			{
				Draw.ArrowDown(this, "SellArrow" + CurrentBar, false, 0, High[0] + off, EntryColor);
				Draw.Text(this, "SellText" + CurrentBar, "SELL", 0, High[0] + (off * 2.5), EntryColor);
			}

			// ── Alerts (real-time only) ──────────────────────────────────
			if (State == State.Realtime)
			{
				if (longConfirmed)
					Alert("buyConfirmed", Priority.High, "BUY CONFIRMED on " + Instrument.FullName, "", 10, Brushes.DarkGreen, Brushes.White);
				else if (shortConfirmed)
					Alert("sellConfirmed", Priority.High, "SELL CONFIRMED on " + Instrument.FullName, "", 10, Brushes.DarkRed, Brushes.White);
				else if (bullishCross)
					Alert("pendingLong", Priority.Medium, "PENDING LONG — awaiting close confirmation on " + Instrument.FullName, "", 10, Brushes.Goldenrod, Brushes.Black);
				else if (bearishCross)
					Alert("pendingShort", Priority.Medium, "PENDING SHORT — awaiting close confirmation on " + Instrument.FullName, "", 10, Brushes.Goldenrod, Brushes.Black);
			}
		}

		#region Properties

		// ── EMA Lengths ──────────────────────────────────────────────────
		[NinjaScriptProperty]
		[Range(1, int.MaxValue)]
		[Display(Name = "Fast EMA Length", Order = 1, GroupName = "EMA Lengths")]
		public int EmaFastLength { get; set; }

		[NinjaScriptProperty]
		[Range(1, int.MaxValue)]
		[Display(Name = "Slow EMA Length", Order = 2, GroupName = "EMA Lengths")]
		public int EmaSlowLength { get; set; }

		[NinjaScriptProperty]
		[Range(1, int.MaxValue)]
		[Display(Name = "Trend EMA Length", Order = 3, GroupName = "EMA Lengths")]
		public int EmaTrendLength { get; set; }

		// ── Close Confirmation ───────────────────────────────────────────
		[NinjaScriptProperty]
		[Range(1, int.MaxValue)]
		[Display(Name = "Ticks Beyond Close for Confirm", Order = 1, GroupName = "Close Confirmation")]
		public int TickOffset { get; set; }

		[NinjaScriptProperty]
		[Range(1, int.MaxValue)]
		[Display(Name = "Confirmation Window (minutes)", Order = 2, GroupName = "Close Confirmation")]
		public int ConfirmWindowMins { get; set; }

		// ── Automation / Display ─────────────────────────────────────────
		[NinjaScriptProperty]
		[Display(Name = "Show Pending Markers", Order = 1, GroupName = "Automation / Display")]
		public bool ShowPendingMarkers { get; set; }

		// ── Signal plot accessors (read by Predator filters / Strategy Builder) ──
		[Browsable(false)]
		[XmlIgnore]
		public Series<double> BuySignal  { get { return Values[3]; } }

		[Browsable(false)]
		[XmlIgnore]
		public Series<double> SellSignal { get { return Values[4]; } }

		// ── Colors ───────────────────────────────────────────────────────
		[XmlIgnore]
		[Display(Name = "Bullish Color", Order = 1, GroupName = "Colors")]
		public Brush BullishColor { get; set; }
		[Browsable(false)]
		public string BullishColorSerializable
		{
			get { return Serialize.BrushToString(BullishColor); }
			set { BullishColor = Serialize.StringToBrush(value); }
		}

		[XmlIgnore]
		[Display(Name = "Bearish Color", Order = 2, GroupName = "Colors")]
		public Brush BearishColor { get; set; }
		[Browsable(false)]
		public string BearishColorSerializable
		{
			get { return Serialize.BrushToString(BearishColor); }
			set { BearishColor = Serialize.StringToBrush(value); }
		}

		[XmlIgnore]
		[Display(Name = "200 EMA Color", Order = 3, GroupName = "Colors")]
		public Brush TrendEmaColor { get; set; }
		[Browsable(false)]
		public string TrendEmaColorSerializable
		{
			get { return Serialize.BrushToString(TrendEmaColor); }
			set { TrendEmaColor = Serialize.StringToBrush(value); }
		}

		[XmlIgnore]
		[Display(Name = "Confirmed Entry Color", Order = 4, GroupName = "Colors")]
		public Brush EntryColor { get; set; }
		[Browsable(false)]
		public string EntryColorSerializable
		{
			get { return Serialize.BrushToString(EntryColor); }
			set { EntryColor = Serialize.StringToBrush(value); }
		}

		#endregion
	}
}
