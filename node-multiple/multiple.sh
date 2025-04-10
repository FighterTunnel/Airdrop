#!/bin/bash

# Mengecek apakah curl dan wget sudah terinstal
command -v curl >/dev/null 2>&1 || { echo "curl tidak ditemukan, menginstal curl..."; apt-get install -y curl; }
command -v wget >/dev/null 2>&1 || { echo "wget tidak ditemukan, menginstal wget..."; apt-get install -y wget; }

echo "MULTIPLE NODE"
sleep 2

# Fungsi untuk mendownload file jika belum ada
download_file() {
    local url=$1
    local file_name=$2
    
    if [ -f "$file_name" ]; then
        echo "File sudah ada, menghapus dan mendownload ulang..."
        rm -f "$file_name"
    fi

    echo "Mendownload file $file_name..."
    wget -q "$url" -O "$file_name"
}

# Fungsi untuk mengekstrak file tar
extract_tar() {
    local file_name=$1
    echo "Mengekstrak file $file_name..."
    tar -xvf "$file_name"
}

# Memeriksa arsitektur sistem
ARCHITECTURE=$(uname -m)

# Mengatur URL sesuai arsitektur
if [ "$ARCHITECTURE" == "x86_64" ]; then
    CLIENT_URL="https://mdeck-download.s3.us-east-1.amazonaws.com/client/linux/MultipleForLinux.tar"
    CLIENT_FILE="MultipleForLinux.tar"
elif [ "$ARCHITECTURE" == "aarch64" ]; then
    CLIENT_URL="https://cdn.app.multiple.cc/client/linux/arm64/multipleforlinux.tar"
    CLIENT_FILE="MultipleForLinux.tar"
else
    echo "Arsitektur tidak didukung: $ARCHITECTURE"
    exit 1
fi

# Membuat direktori /root/.multiple jika belum ada
TARGET_DIR="/root/.multiple"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || { echo "Gagal masuk ke direktori $TARGET_DIR"; exit 1; }

# Mengunduh file client
download_file "$CLIENT_URL" "$CLIENT_FILE"

# Mengekstrak file yang telah diunduh
extract_tar "$CLIENT_FILE"

# Hapus file .tar setelah ekstraksi
if [ -f "$CLIENT_FILE" ]; then
    echo "Menghapus file tar setelah ekstraksi..."
    rm -f "$CLIENT_FILE"
fi

# Memeriksa apakah direktori multipleforlinux ada setelah ekstraksi
if [ ! -d "./multipleforlinux" ]; then
    echo "Direktori multipleforlinux tidak ditemukan setelah ekstraksi. Membuat direktori secara manual..."
    mkdir -p ./multipleforlinux

    # Memindahkan file-file yang diekstrak ke direktori multipleforlinux
    echo "Memindahkan file-file yang diekstrak ke direktori multipleforlinux..."
    mv ./* ./multipleforlinux/ 2>/dev/null
fi

# Pindah ke direktori multipleforlinux
cd ./multipleforlinux || { echo "Gagal masuk ke direktori multipleforlinux"; exit 1; }

# Memeriksa apakah file multiple-cli dan multiple-node ada setelah ekstraksi
if [ ! -f "./multiple-cli" ] || [ ! -f "./multiple-node" ]; then
    echo "File yang dibutuhkan tidak ditemukan setelah ekstraksi. Pastikan file yang diunduh benar."
    exit 1
fi

# Memberikan izin eksekusi pada file yang diekstrak
chmod +x ./multiple-cli
chmod +x ./multiple-node

# Menambahkan direktori yang diekstrak ke PATH hanya untuk sesi ini
EXTRACTED_DIR=$(pwd)
echo "Menambahkan direktori ke PATH: $EXTRACTED_DIR"
export PATH=$PATH:$EXTRACTED_DIR

# Memberikan izin penuh pada folder hasil ekstraksi
chmod -R 777 "$EXTRACTED_DIR"

# Menjalankan aplikasi dengan output log
echo "Menjalankan program multiple-node..."
nohup ./multiple-node > output.log 2>&1 &

# Menjalankan bind dengan parameter yang dimasukkan
./multiple-cli bind --bandwidth-download 100 --identifier 1S00BIIS --pin 123369 --storage 200 --bandwidth-upload 100
