#!/bin/bash

# Usage: ./log_memory_top.sh <network>

# Get the current date and time
DATE=$(date +%Y-%m-%d)
TIME=$(date -u +"%H-%M-%S")

# Get the network name (e.g., mainnet-beta) passed as an argument
NETWORK=$1

# Define the log directory and file paths
LOG_DIR="/home/sol/logs"
LOG_FILE="$LOG_DIR/$DATE-$TIME-$NETWORK-memory.log"

# Ensure the log directory exists
mkdir -p $LOG_DIR

echo "Waiting for agave-validator process to start..." >> $LOG_FILE

# Wait until the agave-validator process is running
while true; do
    PID=$(pgrep agave-validator)
    if [ -n "$PID" ]; then
        echo "Found agave-validator with PID: $PID" >> $LOG_FILE
        break
    fi
    sleep 1
done

echo "Timestamp,PID,%MEM,VIRT,RES" >> $LOG_FILE

# Log memory usage of agave-validator with UTC timestamps using top
while true; do
    # Get the UTC timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get memory usage using top
    top_output=$(top -b -n 1 -p $PID | grep $PID)
    
    # Parse the relevant fields from top output
    virt=$(echo $top_output | awk '{print $5}')  # VIRT column
    res=$(echo $top_output | awk '{print $6}')   # RES column
    mem=$(echo $top_output | awk '{print $10}')  # %MEM column

    # Log the data with timestamp
    echo "$timestamp,$PID,$mem,$virt,$res" >> $LOG_FILE
    
    # Wait for the next polling interval
    sleep 1
done
sol@ip-172-31-43-127:~/validator-scripts-repo/scripts$ cat agave-memory-tracker-simple-old.sh 
#!/bin/bash

# Usage: ./log_memory_swap.sh <network>

# Get the current date and time
DATE=$(date +%Y-%m-%d)
TIME=$(date -u +"%H-%M-%S")

# Get the network name (e.g., mainnet-beta) passed as an argument
NETWORK=$1

# Define the log directory and file paths
LOG_DIR="/home/sol/logs"
LOG_FILE="$LOG_DIR/$DATE-$TIME-$NETWORK-memory.log"

# Ensure the log directory exists
mkdir -p $LOG_DIR

echo "Waiting for agave-validator process to start..." >> $LOG_FILE

# Wait until the agave-validator process is running
while true; do
    PID=$(pgrep agave-validator)
    if [ -n "$PID" ]; then
        echo "Found agave-validator with PID: $PID" >> $LOG_FILE
        break
    fi
    sleep 1
done

# Log memory usage of agave-validator with UTC timestamps
while true; do
    # Get the UTC timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get memory and swap usage using pidstat and append the timestamp
    pidstat -r -p $PID 1 1 | tail -n +4 | while read line; do
        echo "$timestamp $line" >> $LOG_FILE
    done
    
    # Wait for the next polling interval (1 second)
    sleep 1
done