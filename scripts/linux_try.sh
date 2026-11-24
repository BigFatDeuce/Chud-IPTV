#!/bin/sh
# Essaie l'AppImage sur une distribution vierge, sous écran virtuel : démarrage, source de test
# ajoutée au clavier, lecture d'une chaîne, et capture de l'écran.
#   docker run --rm --add-host=host.docker.internal:host-gateway -v <dist>:/out -v <dépôt>/scripts/linux_try.sh:/try.sh:ro debian:13 sh /try.sh
# Le serveur factice (docs/maquette-phase1/serve.py) doit tourner sur l'hôte, port 18099.
set -u
name=$(. /etc/os-release; echo "$ID")
echo "=== $(. /etc/os-release; echo "$ID $VERSION_ID")"
if command -v apt-get >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq >/dev/null
  apt-get install -y -qq xvfb xdotool x11-apps imagemagick libgtk-3-0 libgl1 libegl1 libgles2 libasound2 libpulse0 >/dev/null 2>&1 \
    || apt-get install -y -qq xvfb xdotool x11-apps imagemagick libgtk-3-0t64 libgl1 libegl1 libgles2 libasound2t64 libpulse0 >/dev/null 2>&1
elif command -v dnf >/dev/null; then
  dnf install -y -q xorg-x11-server-Xvfb xdotool ImageMagick xwd gtk3 mesa-libGL mesa-libEGL mesa-dri-drivers libglvnd-gles alsa-lib pulseaudio-libs >/dev/null 2>&1
elif command -v pacman >/dev/null; then
  pacman -Syu --noconfirm -q xorg-server-xvfb xdotool imagemagick xorg-xwd gtk3 mesa alsa-lib libpulse >/dev/null 2>&1
fi
echo "libmpv du système : $(find / -name 'libmpv.so*' -not -path '/proc/*' -not -path '/out/*' -not -path '/tmp/*' 2>/dev/null | wc -l) fichier(s)"
cp /out/Chud-IPTV-*-x86_64.AppImage /tmp/c.AppImage && chmod +x /tmp/c.AppImage
Xvfb :9 -screen 0 1280x720x24 >/dev/null 2>&1 &
sleep 2
export DISPLAY=:9 APPIMAGE_EXTRACT_AND_RUN=1 LIBGL_ALWAYS_SOFTWARE=1 HOME=/root
/tmp/c.AppImage > /tmp/app.log 2>&1 &
app=$!
sleep 7
key() { for k in "$@"; do xdotool key --clearmodifiers "$k"; sleep 0.35; done; }
shot() { xwd -root -silent | convert xwd:- "/out/$name-$1.png"; }
shot 1-accueil
key Return; sleep 1
key Tab Tab Tab Return; sleep 0.5
key Tab Tab
xdotool type --delay 40 'Tests'; key Tab
xdotool type --delay 40 'http://host.docker.internal:18099/list.m3u'
key Down Down Down Return
sleep 4
shot 2-liste
# Troisième chaîne : H264 1080p.
key Right Down Down Return
sleep 9
shot 3-lecture
if kill -0 "$app" 2>/dev/null; then echo "l'app tourne toujours"; else echo "l'app s'est arrêtée"; fi
kill "$app" 2>/dev/null
grep -iE 'cannot open|symbol|not found|segmentation' /tmp/app.log | tail -4
