#!/bin/bash

set -e

# Update package list
apt update -y
SWAP_FILE="/swapfile"
SWAP_SIZE="30G" 

if [ ! -f "$SWAP_FILE" ]; then
    fallocate -l $SWAP_SIZE $SWAP_FILE
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    echo "$SWAP_FILE swap swap defaults 0 0" >> /etc/fstab
    echo -e "Swap RAM successfully added with size $SWAP_SIZE"
else
    echo -e "Swap file already exists, skipping swap RAM addition"
fi

# Install GaiaNet node
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash

# Wait for a few seconds to ensure installation completes
sleep 3

# Load environment variables
source /root/.bashrc

# Initialize and start GaiaNet
gaianet init
gaianet start

# Stop GaiaNet and reinitialize with custom config
gaianet stop
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen2-0.5b-instruct/config.json

# Start GaiaNet again and display info
gaianet start
gaianet info
