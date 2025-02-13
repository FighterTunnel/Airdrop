#!/bin/bash
while true; do
    read -p "Please input the content of PKey: " pem_content
    if [[ -z "$pem_content" ]]; then
        echo "Private key content cannot be empty. Please try again."
    else
        echo "$pem_content" > my.pem
        break
    fi
done
apt update -y
curl https://download.hyper.space/api/install | bash
cp /root/.aios/aios-cli /usr/bin/aios-cli

# Validate and read private key content


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
