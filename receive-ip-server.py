#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import time

PORT = 5050  # Bisa disesuaikan
DATA_FILE = "cloudshell_ips.txt"

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        query = urllib.parse.parse_qs(parsed.query)
        alias = query.get("id", ["unknown"])[0]
        ip = query.get("ip", [""])[0]

        if ip:
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
            with open(DATA_FILE, "a") as f:
                f.write(f"{alias},{ip},{timestamp}\n")
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Missing IP")

httpd = HTTPServer(("", PORT), SimpleHandler)
print(f"🌐 Listening on port {PORT}...")
httpd.serve_forever()
