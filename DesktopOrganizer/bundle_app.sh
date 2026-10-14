#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "🔨 Membangun DesktopOrganizer untuk macOS Apple Silicon (M1)..."
swift build -c release

APP_NAME="Custom Desktop Mac.app"
APP_DIR="../$APP_NAME"
BUILD_BIN=".build/out/Products/Release/DesktopOrganizer"

if [ ! -f "$BUILD_BIN" ]; then
    BUILD_BIN=".build/out/Products/Debug/DesktopOrganizer"
fi

echo "📦 Mengemas menjadi $APP_NAME..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BUILD_BIN" "$APP_DIR/Contents/MacOS/DesktopOrganizer"
chmod +x "$APP_DIR/Contents/MacOS/DesktopOrganizer"

# Salin Resource Bundle SPM & Aset Resmi
BUNDLE_DIR="$(dirname "$BUILD_BIN")/DesktopOrganizer_DesktopOrganizer.bundle"
if [ -d "$BUNDLE_DIR" ]; then
    cp -R "$BUNDLE_DIR" "$APP_DIR/Contents/Resources/"
fi
cp Sources/DesktopOrganizer/Resources/AppIcon.icns "$APP_DIR/Contents/Resources/"
cp Sources/DesktopOrganizer/Resources/*.png "$APP_DIR/Contents/Resources/"

# Buat Info.plist resmi
cat << 'EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.ihsanelfikrie.customdesktopmac</string>
    <key>CFBundleName</key><string>Custom Desktop Mac</string>
    <key>CFBundleDisplayName</key><string>Custom Desktop Mac</string>
    <key>CFBundleExecutable</key><string>DesktopOrganizer</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSHumanReadableCopyright</key><string>Copyright © 2026 Ihsan Elfikrie. All rights reserved.</string>
    <key>CFBundleGetInfoString</key><string>Custom Desktop Mac 1.0, © 2026 Ihsan Elfikrie</string>
    <key>NSAppleEventsUsageDescription</key><string>Custom Desktop Mac menggeser ikon desktop yang tertutup lemari, pigura, atau karpet ke tempat kosong, dan mengontrol musik di Spotify.</string>
</dict>
</plist>
EOF

echo "✅ Berhasil! Aplikasi tersedia di: $APP_DIR"
