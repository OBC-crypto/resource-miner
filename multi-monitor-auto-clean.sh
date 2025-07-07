#!/bin/bash

# ========== Konfigurasi ==========
BOT_TOKEN="123456789:ABCdefGHIjkLMNopQRStuvWXYz"  # Ganti token bot kamu
CHAT_ID="123456789"                               # Ganti chat ID kamu
MAX_FAILS=3
INTERVAL=60
DATA_FILE="cloudshell_ips.txt"
TMP_FILE="cloudshell_ips_latest.tmp"

# ========== Fungsi Kirim Notifikasi ==========
send_telegram() {
  local ALIAS="$1"
  local IP="$2"
  local TIME_NOW=$(date '+%Y-%m-%d %H:%M:%S')
  local MESSAGE="⚠️ *Cloud Shell OFFLINE & Dihapus dari Monitoring!*\n📛 ID: *$ALIAS*\n🔌 IP: \`$IP\`\n📅 Waktu: $TIME_NOW"
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown"
}

# ========== Fungsi Ambil IP Terbaru ==========
load_latest_ips() {
  # Ambil entri terbaru per alias, urutkan berdasarkan waktu terakhir
  tac "$DATA_FILE" | awk -F, '!seen[$1]++' | tac > "$TMP_FILE"
}

# ========== Status ping gagal ==========
declare -A FAIL_COUNT

# ========== Loop Monitoring ==========
echo "📡 Memulai monitoring IP dari $DATA_FILE..."

while true; do
  load_latest_ips

  while IFS=',' read -r ALIAS IP TIMESTAMP; do
    # Skip entri kosong
    if [[ -z "$ALIAS" || -z "$IP" ]]; then
      continue
    fi

    echo "🔍 [$ALIAS] Ping ke $IP..."
    ping -c 1 -W 3 "$IP" > /dev/null

    if [ $? -ne 0 ]; then
      ((FAIL_COUNT["$ALIAS"]++))
      echo "❌ [$ALIAS] Gagal ping ${FAIL_COUNT[$ALIAS]}/$MAX_FAILS"

      if [ "${FAIL_COUNT[$ALIAS]}" -ge "$MAX_FAILS" ]; then
        send_telegram "$ALIAS" "$IP"
        unset FAIL_COUNT["$ALIAS"]
        grep -v "^$ALIAS," "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
      fi
    else
      echo "✅ [$ALIAS] Ping berhasil"
      FAIL_COUNT["$ALIAS"]=0
    fi
  done < "$TMP_FILE"

  echo "⏳ Menunggu $INTERVAL detik sebelum siklus berikutnya..."
  sleep "$INTERVAL"
done
