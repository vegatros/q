#!/bin/bash

while true; do
    clear
    echo "=== CloudTrail Logs (Last 5 Minutes) ==="
    echo "Updated: $(date)"
    echo ""
    
    # Get CloudTrail events from last 5 minutes
    END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%S")
    START_TIME=$(date -u -d '5 minutes ago' +"%Y-%m-%dT%H:%M:%S")
    
    aws cloudtrail lookup-events \
        --region us-east-1 \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --max-results 20 \
        --query 'Events[*].[EventTime,EventName,EventSource,Username]' \
        --output table
    
    echo ""
    echo "Refreshing in 60 seconds... (Press Ctrl+C to stop)"
    sleep 60
done
