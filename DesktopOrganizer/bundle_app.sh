#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "🔨 Membangun DesktopOrganizer untuk macOS Apple Silicon (M1)..."
swift build -c release

APP_NAME="DesktopOrganizer.app"
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

# Buat Info.plist
cat << 'EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>DesktopOrganizer</string>
    <key>CFBundleIdentifier</key>
    <string>com.customdesktop.DesktopOrganizer</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Desktop Organizer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Berhasil! Aplikasi tersedia di: $APP_DIR"
