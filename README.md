# ⚙️ Resource-Miner: Setup Otomatis & Monitoring Cloud Instance

`resource-miner` adalah skrip otomatisasi yang membantu Anda mengatur waktu server, meningkatkan performa sistem (melalui swap file), mengelola container Docker, serta mengaktifkan sistem monitoring melalui notifikasi Telegram dengan systemd.

---

## 📆 Pengaturan Waktu Server
-----------------------------
1. Cek waktu saat ini:

       date

2. Pilih zona waktu yang sesuai:

       timedatectl list-timezones | grep Makassar

3. Atur zona waktu ke Asia/Makassar:

       sudo timedatectl set-timezone Asia/Makassar

4. Konfirmasi:

       timedatectl
       date

#🐳 Menjalankan Container Docker
-------------------------------

1. Jalankan container:

       docker compose up -d

2. Cek status container:

       docker ps -a

3. Lihat log:

       docker logs <container-name-or-id>

4. Restart container:

       docker restart <container-name-or-id>


#Menambahkan Swap (Virtual RAM)
--------------------------------
1. Cek memori:

       free -h

2. Tambahkan 2GB swap:


       sudo fallocate -l 2G /swapfile
       sudo chmod 600 /swapfile
       sudo mkswap /swapfile
       sudo swapon /swapfile
       echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

3. Tuning performa swap:


       sudo sysctl vm.swappiness=10
       echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

       sudo sysctl vm.vfs_cache_pressure=50
       echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

4. Verifikasi:

       free -h

#📂 Menyimpan Skrip ke Direktori /root
-------------------------------------

       sudo su -
       git clone https://github.com/OBC-crypto/resource-miner.git
       cd resource-miner


#🔁 Eksekusi Skrip Otomatisasi
----------------------------

1. reboot.sh

   Edit file:

       nano reboot.sh

2. Isi TELEGRAM_TOKEN dan CHAT_ID.

3. Simpan dan beri izin eksekusi:

       chmod +x reboot.sh
       ./reboot.sh


4. restart-container.sh

   Edit file:

       nano restart-container.sh

5. Isi TELEGRAM_TOKEN dan CHAT_ID.

6. Simpan dan eksekusi:

       chmod +x restart-container.sh
       ./restart-container.sh


#🛡️ Menjalankan Monitoring via systemd
-------------------------------------

1. Pindahkan dan edit skrip receiver:

       mv /root/resource-miner/receiver.py /root
       nano /root/receiver.py

2. Isi token Telegram dan chat ID lalu simpan.


3. Aktifkan layanan dengan systemd:


        mv /root/resource-miner/cloudshell-receiver.service /etc/systemd/system
        sudo systemctl daemon-reexec
        sudo systemctl daemon-reload
        sudo systemctl enable cloudshell-receiver
        sudo systemctl restart cloudshell-receiver

4. Jalankan service pemantauan IP:

        sudo systemctl status cloudshell-receiver.service

#📋 Melihat Log Output
---------------------------

        journalctl -u ip-monitor.service -f

#📌 Ctatan
---------------

1. Skrip ini ditujukan untuk pengguna tingkat lanjut dan penggunaan pribadi dalam mengelola resource cloud/VPS.

2. Pastikan untuk tidak menyalahgunakan layanan cloud publik agar tidak melanggar kebijakan layanan.

3. Patuhi kebijakan layanan penyedia cloud. Penyalahgunaan dapat menyebabkan penangguhan akun.

