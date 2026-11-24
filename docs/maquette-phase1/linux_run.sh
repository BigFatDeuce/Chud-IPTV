#!/bin/sh
# Maquette : lance l'AppImage sur une distribution vierge (sans libmpv), sous écran virtuel.
set -u
id=$(. /etc/os-release; echo "$ID $VERSION_ID")
echo "=== $id"
if command -v apt-get >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq >/dev/null; apt-get install -y -qq xvfb libgtk-3-0 libgl1 libegl1 libasound2 libpulse0 mesa-utils >/dev/null 2>&1 \
    || apt-get install -y -qq xvfb libgtk-3-0t64 libgl1 libegl1 libasound2t64 libpulse0 >/dev/null 2>&1
elif command -v dnf >/dev/null; then
  dnf install -y -q xorg-x11-server-Xvfb gtk3 mesa-libGL mesa-libEGL mesa-dri-drivers libglvnd-gles alsa-lib pulseaudio-libs >/dev/null 2>&1
elif command -v pacman >/dev/null; then
  pacman -Syu --noconfirm -q xorg-server-xvfb gtk3 mesa alsa-lib libpulse >/dev/null 2>&1
fi
echo "libmpv systeme: $(find / -name 'libmpv.so*' -not -path '/proc/*' -not -path '/out/*' 2>/dev/null | wc -l) fichier(s)"
cp /out/Spike-x86_64.AppImage /tmp/s.AppImage && chmod +x /tmp/s.AppImage
Xvfb :9 -screen 0 1280x720x24 >/dev/null 2>&1 &
sleep 2
export DISPLAY=:9 APPIMAGE_EXTRACT_AND_RUN=1 LIBGL_ALWAYS_SOFTWARE=1 HOME=/root XDG_DATA_HOME=/root/.local/share
timeout 90 /tmp/s.AppImage > /tmp/app.log 2>&1
echo "exit=$?"
find /root -name spike_log.jsonl 2>/dev/null | head -1 | xargs -r cat | cut -c1-230
grep -v '^SPIKE' /tmp/app.log | tail -6
