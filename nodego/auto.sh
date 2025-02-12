#!/bin/bash
apt install npm -y
git clone https://github.com/airdropinsiders/NodeGo-Auto-Bot.git
cd NodeGo-Auto-Bot
npm install
rm /root/NodeGo-Auto-Bot/data.txt
wget https://raw.githubusercontent.com/FighterTunnel/Airdrop/refs/heads/main/nodego/data.txt
tmux new-session -d -s "NodeGo-Auto-Bot" "npm run start"
