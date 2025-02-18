#!/bin/bash

echo -e "\e[1;34m
▓██   ██▓ ██░ ██  ▄▄▄      
 ▒██  ██▒▓██░ ██▒▒████▄    
  ▒██ ██░▒██▀▀██░▒██  ▀█▄  
  ░ ▐██▓░░▓█ ░██ ░██▄▄▄▄██ 
  ░ ██▒▓░░▓█▒░██▓ ▓█   ▓██▒
   ██▒▒▒  ▒ ░░▒░▒ ▒▒   ▓▒█░
 ▓██ ░▒░  ▒ ░▒░ ░  ▒   ▒▒ ░
 ▒ ▒ ░░   ░  ░░ ░  ░   ▒   
 ░ ░      ░  ░  ░      ░  ░
 ░ ░                       
\e[0m"
echo -e "\e[1;33m✨ AUTOMATIC CHROMIUM INSTALLER ✨\e[0m"
echo -e "\e[1;32m🚀 BY @yha_bot 🚀\e[0m"

sleep 5

# Input pengguna dengan pesan yang lebih menarik
echo -e "\e[1;33m🌟 Mari kita mulai dengan membuat akun Anda! 🌟\e[0m"
read -p "Masukkan username yang keren: " CUSTOM_USER
read -s -p "Buat password yang aman: " PASSWORD
echo -e "\n\n\e[1;32m✔️ Akun Anda berhasil dibuat!\e[0m\n"

# Fungsi untuk memeriksa root dengan pesan yang lebih baik
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "\e[1;31m❌ Ups! Skrip ini harus dijalankan sebagai root.\e[0m"
        echo -e "\e[1;33m💡 Coba jalankan dengan sudo ya!\e[0m"
        exit 1
    fi
}

# Proses instalasi Docker yang lebih informatif
install_docker() {
    echo -e "\n\e[1;34m🚀 Memulai instalasi Docker...\e[0m"
    echo -e "\e[1;36m🔄 Memperbarui sistem...\e[0m"
    sudo apt update -y && sudo apt upgrade -y || { echo -e "\e[1;31m❌ Gagal memperbarui paket\e[0m"; exit 1; }

    echo -e "\e[1;36m🧹 Membersihkan paket yang konflik...\e[0m"
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg || echo -e "\e[1;33m⚠️ $pkg tidak ditemukan, lanjut...\e[0m"
    done

    echo -e "\e[1;36m📦 Menginstal dependensi...\e[0m"
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common || { echo -e "\e[1;31m❌ Gagal menginstal dependensi\e[0m"; exit 1; }

    echo -e "\e[1;36m🔑 Menambahkan kunci GPG Docker...\e[0m"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - || { echo -e "\e[1;31m❌ Gagal menambahkan kunci GPG\e[0m"; exit 1; }

    echo -e "\e[1;36m📚 Menyiapkan repositori Docker...\e[0m"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || { echo -e "\e[1;31m❌ Gagal menambahkan repositori\e[0m"; exit 1; }

    echo -e "\e[1;36m⚙️ Menginstal Docker...\e[0m"
    sudo apt update -y && sudo apt install -y docker-ce || { echo -e "\e[1;31m❌ Gagal menginstal Docker\e[0m"; exit 1; }

    echo -e "\e[1;36m🚀 Memulai layanan Docker...\e[0m"
    sudo systemctl start docker && sudo systemctl enable docker || { echo -e "\e[1;31m❌ Gagal memulai Docker\e[0m"; exit 1; }

    echo -e "\n\e[1;32m🎉 Docker berhasil diinstal!\e[0m\n"
}

# Fungsi untuk memeriksa dan menginstal Docker Compose
install_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Menginstal Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || { echo "Gagal mengunduh Docker Compose. Keluar..."; exit 1; }
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose berhasil diinstal."
    else
        echo "Docker Compose sudah terinstal."
    fi
}


# Periksa dan instal Docker
if ! command -v docker &> /dev/null; then
    install_docker
else
    echo "Docker sudah terinstal."
fi
# Periksa apakah user root
check_root
# Periksa dan instal Docker Compose
install_docker_compose

# Dapatkan zona waktu server
TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')
if [ -z "$TIMEZONE" ]; then
    read -p "Masukkan zona waktu Anda (default: Asia/Jakarta): " user_timezone
    TIMEZONE=${user_timezone:-Asia/Jakarta}
fi


# Siapkan Chromium dengan Docker Compose
echo "Menyiapkan Chromium dengan Docker Compose..."
mkdir -p $HOME/chromium && cd $HOME/chromium

cat <<EOF > docker-compose.yaml
---
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium
    security_opt:
      - seccomp:unconfined
    environment:
      - CUSTOM_USER=$CUSTOM_USER
      - PASSWORD=$PASSWORD
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - LANG=en_US.UTF-8
      - CHROME_CLI=https://google.com/
    volumes:
      - /root/chromium/config:/config
    ports:
      - 3010:3000
      - 3011:3001
    shm_size: "1gb"
    restart: unless-stopped
EOF

# Verifikasi bahwa docker-compose.yaml telah dibuat dengan sukses
if [ ! -f "docker-compose.yaml" ]; then
    echo "Gagal membuat docker-compose.yaml. Keluar..."
    exit 1
fi

# Jalankan kontainer Chromium
echo "Menjalankan kontainer Chromium..."
docker-compose up -d || { echo "Gagal menjalankan kontainer Docker. Keluar..."; exit 1; }

# Dapatkan alamat IP VPS
IPVPS=$(curl -s ifconfig.me)

# Output informasi akses
echo -e "\n\e[1;32m🎉 Selamat! Instalasi berhasil diselesaikan! 🎉\e[0m"
echo -e "\e[1;36m🌐 Akses Chromium Anda di:\e[0m"
echo -e "\e[1;35m   http://$IPVPS:3010/\e[0m"
echo -e "\e[1;35m   https://$IPVPS:3011/\e[0m"
echo -e "\n\e[1;33m🔐 Informasi Login:\e[0m"
echo -e "\e[1;32m   Username: $CUSTOM_USER\e[0m"
echo -e "\e[1;32m   Password: $PASSWORD\e[0m"
echo -e "\e[1;32m   Zona waktu server terdeteksi: $TIMEZONE\e[0m"
echo -e "\n\e[1;31m⚠️ Jangan lupa simpan informasi login Anda! ⚠️\e[0m"
echo -e "\e[1;34m💻 Selamat menjelajah! 💻\e[0m\n"


# Bersihkan sumber daya Docker yang tidak terpakai
docker system prune -f
