#!/bin/bash

# ?? Konfigurasi
TELEGRAM_TOKEN="XXXXXXXXX"
CHAT_ID="XXXXXXX"
CONTAINER_NAME="resource-vps"  # Ganti dengan nama container kamu

# ?? Pastikan Python3 dan pip tersedia
echo "[?] Memastikan Python3 dan pip tersedia..."
apt update -y
apt install -y python3 python3-pip

# ?? Install pustaka Python (requests, pytz)
pip3 install requests pytz --quiet

# ?? Buat skrip Python untuk restart dan notifikasi
cat <<EOF > /root/container_restart_notify.py
import requests
import subprocess
import time
from datetime import datetime
import pytz

TELEGRAM_TOKEN = "$TELEGRAM_TOKEN"
TELEGRAM_CHAT_ID = "$CHAT_ID"
CONTAINER_NAME = "$CONTAINER_NAME"

def get_local_time():
    tz = pytz.timezone('Asia/Makassar')
    return datetime.now(tz).strftime('%Y-%m-%d %H:%M:%S')

def send_telegram_message(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    data = {
        "chat_id": TELEGRAM_CHAT_ID,
        "text": message,
        "parse_mode": "Markdown"
    }
    requests.post(url, data=data)

def restart_container():
    time_now = get_local_time()
    send_telegram_message(f"🔄 Ogis dan Buda, *{CONTAINER_NAME}* server1 di-restart.\n🕒 Waktu: {time_now} TA")

    try:
        subprocess.run(["docker", "restart", CONTAINER_NAME], check=True)
        time.sleep(5)
        time_now = get_local_time()
        send_telegram_message(f"✅ Ogis dan Buda *{CONTAINER_NAME}* server1 sudah di-restart.\n🕒 Waktu: {time_now}ITA")
    except subprocess.CalledProcessError as e:
        send_telegram_message(f"❌ Gagal me-restart container *{CONTAINER_NAME}*: {str(e)}")

if __name__ == "__main__":
    restart_container()
EOF

# ?? Tambahkan cron job
echo "[?] Menambahkan cron job..."
(crontab -l 2>/dev/null; echo "0 4 * * * /usr/bin/python3 /root/container_restart_notify.py") | crontab -
(crontab -l 2>/dev/null; echo "5 12 * * * /usr/bin/python3 /root/container_restart_notify.py") | crontab -

# ??? Izin eksekusi
chmod +x /root/container_restart_notify.py

echo "[?] Setup selesai. Container $CONTAINER_NAME akan auto-restart jam 04:00-PAGI & 12:05-SIANG dengan notifikasi Telegram."
