#!/usr/bin/env bash
# Emballe la compilation Linux de Flutter en un seul fichier AppImage, libmpv comprise.
#   packaging/linux/build-appimage.sh <version> <dossier de sortie>
# À lancer depuis la racine du dépôt, après `flutter build linux --release` dans app/.
# media_kit ne fournit pas libmpv sous Linux : on embarque celle du système de compilation et ses
# dépendances, sauf le socle listé dans system-libs.txt. Ce tri a été réglé à l'essai : embarquer
# GLib casse Fedora, trop en laisser au système casse Debian et Arch.
set -euo pipefail
version="$1"
out="$2"
bundle="app/build/linux/x64/release/bundle"
appdir="$(mktemp -d)/Chud-IPTV.AppDir"

mkdir -p "$appdir/usr/bin" "$appdir/usr/lib" "$out"
cp -r "$bundle"/. "$appdir/usr/bin/"
install -m 755 packaging/linux/AppRun "$appdir/AppRun"
cp packaging/linux/chud-iptv.desktop "$appdir/"
cp packaging/linux/chud-iptv.png "$appdir/chud-iptv.png"

copy_deps() {
  ldd "$1" | awk '/=> \//{print $1, $3}' | while read -r name path; do
    if ! grep -qxF "$name" packaging/linux/system-libs.txt && [ ! -e "$appdir/usr/lib/$name" ]; then
      cp -L "$path" "$appdir/usr/lib/$name"
      copy_deps "$path"
    fi
  done
}
cp -L "$(ldconfig -p | awk '/libmpv.so.1 /{print $NF; exit}')" "$appdir/usr/lib/libmpv.so.1"
copy_deps "$appdir/usr/lib/libmpv.so.1"
copy_deps "$bundle/chud-iptv"
for plugin in "$bundle"/lib/*.so; do
  copy_deps "$plugin"
done

tool="$(mktemp -d)/appimagetool"
curl -fsSL -o "$tool" https://github.com/AppImage/appimagetool/releases/download/1.9.0/appimagetool-x86_64.AppImage
chmod +x "$tool"
# Les machines de GitHub n'ont pas FUSE : l'outil se déplie avant de s'exécuter.
APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 "$tool" --no-appstream "$appdir" "$out/Chud-IPTV-$version-x86_64.AppImage"
