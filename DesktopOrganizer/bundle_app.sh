#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "🔨 Membangun Custom Desktop Mac untuk macOS Apple Silicon (M1)..."
swift build -c release

APP_NAME="Custom Desktop Mac.app"
APP_DIR="../$APP_NAME"
BUILD_BIN=".build/release/DesktopOrganizer"

if [ ! -f "$BUILD_BIN" ]; then
    BUILD_BIN=".build/out/Products/Release/DesktopOrganizer"
fi
if [ ! -f "$BUILD_BIN" ]; then
    BUILD_BIN=".build/debug/DesktopOrganizer"
fi

echo "📦 Mengemas menjadi $APP_NAME..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BUILD_BIN" "$APP_DIR/Contents/MacOS/Custom Desktop Mac"
chmod +x "$APP_DIR/Contents/MacOS/Custom Desktop Mac"
strip -u -r "$APP_DIR/Contents/MacOS/Custom Desktop Mac" 2>/dev/null || true

# Salin Resource Bundle SPM & Aset Resmi
BUNDLE_DIR="$(dirname "$BUILD_BIN")/DesktopOrganizer_DesktopOrganizer.bundle"
if [ -d "$BUNDLE_DIR" ]; then
    cp -R "$BUNDLE_DIR" "$APP_DIR/Contents/Resources/"
fi
cp Sources/DesktopOrganizer/Resources/AppIcon.icns "$APP_DIR/Contents/Resources/"
cp Sources/DesktopOrganizer/Resources/*.png "$APP_DIR/Contents/Resources/" 2>/dev/null || true
cp Sources/DesktopOrganizer/Resources/*.jpg "$APP_DIR/Contents/Resources/" 2>/dev/null || true

# Buat Info.plist resmi
cat << 'EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.ihsanelfikrie.customdesktopmac</string>
    <key>CFBundleName</key><string>Custom Desktop Mac</string>
    <key>CFBundleDisplayName</key><string>Custom Desktop Mac</string>
    <key>CFBundleExecutable</key><string>Custom Desktop Mac</string>
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
    <key>NSDocumentsFolderUsageDescription</key><string>Custom Desktop Mac menyimpan buku, kardus arsip, dan album foto di Documents/DesktopRoom.</string>
    <key>NSDesktopFolderUsageDescription</key><string>Custom Desktop Mac mengembalikan file dan merapikan ikon desktop Anda.</string>
</dict>
</plist>
EOF

echo "✅ Berhasil! Aplikasi tersedia di: $APP_DIR"
