#!/bin/bash

# Clone and build Nexus Network API
REPO_URL="https://github.com/nexus-xyz/network-api"
REPO_DIR="/root/network-api"
CLI_DIR="/root/network-api/clients/cli"
SWAP_FILE="/swapfile"
SWAP_SIZE="8G" 

# Update and install necessary packages
sudo apt update && sudo apt upgrade -y
if [ $? -ne 0 ]; then
    echo "Failed to update and upgrade system packages."
    exit 1
fi

sudo apt install -y curl git build-essential pkg-config libssl-dev unzip protobuf-compiler
if [ $? -ne 0 ]; then
    echo "Failed to install required packages."
    exit 1
fi

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
if [ $? -ne 0 ]; then
    echo "Failed to download and install Rust."
    exit 1
fi
wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip -O /tmp/protoc-21.12-linux-x86_64.zip
unzip /tmp/protoc-21.12-linux-x86_64.zip -d $HOME/.local
export PATH="$HOME/.local/bin:$PATH"

echo "Exporting PATH"
sleep 2
source $HOME/.cargo/env
echo "Checking Cargo Version"
sleep 2
cargo --version
echo "Checking Rust Version"
sleep 2
rustc --version
if [ $? -ne 0 ]; then
    echo "Cargo not found."
    exit 1
fi

# Creating swap file
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

rustup update
if [ $? -ne 0 ]; then
    echo "Failed to update Rust."
    exit 1
fi

if git clone "$REPO_URL" "$REPO_DIR"; then
    echo "Repository cloned successfully."
    if [ ! -f "/root/network-api/clients/cli/Cargo.toml" ]; then
        echo "Cargo.toml not found in the cloned repository."
        exit 1
    fi
    cd "$CLI_DIR"
    if cargo build --release; then
        echo "Nexus Network API successfully built."
    else
        echo "Failed to build Nexus Network API."
        exit 1
    fi
else
    echo "Failed to clone Nexus Network API repository."
    exit 1
fi

# Setup Rust for RISC-V target
if ! rustup target add riscv32i-unknown-none-elf; then
    echo "Failed to add Rust target for RISC-V."
    exit 1
fi
if ! rustup component add rust-src; then
    echo "Failed to add Rust source component."
    exit 1
fi

# Build and run the CLI
cd "$CLI_DIR"
cargo run -r -- start --env beta
