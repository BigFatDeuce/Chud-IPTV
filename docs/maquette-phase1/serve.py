"""Faux serveur IPTV pour tester le lecteur : diffuse des fichiers .ts au rythme du direct.

    python -I serve.py <dossier des .ts> <port>

/live/<nom>.ts    boucle sans fin
/cut/<nom>.ts     coupe la connexion toutes les 5 s (micro-coupures)
/outage/<nom>.ts  émet 6 s, puis refuse tout pendant 10 s (vraie panne), et reprend
/list.m3u         playlist de ces flux, pour l'ajouter comme source
/log              ce que le serveur a vu passer
"""
import http.server
import pathlib
import socketserver
import sys
import time

ROOT = pathlib.Path(sys.argv[1])
PORT = int(sys.argv[2])
CHUNK = 188 * 200
down_until = {}
started = time.time()


journal = []


def log(text):
    journal.append(f"{time.time() - started:7.1f}s {text}")


CHANNELS = [
    ("Panne 10 s", "outage/h264.ts"),
    ("Coupures 5 s", "cut/h264.ts"),
    ("H264 1080p", "live/h264.ts"),
    ("HEVC 1080p", "live/hevc.ts"),
    ("MPEG-2 576i", "live/mpeg2i.ts"),
    ("H264 1080i", "live/h264i.ts"),
    ("Morte", "live/absent.ts"),
]


class Handler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.0"

    def log_message(self, *a):
        pass

    def playlist(self):
        host = self.headers.get("Host")
        lines = ["#EXTM3U"]
        for name, path in CHANNELS:
            lines += [f'#EXTINF:-1 group-title="Tests",{name}', f"http://{host}/{path}"]
        body = ("\n".join(lines) + "\n").encode()
        self.send_response(200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/list.m3u":
            self.playlist()
            return
        if self.path == "/log":
            body = "\n".join(journal).encode()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(body)
            return
        kind, _, name = self.path.lstrip("/").partition("/")
        path = ROOT / name
        log(f"{kind}/{name}")
        if time.time() < down_until.get(name, 0):
            log("  refusé : panne en cours")
            self.send_error(503)
            return
        if kind not in ("live", "cut", "outage") or not path.exists():
            self.send_error(404)
            return
        data = path.read_bytes()
        seconds = float((ROOT / (name + ".dur")).read_text())
        rate = len(data) / seconds
        self.send_response(200)
        self.send_header("Content-Type", "video/mp2t")
        self.end_headers()
        start = time.time()
        limit = {"cut": 5, "outage": 6}.get(kind)
        sent = 0
        try:
            while True:
                offset = sent % len(data)
                self.wfile.write(data[offset : offset + CHUNK])
                sent += min(CHUNK, len(data) - offset)
                if limit and time.time() - start > limit:
                    if kind == "outage":
                        down_until[name] = time.time() + 10
                        log("  panne de 10 s")
                    return
                # Avance de 2 s, comme un serveur IPTV qui remplit le tampon au démarrage.
                wait = sent / rate - (time.time() - start) - 2
                if wait > 0:
                    time.sleep(wait)
        except (BrokenPipeError, ConnectionError):
            pass


class Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


Server(("0.0.0.0", PORT), Handler).serve_forever()
