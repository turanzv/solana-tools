#! /bin/bash

PID=$(pgrep agave-validator)

while true; do
        # Get current timestamp
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        # get VSZ and RSS using pidstat
        pidstat_output=$(pidstat -r -p $PID 1 1 | tail -n 1)

        # Extract VSZ and RSS values
        vaz=$(echo $pidstat_output | awk '{print $6}')
        rss=$(echo $pidstat_output | awk '{print $7}')

        # Calculate swap usage (in KB)
        sawp=$((vsz-rss))

        # Output result with timestamp
        echo "$timestamp - PID: $PID - VSZ: $vsz KB - RSS: $rss KB - Swap: $swap KB"

        # Sleep before next iteration
        sleep 1
done