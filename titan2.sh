#!/bin/bash

# Periksa apakah skrip dijalankan sebagai pengguna root
if [ "$(id -u)" != "0" ]; then
    echo "Skrip ini harus dijalankan dengan izin pengguna root 
    echo " Silakan coba gunakan perintah 'Gunakan sudo -i' untuk beralih ke pengguna root, lalu jalankan skrip ini lagi. "
    exit 1
fi

echo "source @y95277777 im just translate"
echo "================================================================"

# Baca dan muat informasi kode identitas
read -p "Masukan Code Identity Anda: " id

# pengguna memasukkan jumlah container yang ingin dibuat
read -p "Silakan masukkan Jumlah node yang ingin Anda buat, satu IP dibatasi paling banyak 5 node: " container_count

# Biarkan pengguna memasukkan nomor port RPC awal
read -p "Silakan masukkan RPC awal yang ingin Anda atur (silakan atur sendiri nomor portnya, aktifkan 5 Port node akan diperluas secara numerik secara berurutan): " start_rpc_port

# Biarkan pengguna memasukkan ukuran ruang yang ingin mereka alokasikan 
read -p "Silakan masukkan ukuran ruang penyimpanan (GB) yang ingin Anda alokasikan untuk setiap node, batas atas tunggal adalah 64GB, halaman web lebih efektif Lambat. Setelah menunggu 20 menit, halaman web dapat ditanyakan: " storage_gb

# pengguna memasukkan jalur penyimpanan (opsional) 
read -p "Silakan masukkan jalur host tempat node menyimpan data (tekan Enter secara langsung dan jalur default titan_storage_$i akan digunakan, diikuti dengan ekstensi Nomor): " custom_storage_path

apt update

# Centang jika Docker diinstal 
if ! command -v docker &> /dev/null
then
    echo "Docker tidak terdeteksi, menginstal..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # Instal Docker versi terbaru 
    apt-get install docker.io -y
else
    echo "Docker telah diinstal."
fi

# Tarik gambar Docker
docker pull nezha123/titan-edge:1.4

# Buat sejumlah kontainer yang ditentukan pengguna
for ((i=1; i<=container_count; i++))
do
    current_rpc_port=$((start_rpc_port + i - 1))

    # Tentukan apakah pengguna telah memasukkan jalur penyimpanan khusus 
    if [ -z "$custom_storage_path" ]; then
        # Jika pengguna belum memasukkan, gunakan jalur default
        storage_path="$PWD/titan_storage_$i"
    else
        # pengguna telah memasukkan jalur khusus, gunakan Jalur yang disediakan oleh pengguna 
        storage_path="$custom_storage_path"
    fi

    # Pastikan jalur penyimpanan ada 
    mkdir -p "$storage_path"

    # Jalankan container dan setel kebijakan mulai ulang ke selalu 
    container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host  nezha123/titan-edge:1.4)

    echo "Node titan$i telah memulai ID kontainer $container_id"

    sleep 30

    # Ubah file config.toml host untuk mengatur nilai StorageGB dan port
    docker exec $container_id bash -c "\
        sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
        sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_rpc_port\"/' /root/.titanedge/config.toml && \
        echo 'Ruang penyimpanan titan'$i' disetel ke $storage_gb GB, dan port RPC disetel ke $current_rpc_port'"

    # Mulai ulang wadah agar pengaturan diterapkan 
    docker restart $container_id

    # Masuk ke container dan lakukan pengikatan Order
    docker exec $container_id bash -c "\
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
    echo "Node titan$i terikat ."

done

echo "===========================Semua node telah disiapkan dan dimulai==========================="
