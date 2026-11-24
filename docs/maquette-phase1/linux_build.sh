#!/usr/bin/env bash
# Maquette : compile sur Ubuntu 22.04 et fabrique une AppImage qui embarque libmpv et ses dépendances.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl git unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
  libmpv-dev mpv file libfuse2 desktop-file-utils patchelf squashfs-tools libgl1-mesa-dev libegl1-mesa-dev >/dev/null
dpkg -l | grep -E 'libmpv|libavcodec[0-9]' | awk '{print $2, $3}'
cd /opt
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.8-stable.tar.xz | tar xJ
git config --global --add safe.directory /opt/flutter
export PATH=/opt/flutter/bin:$PATH
flutter --disable-analytics >/dev/null 2>&1 || true
mkdir -p /work && cd /work
tar -C /src --exclude=build --exclude=.dart_tool --exclude=linux-out -cf - . | tar xf -
flutter pub get | tail -1
flutter build linux --release --dart-define=URLS="$URLS" 2>&1 | tail -4
bundle=build/linux/x64/release/bundle
du -sh "$bundle"
ldd "$bundle/spike" | grep -iE 'mpv|mimalloc' || true

app=/work/Spike.AppDir
mkdir -p "$app/usr/bin" "$app/usr/lib"
cp -r "$bundle"/. "$app/usr/bin/"
cat > "$app/AppRun" <<'EOF'
#!/bin/sh
here="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$here/usr/lib:$here/usr/bin/lib:$LD_LIBRARY_PATH"
export LIBMPV_LIBRARY_PATH="$here/usr/lib/libmpv.so.1"
exec "$here/usr/bin/spike" "$@"
EOF
chmod +x "$app/AppRun"
printf '[Desktop Entry]\nType=Application\nName=Spike\nExec=spike\nIcon=spike\nCategories=AudioVideo;\n' > "$app/spike.desktop"
printf '\x89PNG\r\n' > /dev/null
curl -fsSL -o "$app/spike.png" https://raw.githubusercontent.com/flutter/website/main/src/content/assets/images/branding/flutter/icon/64.png || \
  convert -size 64x64 xc:black "$app/spike.png" || touch "$app/spike.png"

# Reste au système : le socle GLib/GTK, X11/Wayland/GL, l'audio et la libc. Le reste est embarqué.
cat > /tmp/system_libs <<'LIST'
libglib-2.0.so.0
libgobject-2.0.so.0
libgio-2.0.so.0
libgmodule-2.0.so.0
libgthread-2.0.so.0
libffi.so.8
libpcre2-8.so.0
libmount.so.1
libblkid.so.1
libuuid.so.1
libselinux.so.1
libz.so.1
liblzma.so.5
libzstd.so.1
libsystemd.so.0
libdbus-1.so.3
libexpat.so.1
libbrotlidec.so.1
libbrotlicommon.so.1
libgtk-3.so.0
libgdk-3.so.0
libgdk_pixbuf-2.0.so.0
libcairo.so.2
libcairo-gobject.so.2
libpango-1.0.so.0
libpangocairo-1.0.so.0
libpangoft2-1.0.so.0
libatk-1.0.so.0
libatk-bridge-2.0.so.0
libatspi.so.0
libharfbuzz.so.0
libfreetype.so.6
libfontconfig.so.1
libX11.so.6
libX11-xcb.so.1
libXext.so.6
libXrender.so.1
libXfixes.so.3
libXi.so.6
libXcursor.so.1
libXrandr.so.2
libXinerama.so.1
libXcomposite.so.1
libXdamage.so.1
libxcb.so.1
libwayland-client.so.0
libwayland-cursor.so.0
libwayland-egl.so.1
libwayland-server.so.0
libxkbcommon.so.0
libGL.so.1
libEGL.so.1
libGLX.so.0
libGLdispatch.so.0
libOpenGL.so.0
libdrm.so.2
libgbm.so.1
libasound.so.2
libpulse.so.0
libstdc++.so.6
libgcc_s.so.1
libc.so.6
libm.so.6
libdl.so.2
libpthread.so.0
librt.so.1
libresolv.so.2
LIST
copy_deps() {
  ldd "$1" | awk '/=> \//{print $1, $3}' | while read -r name path; do
    if ! grep -qxF "$name" /tmp/system_libs && [ ! -e "$app/usr/lib/$name" ]; then
      cp -L "$path" "$app/usr/lib/$name"
      copy_deps "$path"
    fi
  done
}
cp -L "$(ldconfig -p | awk '/libmpv.so.1 /{print $NF; exit}')" "$app/usr/lib/libmpv.so.1"
copy_deps "$app/usr/lib/libmpv.so.1"
copy_deps "$bundle/spike"
ls "$app/usr/lib" | wc -l
du -sh "$app"

cd /work
curl -fsSL -o /tmp/appimagetool https://github.com/AppImage/appimagetool/releases/download/1.9.0/appimagetool-x86_64.AppImage
chmod +x /tmp/appimagetool
APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 /tmp/appimagetool --no-appstream "$app" /out/Spike-x86_64.AppImage 2>&1 | tail -2
ls -la /out
