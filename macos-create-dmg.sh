#!/bin/sh
rm -f StudentObservations-Installer.dmg
rm -rf build/macos/Release
mkdir -p build/macos/Release
cp -r "build/macos/Build/Products/Release/Student Observations.app" build/macos/Release/
create-dmg \
  --volname "Student Observations Installer" \
  --volicon "logo.icns" \
  --window-pos 200 120 \
  --window-size 800 529 \
  --icon-size 130 \
  --text-size 14 \
  --icon "Student Observations.app" 260 250 \
  --hide-extension "Student Observations.app" \
  --app-drop-link 540 250 \
  --hdiutil-quiet \
  "StudentObservations-Installer.dmg" \
  "build/macos/Release/"