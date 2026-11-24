#!/usr/bin/env bash
# Compile l'AppImage dans un conteneur Ubuntu 22.04, comme le fait GitHub, sans machine Linux :
#   docker run --rm -v <dépôt>:/src:ro -v <dist>:/out ubuntu:22.04 bash /src/scripts/linux_docker.sh
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl git unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
  desktop-file-utils file libmpv-dev mpv >/dev/null
cd /opt
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.8-stable.tar.xz | tar xJ
git config --global --add safe.directory /opt/flutter
export PATH=/opt/flutter/bin:$PATH
flutter --disable-analytics >/dev/null 2>&1 || true
mkdir -p /work && cd /work
tar -C /src --exclude=build --exclude=.dart_tool --exclude=dist --exclude=.git -cf - . | tar xf -
cd app
flutter pub get | tail -1
flutter build linux --release 2>&1 | tail -3
cd ..
version=$(grep '^version:' app/pubspec.yaml | sed -E 's/version: *([0-9.]+).*/\1/')
bash packaging/linux/build-appimage.sh "$version" /out
