#!/usr/bin/env bash
# usage : run_tv.sh <nom> <VO> <HWDEC> <NOSTOP>
# flutter, adb and the Android SDK are taken from PATH and ANDROID_HOME; screenshots go to $SHOTS (default: current folder).
ADB=${ADB:-adb}
S="${SHOTS:-.}"
U=http://10.0.2.2:18099/live/h264.ts,http://10.0.2.2:18099/live/hevc.ts,http://10.0.2.2:18099/live/mpeg2i.ts,https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
flutter build apk --release --target-platform android-x64 --dart-define=URLS=$U --dart-define=VO=$2 --dart-define=HWDEC=$3 --dart-define=NOSTOP=$4 2>&1 | tail -1
"$ADB" uninstall app.spike.spike >/dev/null 2>&1
"$ADB" install build/app/outputs/flutter-apk/app-release.apk 2>&1 | tr -d "" | grep -E "Success|Failure" | grep -q Success || { echo "INSTALL ECHEC"; exit 1; }
"$ADB" logcat -c; sleep 1
MSYS_NO_PATHCONV=1 "$ADB" shell am start -n app.spike.spike/.MainActivity >/dev/null
sleep 11; MSYS_NO_PATHCONV=1 "$ADB" exec-out screencap -p > "$S/tv_$1.png"
for i in $(seq 1 70); do sleep 2; "$ADB" logcat -d -s flutter 2>/dev/null | grep -q '"t":"done"\|"t":"fatal"' && break; done
echo "=== $1 VO=$2 HWDEC=$3 NOSTOP=$4"
"$ADB" logcat -d -s flutter 2>/dev/null | grep SPIKE | sed 's/.*SPIKE //' | grep -E '"t":"(play|mpv|fatal|done)"' | sed -E 's/,"mpv":"[^"]*","ffmpeg":"[^"]*"//' | cut -c1-240 | head -30
