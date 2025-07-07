# resource-miner

#cara mengatur jam server#

date
timedatectl list-timezones | grep Makassar
sudo timedatectl set-timezone Asia/Makassar
timedatectl
date
------------------------------------------------------------------------------


#Menambah ukuran swap

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
--------------------------------------------------------------------------------


#Eksekusi script reboot.sh

chmod +x reboot.sh
./reboot.sh
------------------------------------------------------------------------------


#Eksekusi script restart-container.sh

chmod +x restart-container.sh
./restart-container.sh
-------------------------------------------------------------------------------


#Eksekusi script multi-monitor-auto-clean.sh

chmod multi-monitor-auto-clean.sh
./multi-monitor-auto-clean.sh &
------------------------------------------------------------------------------


#Eksekusi simple python webserver (no dashboard)

chmod +x receive-ip-server.py
nohup ./receive-ip-server.py &
-------------------------------------------------------------------------------
