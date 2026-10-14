#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "🔨 Membangun DesktopOrganizer versi Release..."
./bundle_app.sh

APP_BUNDLE="../Custom Desktop Mac.app"
DMG_NAME="../Custom-Desktop-Mac-Installer.dmg"
STAGING_DIR="/tmp/CustomDesktopMac_DMG_Staging"

echo "💿 Menyiapkan disk image installer..."
rm -rf "$STAGING_DIR" "$DMG_NAME"
mkdir -p "$STAGING_DIR"

# Copy app bundle ke staging
cp -R "$APP_BUNDLE" "$STAGING_DIR/Custom Desktop Mac.app"

# Buat shortcut symlink ke folder /Applications
ln -s /Applications "$STAGING_DIR/Applications"

echo "📦 Mengemas file DMG dengan hdiutil native macOS..."
hdiutil create -volname "Custom Desktop Mac" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

rm -rf "$STAGING_DIR"

echo "🎉 BERHASIL! File DMG siap di: $DMG_NAME"
