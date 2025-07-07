# resource-miner

#cara mengatur jam server#
---------------------------------------------------------------------------



date

timedatectl list-timezones | grep Makassar

sudo timedatectl set-timezone Asia/Makassar

timedatectl

date



#Menambah ukuran swap
-----------------------------------------------------------------------------

free -h

sudo fallocate -l 2G /swapfile

sudo chmod 600 /swapfile

sudo mkswap /swapfile

sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

free -h

sudo sysctl vm.swappiness=10

echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

sudo sysctl vm.vfs_cache_pressure=50

echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf


#Menyimpan semua script pada direktori /root
----------------------------------------------------------------------------

sudo su -

git clone https://github.com/OBC-crypto/resource-miner.git

cd resource-miner


#Eksekusi script reboot.sh
-----------------------------------------------------------------------------


chmod +x reboot.sh

./reboot.sh



#Eksekusi script restart-container.sh
-----------------------------------------------------------------------------


chmod +x restart-container.sh

./restart-container.sh



#Eksekusi script multi-monitor-auto-clean.sh
-----------------------------------------------------------------------------


mv /root/resource-miner/multi-monitor-auto-clean.sh /root

chmod multi-monitor-auto-clean.sh

./multi-monitor-auto-clean.sh &



#Eksekusi simple python webserver (no dashboard)
----------------------------------------------------------------------------


mv /root/resource-miner/receive-ip-server.py /root

chmod +x receive-ip-server.py

nohup ./receive-ip-server.py &



#Menambahkan pengaturan pada systemd
----------------------------------------------------------------------------


mv  /root/resource-miner/ip-monitor.service /etc/systemd/system


sudo systemctl daemon-reload

sudo systemctl enable ip-monitor.service

sudo systemctl start ip-monitor.service

sudo systemctl status ip-monitor.service


#Mengecek Log output
---------------------------------------------------------------------------

journalctl -u ip-monitor.service -f

