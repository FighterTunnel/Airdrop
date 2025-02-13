#!/bin/bash
apt update -y
curl https://download.hyper.space/api/install | bash
cp /root/.aios/aios-cli /usr/bin/aios-cli

wget https://raw.githubusercontent.com/FighterTunnel/Airdrop/refs/heads/main/hyperspace/my.pem
chmod 600 my.pem
tmux new-session -d -s "hyperspace" "aios-cli start"
sleep 10

aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf
aios-cli hive import-keys ./my.pem
aios-cli hive login
aios-cli hive select-tier 5
aios-cli infer --model hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf --prompt "Can you explain the concept of hyperspace and its applications in science fiction?"
aios-cli hive infer --model hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf --prompt "Hello, airdropnode! Can you explain hyperspace and its connection to modern science?"
aios-cli hive login
aios-cli hive connect
