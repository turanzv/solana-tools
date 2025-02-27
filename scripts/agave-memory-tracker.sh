#!/bin/bash

# Usage: ./agave-memory-tracker.sh <network>

# Get the current date and time
DATE=$(date +%Y-%m-%d)
TIME=$(date -u +"%H-%M-%S")

# Get the network name (e.g., mainnet-beta) passed as an argument
NETWORK=$1

# Define the log directory and file paths
LOG_DIR="/home/sol/logs"
LOG_FILE="$LOG_DIR/$DATE-$TIME-$NETWORK-memory.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

echo "Waiting for agave-validator process to start..." >> "$LOG_FILE"

# Wait until the agave-validator process is running
while true; do
    PID=$(pgrep agave-validator)
    if [ -n "$PID" ]; then
        echo "Found agave-validator with PID: $PID" >> "$LOG_FILE"
        break
    fi
    sleep 1
done

# Write CSV headers
echo "Timestamp,UID,PID,minflt/s,majflt/s,VSZ,RSS,%MEM,Command" >> "$LOG_FILE"

# Log memory usage of agave-validator with UTC timestamps
while true; do
    # Get the UTC timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get memory usage using pidstat
    pidstat_output=$(pidstat -r -p "$PID" 1 1 | tail -n 1)

    # Parse the relevant fields from pidstat output
    uid=$(echo "$pidstat_output" | awk '{print $2}')
    pid=$(echo "$pidstat_output" | awk '{print $3}')
    minflt=$(echo "$pidstat_output" | awk '{print $4}')
    majflt=$(echo "$pidstat_output" | awk '{print $5}')
    vsz=$(echo "$pidstat_output" | awk '{print $6}')
    rss=$(echo "$pidstat_output" | awk '{print $7}')
    mem=$(echo "$pidstat_output" | awk '{print $8}')
    command=$(echo "$pidstat_output" | awk '{print $9}')

    # Log the data
    echo "$timestamp,$uid,$pid,$minflt,$majflt,$vsz,$rss,$mem,$command" >> "$LOG_FILE"

    # Wait for the next polling interval
    sleep 1
done
