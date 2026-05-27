#!/bin/bash
set -e

VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')

rm -f "releases/D-METER-v${VERSION}.dmg"

echo "Building D-METER v$VERSION..."

flutter build macos --release

create-dmg \
  --volname "D-METER" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 120 \
  --icon "d_meter.app" 200 190 \
  --hide-extension "d_meter.app" \
  --app-drop-link 600 185 \
  "releases/D-METER-v${VERSION}.dmg" \
  "build/macos/Build/Products/Release/"

echo "Done: releases/D-METER-v${VERSION}.dmg"
