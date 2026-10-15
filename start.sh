#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
killall "Custom Desktop Mac" 2>/dev/null || true
killall DesktopOrganizer 2>/dev/null || true
sleep 0.5
if [ ! -d "$DIR/Custom Desktop Mac.app" ]; then
    echo "📦 Aplikasi belum dibundle. Mengompilasi dan mengemas otomatis..."
    "$DIR/DesktopOrganizer/bundle_app.sh"
fi
open "$DIR/Custom Desktop Mac.app"
echo "✨ Custom Desktop Mac berhasil dijalankan!"
