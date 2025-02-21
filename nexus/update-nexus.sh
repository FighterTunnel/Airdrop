#!/bin/bash
green="\e[32m"
red="\e[31m"
neutral="\e[0m"


if grep -q "CLI_NODE=" /root/.nexus/node-id; then
    sed -i 's/CLI_NODE=//g' /root/.nexus/node-id
else
    echo "The term 'CLI_NODE=' does not exist in the file."
fi
systemctl stop nexus-cli
cd /root/network-api
    git stash
    git fetch --tags
    git -c advice.detachedHead=false checkout "$(git rev-list --tags --max-count=1)" 

systemctl start nexus-cli

        cek_status() {
            status=$(systemctl is-active --quiet $1 && echo "aktif" || echo "nonaktif")
            if [ "$status" = "aktif" ]; then
                echo -e "${green}GOOD${neutral}"
            else
                echo -e "${red}BAD${neutral}"
            fi
        }
   
echo -e "====================="
echo -e "AIRDROP SHOGUN"
echo -e "Nexus Network CLI: $(cek_status nexus-cli.service)"
echo -e "====================="
