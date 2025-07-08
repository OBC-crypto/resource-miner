from flask import Flask, request
from datetime import datetime, timedelta
import threading
import time
import requests

app = Flask(__name__)
last_seen = {}

# =====================
# Konfigurasi Telegram
# =====================
BOT_TOKEN = "8039103967:AAH5wWpQ4JeA05VxXEK6H6KJKI5IlxC74MY"  # Ganti dengan milikmu
CHAT_ID = "843382635"  # Ganti dengan chat ID kamu

# =====================
# Fungsi Kirim Telegram
# =====================
def send_telegram(message):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {
        "chat_id": CHAT_ID,
        "text": message,
        "parse_mode": "Markdown"
    }
    try:
        response = requests.post(url, data=payload, timeout=5)
        print(f"[TELEGRAM] Response: {response.text}")
        if not response.ok or not response.json().get("ok"):
            print(f"[TELEGRAM ERROR] Payload gagal dikirim: {response.text}")
    except Exception as e:
        print(f"[TELEGRAM ERROR] {e}")

# =====================
# Endpoint /report
# =====================
@app.route('/report')
def report():
    cloud_id = request.args.get("id")
    ip = request.args.get("ip")
    ts = request.args.get("ts")

    if cloud_id and ip:
        now = datetime.utcnow()
        new_entry = cloud_id not in last_seen

        last_seen[cloud_id] = {
            "ip": ip,
            "timestamp": now
        }

        print(f"[RECEIVED] {cloud_id} - {ip} at {ts or now}")

        # Notifikasi saat ID baru terdaftar
        if new_entry:
            msg = (
                f"🆕 *Cloud Shell Baru Terdaftar*\n"
                f"🆔 ID: *{cloud_id}*\n"
                f"🔌 IP: `{ip}`\n"
                f"⏰ Waktu: {ts or now.strftime('%Y-%m-%d %H:%M:%S')}"
            )
            send_telegram(msg)

    return "ok"

# =====================
# Monitor & Timeout 3 Menit
# =====================
def monitor():
    while True:
        now = datetime.utcnow()
        to_remove = []

        for cloud_id, data in list(last_seen.items()):
            last_time = data['timestamp']
            if now - last_time > timedelta(minutes=3):
                msg = (
                    f"⚠️ *Cloud Shell OFFLINE!*\n"
                    f"🆔 ID: *{cloud_id}*\n"
                    f"🔌 IP: `{data['ip']}`\n"
                    f"🕒 Terakhir aktif: {last_time.strftime('%Y-%m-%d %H:%M:%S')}"
                )
                send_telegram(msg)
                to_remove.append(cloud_id)

        for cid in to_remove:
            del last_seen[cid]

        time.sleep(60)

# =====================
# Start Flask + Monitor
# =====================
if __name__ == '__main__':
    threading.Thread(target=monitor, daemon=True).start()
    app.run(host='0.0.0.0', port=5051)

