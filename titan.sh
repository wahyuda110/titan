#!/bin/bash 

# Periksa apakah skrip dijalankan sebagai pengguna root 
jika [ "$(id -u)" != "0" ]; lalu 
    echo "Skrip ini harus dijalankan dengan izin pengguna root 
    echo " Silakan coba gunakan perintah 'Gunakan sudo -i' untuk beralih ke pengguna root, lalu jalankan skrip ini lagi. " 
    exit 1 
fi 

echo "Skrip dan tutorialnya ditulis oleh pengguna Twitter Da Bei Ge @y95277777 open source, mohon jangan percaya biayanya." 
echo "==== === == ===========" 
echo "Grup Telegram komunitas Node: https://t.me/niuwuriji" 
echo "Komunitas Node Telegram channel : https://t.me/niuwuriji" 

# Baca dan muat Informasi kode identitas 
baca -p "Masukkan kode identitas anda : " id 

# Biarkan pengguna memasukkan jumlah container yang ingin dibuat 
baca -p "Silakan masukkan jumlah node yang ingin dibuat. Satu IP dibatasi maksimal 5 node: " container_count 

# Biarkan pengguna memasukkan batas ukuran hard disk setiap node (dalam GB) 
read -p "Silakan masukkan batas ukuran hard disk setiap node (dalam GB, misalnya: 1 mewakili 1GB, 2 mewakili 2GB): " disk_size_gb 

# Tanyakan direktori penyimpanan volume data pengguna, dan tetapkan nilai default 
read -p "Silahkan masukkan direktori penyimpanan volume data [default: /mnt /docker_volumes]: " volume_dir 
volume_dir=${volume_dir:-/mnt/docker_volumes} 

apt update 

# Periksa apakah Docker telah diinstal Instal 
if ! command -v docker &> /dev/null 
lalu 
    echo "Docker tidak terdeteksi, sedang menginstal. .." 
    apt-get install ca-certificates curl gnupg lsb-release 
    
    # Instal versi terbaru Docker 
    apt-get install docker.io -y 
else 
    echo "Docker telah diinstal." 
fi 

# Tarik gambar Docker 
docker pull nezha123/ titan-edge 

# Buat direktori penyimpanan file gambar 
mkdir -p $volume_dir 

# Buat jumlah container yang ditentukan pengguna 
untuk i di $(seq 1 $ container_count) 
do 
    disk_size_mb=$((disk_size_gb * 1024)) 
    
    # Buat sistem file gambar dengan ukuran tertentu untuk setiap kontainer 
    volume_path="$volume_dir/volume_$i.img" 
    sudo dd if=/dev/zero of=$ volume_path bs=1M count=$disk_size_mb 
    sudo mkfs.ext4 $volume_path 

    # Buat direktori dan pasang sistem berkas 
    mount_point="/mnt/my_volume_$i" 
    mkdir -p $mount_point 
    sudo mount -o loop $volume_path $mount_point 

    # Akan dipasang Tambahkan informasi ke /etc/fstab 
    echo "$volume_path $mount_point ext4 loop,defaults 0 0" | sudo tee -a /etc/fstab 

    # Jalankan container dan setel kebijakan mulai ulang ke selalu 
    container_id=$(docker run -d --restart selalu -v $mount_point:/root/.titanedge/storage --name " titan$i" nezha123/titan-edge) 

    echo "Node titan$i telah memulai ID container $container_id" 

    sleep 30 
    
    # Masuk ke container dan lakukan pengikatan dan perintah lainnya 
    docker exec -it $container_id bash -c "\ 
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding" 
selesai 

echo "== = =========== Semua node sudah diatur dan dimulai =============== == ===."
