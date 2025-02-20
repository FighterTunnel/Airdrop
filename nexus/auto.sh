#!/bin/bash

# Update and install necessary packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential pkg-config libssl-dev unzip

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
export PATH="$HOME/.cargo/bin:$PATH"
rustc --version
cargo --version
rustup update

# Clone and build Nexus Network API
git clone https://github.com/nexus-network/nexus-network-api
cd nexus-network-api
cargo build --release

# Install Protocol Buffers
wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip
unzip protoc-21.12-linux-x86_64.zip -d $HOME/.local
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
cargo install protobuf-codegen

# Setup Rust for RISC-V target
rustup target add riscv32i-unknown-none-elf
rustup component add rust-src

# Clone and setup Nexus Network API in .nexus directory
mkdir -p $HOME/.nexus
cd $HOME/.nexus
git clone https://github.com/nexus-xyz/network-api
cd network-api
git fetch --tags
git checkout $(git rev-list --tags --max-count=1)

# Build and run the CLI
cd clients/cli
cargo clean
cargo build --release
cargo run --release -- --start --beta
