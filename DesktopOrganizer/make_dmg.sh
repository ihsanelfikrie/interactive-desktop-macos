#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "🔨 Membangun Custom Desktop Mac versi Release..."
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

# Buat panduan instalasi di dalam DMG
cat << 'EOF' > "$STAGING_DIR/CARA_INSTALL_PANDUAN.txt"
=====================================================
🏠 CARA INSTALASI & MENJALANKAN CUSTOM DESKTOP MAC
=====================================================

1. LANGKAH INSTALASI:
   - Tarik (drag) ikon "Custom Desktop Mac.app" ke shortcut folder "Applications".
   - Tunggu hingga proses penyalinan selesai.
   - Klik kanan pada disk image ini di sidebar/desktop, lalu pilih "Eject".

2. CARA MEMBUKA (JIKA MUNCUL PERINGATAN APPLE GATEKEEPER):
   Karena aplikasi ini didistribusikan secara mandiri di luar Mac App Store
   (100% gratis & open-source), macOS secara default akan menampilkan
   peringatan "Pengembang Tidak Terverifikasi" (Unidentified Developer).

   PILIH SALAH SATU CARA MUDAH DI BAWAH INI:

   ▶ CARA 1 (Paling Cepat / 3 Detik):
     1. Buka folder /Applications di Finder Anda.
     2. Tahan tombol CONTROL di keyboard, lalu KLIK KANAN pada Custom Desktop Mac.
     3. Pilih menu "Open" (Buka).
     4. Pada dialog konfirmasi yang muncul, klik tombol "Open". Selesai!

   ▶ CARA 2 (Lewat Pengaturan Sistem):
     1. Buka System Settings (Pengaturan Sistem) di Mac.
     2. Masuk ke menu "Privacy & Security" (Privasi & Keamanan).
     3. Gulir ke bawah ke bagian "Security".
     4. Klik tombol "Open Anyway" (Tetap Buka), lalu masukkan password/Touch ID Anda.

   ▶ CARA 3 (Via Terminal jika muncul pesan "App is damaged"):
     Buka aplikasi Terminal, lalu ketik/paste perintah berikut dan tekan Enter:
     xattr -cr "/Applications/Custom Desktop Mac.app"

=====================================================
Aplikasi ini 100% aman, offline, dan tidak mengirim data ke luar.
Dibuat oleh Ihsan Elfikrie & SANS Studio (ihsanelfikrie.my.id)
=====================================================
EOF

echo "📦 Mengemas file DMG dengan hdiutil native macOS..."
hdiutil create -volname "Custom Desktop Mac" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

rm -rf "$STAGING_DIR"

echo "🎉 BERHASIL! File DMG siap di: $DMG_NAME"
