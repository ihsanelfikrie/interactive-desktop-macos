#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
killall DesktopOrganizer 2>/dev/null || true
sleep 0.5
open "$DIR/Custom Desktop Mac.app"
echo "✨ Custom Desktop Mac berhasil dijalankan!"
