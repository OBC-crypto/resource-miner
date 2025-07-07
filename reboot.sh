#!/bin/bash

# Token dan Chat ID Telegram
TELEGRAM_TOKEN="xxxxxxxx"
CHAT_ID="xxxxxxxxx"

# Pastikan python3 dan pip terinstal
echo "[?] Memastikan Python3 dan pip tersedia..."
apt update -y
apt install -y python3 python3-pip

# Install requests jika belum ada
pip3 install requests --quiet

# Buat skrip: reboot_and_notify.py
cat <<EOF > /root/reboot_and_notify.py
import requests
import time
import os

TELEGRAM_TOKEN = "$TELEGRAM_TOKEN"
TELEGRAM_CHAT_ID = "$CHAT_ID"

def send_telegram_message(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    data = {
        "chat_id": TELEGRAM_CHAT_ID,
        "text": message
    }
    requests.post(url, data=data)

def main():
    send_telegram_message("🔁 Ogis dan Buda, Server 1 direboot sekarang.")
    time.sleep(2)
    os.system("reboot")

if __name__ == "__main__":
    main()
EOF

# Buat skrip: notify_after_reboot.py
cat <<EOF > /root/notify_after_reboot.py
import requests
import time

TELEGRAM_TOKEN = "$TELEGRAM_TOKEN"
TELEGRAM_CHAT_ID = "$CHAT_ID"

def send_telegram_message(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    data = {
        "chat_id": TELEGRAM_CHAT_ID,
        "text": message
    }
    requests.post(url, data=data)

def main():
    time.sleep(30)
    send_telegram_message("✅ Ogis dan Buda server 1 sudah aktif kembali.")

if __name__ == "__main__":
    main()
EOF

# Tambahkan cron jobs
echo "[?] Menambahkan cron job..."
(crontab -l 2>/dev/null; echo "0 22 * * * /usr/bin/python3 /root/reboot_and_notify.py") | crontab -
(crontab -l 2>/dev/null; echo "@reboot /usr/bin/python3 /root/notify_after_reboot.py") | crontab -

# Permissions
chmod +x /root/reboot_and_notify.py /root/notify_after_reboot.py

echo "[?] Setup selesai. VPS akan otomatis reboot setiap jam 22:00 dan kirim notifikasi Telegram."
