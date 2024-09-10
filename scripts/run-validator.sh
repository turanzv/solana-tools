#!/bin/bash

# Usage: ./run_validator.sh <network> [--clear-ledger]
# Example: ./run_validator.sh mainnet-beta --clear-ledger

# Check if network argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <network> [--clear-ledger]"
    echo "Example: $0 mainnet-beta --clear-ledger"
    exit 1
fi

NETWORK=$1
CLEAR_LEDGER=false

if [ "$2" == "--clear-ledger" ]; then
    CLEAR_LEDGER=true
fi

# Define parameters based on the network
case $NETWORK in
    mainnet-beta)
        SOLANA_URL="https://api.mainnet-beta.solana.com"
        METRICS_CONFIG="host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password"
        GENESIS_HASH="5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d"
        KNOWN_VALIDATORS=(
            "7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2"
            "GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ"
            "DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ"
            "CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S"
        )
        ENTRYPOINTS=(
            "entrypoint.mainnet-beta.solana.com:8001"
            "entrypoint2.mainnet-beta.solana.com:8001"
            "entrypoint3.mainnet-beta.solana.com:8001"
            "entrypoint4.mainnet-beta.solana.com:8001"
            "entrypoint5.mainnet-beta.solana.com:8001"
        )
        ;;
    testnet)
        SOLANA_URL="https://api.testnet.solana.com"
        METRICS_CONFIG="host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"
        GENESIS_HASH="4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY"
        KNOWN_VALIDATORS=(
            "5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on"
            "7XSY3MrYnK8vq693Rju17bbPkCN3Z7KvvfvJx4kdrsSY"
            "Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN"
            "9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv"
        )
        ENTRYPOINTS=(
            "entrypoint.testnet.solana.com:8001"
            "entrypoint2.testnet.solana.com:8001"
            "entrypoint3.testnet.solana.com:8001"
        )
        ;;
    devnet)
        SOLANA_URL="https://api.devnet.solana.com"
        METRICS_CONFIG="host=https://metrics.solana.com:8086,db=devnet,u=scratch_writer,p=topsecret"
        GENESIS_HASH="EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG"
        KNOWN_VALIDATORS=(
            "dv1ZAGvdsz5hHLwWXsVnM94hWf1pjbKVau1QVkaMJ92"
            "dv2eQHeP4RFrJZ6UeiZWoc3XTtmtZCUKxxCApCDcRNV"
            "dv4ACNkpYPcE3aKmYDqZm9G5EB3J4MRoeE7WNDRBVJB"
            "dv3qDFk1DTF36Z62bNvrCXe9sKATA6xvVy6A798xxAS"
        )
        ENTRYPOINTS=(
            "entrypoint.devnet.solana.com:8001"
            "entrypoint2.devnet.solana.com:8001"
            "entrypoint3.devnet.solana.com:8001"
            "entrypoint4.devnet.solana.com:8001"
            "entrypoint5.devnet.solana.com:8001"
        )
        ;;
    *)
        echo "Unknown network: $NETWORK"
        exit 1
        ;;
esac

# Switch the Solana client cluster
/home/sol/agave/bin/solana config set --url $SOLANA_URL

# Export metrics configuration
export SOLANA_METRICS_CONFIG="$METRICS_CONFIG"

# Optionally clear the ledger
if [ "$CLEAR_LEDGER" = true ]; then
    echo "Clearing the ledger at /mnt/ledger..."
    rm -rf /mnt/ledger/*
    NO_SNAPSHOT_FLAG=""
else
    NO_SNAPSHOT_FLAG="--no-snapshot-fetch"
fi

# Build the known validators argument
KNOWN_VALIDATORS_ARGS=""
for validator in "${KNOWN_VALIDATORS[@]}"; do
    KNOWN_VALIDATORS_ARGS+="--known-validator $validator "
done

# Build the entrypoints argument
ENTRYPOINT_ARGS=""
for entrypoint in "${ENTRYPOINTS[@]}"; do
    ENTRYPOINT_ARGS+="--entrypoint $entrypoint "
done

# Get the current date and time
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H-%M-%S)

# Define the log directory base path
LOG_DIR="/home/sol/logs"
LOG_FILE="$LOG_DIR/$DATE-$TIME-$NETWORK.log"

# Create the directory structure
mkdir -p $LOG_DIR

# Execute the validator with the dynamic configuration
exec /home/sol/agave/bin/agave-validator \
    --identity /home/sol/validator-keypair.json \
    --vote-account /home/sol/vote-account-keypair.json \
    $KNOWN_VALIDATORS_ARGS \
    $ENTRYPOINT_ARGS \
    --only-known-rpc \
    --log $LOG_FILE \
    --ledger /mnt/ledger \
    --rpc-port 8899 \
    --dynamic-port-range 8000-8020 \
    --expected-genesis-hash $GENESIS_HASH \
    --wal-recovery-mode skip_any_corrupted_record \
    --limit-ledger-size \
    --private-rpc \
    --full-rpc-api \
    --no-voting \
    $NO_SNAPSHOT_FLAG
