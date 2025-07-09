# ⚙️ Resource-Miner: Setup Otomatis & Monitoring Cloud Instance

`resource-miner` adalah skrip otomatisasi yang membantu Anda mengatur waktu server, meningkatkan performa sistem (melalui swap file), mengelola container Docker, serta mengaktifkan sistem monitoring melalui notifikasi Telegram dengan systemd.

---

## 📆 Pengaturan Waktu Server
-----------------------------
Cek waktu saat ini:

   ```bash
   date

Pilih zona waktu yang sesuai:

timedatectl list-timezones | grep Makassar

Atur zona waktu ke Asia/Makassar:

sudo timedatectl set-timezone Asia/Makassar

Konfirmasi:

timedatectl
date

#🐳 Menjalankan Container Docker
-------------------------------
Jalankan container:

docker compose up -d

Cek status container:

docker ps -a

Lihat log:

docker logs <container-name-or-id>

Restart container:

docker restart <container-name-or-id>

#Menambahkan Swap (Virtual RAM)
--------------------------------
Cek memori:

free -h

Tambahkan 2GB swap:


sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

Tuning performa swap:


sudo sysctl vm.swappiness=10
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

sudo sysctl vm.vfs_cache_pressure=50
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

Verifikasi:

free -h

#📂 Menyimpan Skrip ke Direktori /root
-------------------------------------

sudo su -
git clone https://github.com/OBC-crypto/resource-miner.git
cd resource-miner


#🔁 Eksekusi Skrip Otomatisasi
----------------------------

reboot.sh
Edit file:
nano reboot.sh

Isi TELEGRAM_TOKEN dan CHAT_ID.

Simpan dan beri izin eksekusi:

chmod +x reboot.sh
./reboot.sh


restart-container.sh
Edit file:
nano restart-container.sh

Isi TELEGRAM_TOKEN dan CHAT_ID.

Simpan dan eksekusi:

chmod +x restart-container.sh
./restart-container.sh


#🛡️ Menjalankan Monitoring via systemd
-------------------------------------

Pindahkan dan edit skrip receiver:

mv /root/resource-miner/receiver.py /root
nano /root/receiver.py
Isi token Telegram dan chat ID lalu simpan.


Aktifkan layanan dengan systemd:


mv /root/resource-miner/cloudshell-receiver.service /etc/systemd/system
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable cloudshell-receiver
sudo systemctl restart cloudshell-receiver

Jalankan service pemantauan IP:

sudo systemctl status ip-monitor.service

#📋 Melihat Log Output
---------------------------

journalctl -u ip-monitor.service -f

#📌 Catata
---------------
Skrip ini ditujukan untuk pengguna tingkat lanjut dan penggunaan pribadi dalam mengelola resource cloud/VPS.

Pastikan untuk tidak menyalahgunakan layanan cloud publik agar tidak melanggar kebijakan layanan.

yaml

