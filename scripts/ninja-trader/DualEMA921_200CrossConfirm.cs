#region Using declarations
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Gui;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
using NinjaTrader.NinjaScript.DrawingTools;
#endregion

//
// Dual EMA 9/21 Cross + 200 EMA Trend Filter + Close Confirmation
// ----------------------------------------------------------------
// Faithful port of the TradingView Pine v6 indicator.
//
// LOGIC:
//   1. 9/21 EMA crossover generates the raw signal.
//   2. 200 EMA acts as a directional filter:
//        - Longs only when Close > 200 EMA
//        - Shorts only when Close < 200 EMA
//   3. After a filtered cross fires, the indicator waits (the
//      "confirmation window", in minutes) for a candle to CLOSE
//      beyond the signal candle's close by N ticks. Only then does
//      the confirmed BUY / SELL entry trigger. If the window expires
//      first, the pending signal is cancelled.
//
// NOTE ON CALCULATION:
//   Default is Calculate.OnBarClose to match Pine's
//   alert.freq_once_per_bar_close behavior (no repaint). Switch to
//   OnPriceChange/OnEachTick only if you want intrabar evaluation.
//
namespace NinjaTrader.NinjaScript.Indicators
{
    public class DualEMA921CrossConfirm : Indicator
    {
        // ── EMA series ───────────────────────────────────────────
        private EMA emaFast;
        private EMA emaSlow;
        private EMA emaTrend;

        // ── Persistent state (Pine "var" equivalents) ───────────
        private bool     pendingLong;
        private bool     pendingShort;
        private double   longBreakLevel;
        private double   shortBreakLevel;
        private DateTime longSignalTime;
        private DateTime shortSignalTime;

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                Description                 = @"9/21 EMA cross filtered by 200 EMA with N-tick close confirmation within a time window.";
                Name                        = "DualEMA921CrossConfirm";
                Calculate                   = Calculate.OnBarClose;
                IsOverlay                   = true;
                DisplayInDataBox            = true;
                DrawOnPricePanel            = true;
                PaintPriceMarkers           = true;
                IsSuspendedWhileInactive    = true;

                // Inputs: EMA lengths
                EmaFastLength               = 9;
                EmaSlowLength               = 21;
                EmaTrendLength              = 200;

                // Inputs: confirmation
                TickOffset                  = 2;
                ConfirmWindowMins           = 5;
                ShowCloud                   = true;

                // Inputs: colors
                BullishColor                = Brushes.LimeGreen;
                BearishColor                = Brushes.Red;
                TrendEmaColor               = Brushes.Orange;
                EntryColor                  = Brushes.Aqua;

                // Plots — index order matters (Values[0..4])
                AddPlot(new Stroke(Brushes.LimeGreen, 2), PlotStyle.Line, "FastEMA");   // 0
                AddPlot(new Stroke(Brushes.LimeGreen, 2), PlotStyle.Line, "SlowEMA");   // 1
                AddPlot(new Stroke(Brushes.Orange,    3), PlotStyle.Line, "TrendEMA");  // 2
                AddPlot(new Stroke(Brushes.LimeGreen, 1), PlotStyle.Square, "LongConfirmLevel");  // 3
                AddPlot(new Stroke(Brushes.Red,       1), PlotStyle.Square, "ShortConfirmLevel"); // 4
            }
            else if (State == State.Configure)
            {
                // Ensure enough bars for the trend EMA before plotting signals
                BarsRequiredToPlot = Math.Max(BarsRequiredToPlot, EmaTrendLength);
            }
            else if (State == State.DataLoaded)
            {
                emaFast  = EMA(Close, EmaFastLength);
                emaSlow  = EMA(Close, EmaSlowLength);
                emaTrend = EMA(Close, EmaTrendLength);

                pendingLong     = false;
                pendingShort    = false;
                longBreakLevel  = double.NaN;
                shortBreakLevel = double.NaN;
            }
        }

        protected override void OnBarUpdate()
        {
            // Need at least one prior bar for CrossAbove/CrossBelow,
            // and enough history for the trend EMA to be meaningful.
            if (CurrentBar < 1 || CurrentBar < EmaTrendLength)
                return;

            double fast  = emaFast[0];
            double slow  = emaSlow[0];
            double trend = emaTrend[0];

            // ── Plot EMA values ─────────────────────────────────
            Values[0][0] = fast;
            Values[1][0] = slow;
            Values[2][0] = trend;

            // ── Trend coloring (fast/slow follow 9>21 like Pine) ─
            bool isBullish = fast > slow;
            Brush emaBrush = isBullish ? BullishColor : BearishColor;
            PlotBrushes[0][0] = emaBrush;
            PlotBrushes[1][0] = emaBrush;
            PlotBrushes[2][0] = TrendEmaColor;

            // ── 200 EMA filter ──────────────────────────────────
            bool aboveTrend = Close[0] > trend;
            bool belowTrend = Close[0] < trend;

            // ── Raw crossover, then filter ──────────────────────
            bool bullCrossRaw = CrossAbove(emaFast, emaSlow, 1);
            bool bearCrossRaw = CrossBelow(emaFast, emaSlow, 1);

            bool bullishCross = bullCrossRaw && aboveTrend;
            bool bearishCross = bearCrossRaw && belowTrend;

            // ── Arm pending signal on a filtered cross ──────────
            if (bullishCross)
            {
                pendingLong    = true;
                longBreakLevel = Close[0] + TickOffset * TickSize;
                longSignalTime = Time[0];
                pendingShort   = false;   // cancel opposite
            }

            if (bearishCross)
            {
                pendingShort    = true;
                shortBreakLevel = Close[0] - TickOffset * TickSize;
                shortSignalTime = Time[0];
                pendingLong     = false;  // cancel opposite
            }

            // ── Confirmation / expiry checks ────────────────────
            bool longConfirmed  = false;
            bool shortConfirmed = false;

            if (pendingLong)
            {
                double minsElapsed = (Time[0] - longSignalTime).TotalMinutes;
                if (Close[0] >= longBreakLevel && minsElapsed <= ConfirmWindowMins)
                {
                    longConfirmed = true;
                    pendingLong   = false;
                }
                else if (minsElapsed > ConfirmWindowMins)
                {
                    pendingLong = false;   // expired — no entry
                }
            }

            if (pendingShort)
            {
                double minsElapsed = (Time[0] - shortSignalTime).TotalMinutes;
                if (Close[0] <= shortBreakLevel && minsElapsed <= ConfirmWindowMins)
                {
                    shortConfirmed = true;
                    pendingShort   = false;
                }
                else if (minsElapsed > ConfirmWindowMins)
                {
                    pendingShort = false;  // expired — no entry
                }
            }

            // ── Pending confirmation level lines (with gaps) ────
            if (pendingLong)
            {
                Values[3][0] = longBreakLevel;
                PlotBrushes[3][0] = BullishColor;
            }
            else
                Values[3].Reset();

            if (pendingShort)
            {
                Values[4][0] = shortBreakLevel;
                PlotBrushes[4][0] = BearishColor;
            }
            else
                Values[4].Reset();

            // ── EMA cloud fill (per-bar segment, trend colored) ─
            if (ShowCloud && CurrentBar > 0)
            {
                Brush cloud = isBullish ? BullishColor : BearishColor;
                Draw.Region(this, "emaCloud" + CurrentBar, 1, 0,
                            emaFast, emaSlow, Brushes.Transparent, cloud, 12);
            }

            // ── Pending cross markers (triangles) ───────────────
            if (bullishCross)
                Draw.TriangleUp(this, "bullCross" + CurrentBar, false,
                                0, Low[0] - 2 * TickSize, BullishColor);

            if (bearishCross)
                Draw.TriangleDown(this, "bearCross" + CurrentBar, false,
                                  0, High[0] + 2 * TickSize, BearishColor);

            // ── Confirmed entry markers + alerts ────────────────
            if (longConfirmed)
            {
                Draw.ArrowUp(this, "buyArrow" + CurrentBar, false,
                             0, Low[0] - 4 * TickSize, EntryColor);
                Draw.Text(this, "buyTxt" + CurrentBar, "BUY",
                          0, Low[0] - 9 * TickSize, EntryColor);

                if (State == State.Realtime)
                    Alert("BuyConfirm" + CurrentBar, Priority.High,
                          "BUY CONFIRMED: candle closed above signal close on " + Instrument.MasterInstrument.Name,
                          "Alert1.wav", 10, Brushes.DimGray, Brushes.White);
            }

            if (shortConfirmed)
            {
                Draw.ArrowDown(this, "sellArrow" + CurrentBar, false,
                               0, High[0] + 4 * TickSize, EntryColor);
                Draw.Text(this, "sellTxt" + CurrentBar, "SELL",
                          0, High[0] + 9 * TickSize, EntryColor);

                if (State == State.Realtime)
                    Alert("SellConfirm" + CurrentBar, Priority.High,
                          "SELL CONFIRMED: candle closed below signal close on " + Instrument.MasterInstrument.Name,
                          "Alert1.wav", 10, Brushes.DimGray, Brushes.White);
            }

            // ── Optional pending alerts (lower priority) ────────
            if (State == State.Realtime)
            {
                if (bullishCross)
                    Alert("PendLong" + CurrentBar, Priority.Low,
                          "PENDING LONG: 9/21 cross above 200 EMA — awaiting close confirm on " + Instrument.MasterInstrument.Name,
                          "", 10, Brushes.Transparent, Brushes.Goldenrod);

                if (bearishCross)
                    Alert("PendShort" + CurrentBar, Priority.Low,
                          "PENDING SHORT: 9/21 cross below 200 EMA — awaiting close confirm on " + Instrument.MasterInstrument.Name,
                          "", 10, Brushes.Transparent, Brushes.Goldenrod);
            }
        }

        #region Properties

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

        [NinjaScriptProperty]
        [Range(1, int.MaxValue)]
        [Display(Name = "Ticks Beyond Close for Confirm", Order = 1, GroupName = "Close Confirmation")]
        public int TickOffset { get; set; }

        [NinjaScriptProperty]
        [Range(1, int.MaxValue)]
        [Display(Name = "Confirmation Window (minutes)", Order = 2, GroupName = "Close Confirmation")]
        public int ConfirmWindowMins { get; set; }

        [NinjaScriptProperty]
        [Display(Name = "Show EMA Cloud", Order = 3, GroupName = "Close Confirmation")]
        public bool ShowCloud { get; set; }

        [XmlIgnore]
        [Display(Name = "Bullish Color", Order = 1, GroupName = "Colors")]
        public Brush BullishColor { get; set; }
        [Browsable(false)]
        public string BullishColorSerialize
        {
            get { return Serialize.BrushToString(BullishColor); }
            set { BullishColor = Serialize.StringToBrush(value); }
        }

        [XmlIgnore]
        [Display(Name = "Bearish Color", Order = 2, GroupName = "Colors")]
        public Brush BearishColor { get; set; }
        [Browsable(false)]
        public string BearishColorSerialize
        {
            get { return Serialize.BrushToString(BearishColor); }
            set { BearishColor = Serialize.StringToBrush(value); }
        }

        [XmlIgnore]
        [Display(Name = "200 EMA Color", Order = 3, GroupName = "Colors")]
        public Brush TrendEmaColor { get; set; }
        [Browsable(false)]
        public string TrendEmaColorSerialize
        {
            get { return Serialize.BrushToString(TrendEmaColor); }
            set { TrendEmaColor = Serialize.StringToBrush(value); }
        }

        [XmlIgnore]
        [Display(Name = "Confirmed Entry Color", Order = 4, GroupName = "Colors")]
        public Brush EntryColor { get; set; }
        [Browsable(false)]
        public string EntryColorSerialize
        {
            get { return Serialize.BrushToString(EntryColor); }
            set { EntryColor = Serialize.StringToBrush(value); }
        }

        // Convenience accessors for the plot series
        [Browsable(false)]
        [XmlIgnore]
        public Series<double> FastEMA { get { return Values[0]; } }

        [Browsable(false)]
        [XmlIgnore]
        public Series<double> SlowEMA { get { return Values[1]; } }

        [Browsable(false)]
        [XmlIgnore]
        public Series<double> TrendEMA { get { return Values[2]; } }

        #endregion
    }
}
