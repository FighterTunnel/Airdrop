#!/bin/sh
NEXUS_HOME=$HOME/.nexus
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
NC='\033[0m' # No Color
swap_file="/swapfile"
swap_size="8G" 

sudo apt update && sudo apt upgrade -y
sudo apt install build-essential pkg-config libssl-dev git-all protobuf-compiler -y
rustc --version || curl https://sh.rustup.rs -sSf | sh

[ -d $NEXUS_HOME ] || mkdir -p $NEXUS_HOME

if [ -z "$NONINTERACTIVE" ] && [ "${#NODE_ID}" -ne "28" ]; then
    echo "\n${ORANGE}The Nexus network is currently in Testnet II. You can now earn Nexus Points.${NC}\n\n"
fi

while [ -z "$NONINTERACTIVE" ] && [ ! -f "$NEXUS_HOME/node-id" ]; do
    read -p "Do you agree to the Nexus Beta Terms of Use (https://nexus.xyz/terms-of-use)? (Y/n) " yn </dev/tty
    echo ""
    
    case $yn in
        [Nn]* ) 
            echo ""
            exit;;
        [Yy]* ) 
            echo ""
            break;;
        "" ) 
            echo ""
            break;;
        * ) 
            echo "Please answer yes or no."
            echo "";;
    esac
done


if [ ! -f "$swap_file" ]; then
    fallocate -l $swap_size $swap_file
    chmod 600 $swap_file
    mkswap $swap_file
    swapon $swap_file
    echo "$swap_file swap swap defaults 0 0" >> /etc/fstab
    echo -e "Swap RAM successfully added with size $swap_size"
else
    echo -e "Swap file already exists, skipping swap RAM addition"
fi
git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ $GIT_IS_AVAILABLE != 0 ]; then
  echo Unable to find git. Please install it and try again.
  exit 1;
fi

# Check if protoc is installed
protoc --version >/dev/null 2>&1
PROTOC_IS_AVAILABLE=$?
if [ $PROTOC_IS_AVAILABLE != 0 ]; then
  echo "protoc is not installed or not in PATH. Please install it and try again."
  exit 1;
fi

REPO_PATH=$NEXUS_HOME/network-api
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating.";
  (cd $REPO_PATH && git stash && git fetch --tags)
else
  (cd $NEXUS_HOME && git clone https://github.com/nexus-xyz/network-api)
fi
(cd $REPO_PATH && git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1))

(cd $REPO_PATH/clients/cli && cargo run --release -- --start --beta)

echo "Nexus Network API has been installed and started successfully."
