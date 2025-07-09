from flask import Flask, request
from datetime import datetime, timedelta
import threading
import time
import requests
import subprocess

app = Flask(__name__)
last_seen = {}

# ======================
# Konfigurasi Telegram
# ======================
BOT_TOKEN = ""
CHAT_ID = ""

def send_telegram(message):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {
        "chat_id": CHAT_ID,
        "text": message,
        "parse_mode": "HTML"
    }
    try:
        r = requests.post(url, data=payload, timeout=5)
        print(f"[TELEGRAM] {r.status_code} {r.text}")
    except Exception as e:
        print(f"[ERROR] Telegram: {e}")

# ======================
# Endpoint /report
# ======================
@app.route('/report')
def report():
    cloud_id = request.args.get("id")
    ip = request.args.get("ip")
    ts = request.args.get("ts")

    if cloud_id and ip:
        now = datetime.utcnow()
        is_new = cloud_id not in last_seen

        last_seen[cloud_id] = {
            "ip": ip,
            "timestamp": now,
            "fail_ping": 0
        }

        print(f"[RECEIVED] {cloud_id} - {ip} at {ts or now}")

        if is_new:
            msg = (
                f"🆕 <b>Cloud Shell Baru Terdeteksi</b>\n"
                f"🆔 ID: <b>{cloud_id}</b>\n"
                f"🔌 IP: <code>{ip}</code>\n"
                f"🕒 Waktu: {ts or now}"
            )
            send_telegram(msg)

    return "ok"

# ======================
# Monitor timeout (3 menit tidak aktif)
# ======================
def timeout_monitor():
    while True:
        now = datetime.utcnow()
        to_remove = []

        for cloud_id, data in last_seen.items():
            last_time = data['timestamp']
            if now - last_time > timedelta(minutes=3):
                msg = (
                    f"⚠️ <b>Cloud Shell Timeout (3 menit tanpa sinyal)</b>\n"
                    f"🆔 ID: <b>{cloud_id}</b>\n"
                    f"🔌 IP: <code>{data['ip']}</code>\n"
                    f"🕒 Terakhir aktif: {last_time}"
                )
                send_telegram(msg)
                to_remove.append(cloud_id)

        for cid in to_remove:
            del last_seen[cid]

        time.sleep(60)

# ======================
# Monitor ping ke setiap IP
# ======================
def ping_monitor():
    while True:
        to_remove = []

        for cloud_id, data in list(last_seen.items()):
            ip = data['ip']
            result = subprocess.run(["ping", "-c", "1", "-W", "1", ip],
                                    stdout=subprocess.DEVNULL)

            if result.returncode != 0:
                data['fail_ping'] += 1
                print(f"[PING FAIL] {cloud_id} → {ip} (Fail #{data['fail_ping']})")

                if data['fail_ping'] >= 3:
                    msg = (
                        f"🚫 <b>Cloud Shell Tidak Bisa Dihubungi (Ping Gagal)</b>\n"
                        f"🆔 ID: <b>{cloud_id}</b>\n"
                        f"🔌 IP: <code>{ip}</code>\n"
                        f"🕒 Terakhir terlihat: {data['timestamp']}"
                    )
                    send_telegram(msg)
                    to_remove.append(cloud_id)
            else:
                data['fail_ping'] = 0
                print(f"[PING OK] {cloud_id} → {ip}")

        for cid in to_remove:
            del last_seen[cid]

        time.sleep(30)

# ======================
# Jalankan Flask + Thread Monitor
# ======================
if __name__ == '__main__':
    threading.Thread(target=timeout_monitor, daemon=True).start()
    threading.Thread(target=ping_monitor, daemon=True).start()
    app.run(host='0.0.0.0', port=5051)
