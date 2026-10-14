# 🏠 macOS Custom Desktop Organizer

Aplikasi Desktop Organizer interaktif native untuk macOS (Apple Silicon M1/M2/M3 & Intel), dibuat dengan **SwiftUI & AppKit**. Aplikasi ini mengubah tampilan desktop menjadi ruangan kerja berilustrasi yang interaktif dan rapi seperti pada video referensi.

---

## 🚀 Cara Menjalankan

Aplikasi sudah dikompilasi ke format native `.app`:
- **Double click**: [DesktopOrganizer.app](file:///Users/macbook/Custom%20Desktop%20Mac/DesktopOrganizer.app)
- **Atau jalankan via Terminal**:
  ```bash
  ./start.sh
  ```

---

## ✨ Fitur & Interaksi yang Tersedia

| Elemen Ruangan | Interaksi & Fungsi |
|---|---|
| 🖼️ **Bingkai Foto Dinding** | Drag & drop gambar (PNG/JPG/HEIC) dari Finder ke bingkai. Klik foto untuk melihat ukuran penuh. Hover untuk menghapus/mengganti. |
| 📚 **Rak Buku (Bookshelf)** | Drag & drop folder atau file ke rak buku sebelah kiri. Klik rak buku untuk membuka **Drawer Rak Buku** yang menampilkan buku-buku bersampul judul file/folder kamu. Klik buku untuk membukanya di Finder. |
| 🪄 **Magic Carpet (Karpet Ajaib)** | Drag & drop file/folder ke karpet merah oval untuk menyembunyikannya. Klik karpet untuk animasi **mengangkat karpet** dan melihat file rahasia di bawahnya. |
| 📝 **Papan Memo (Corkboard)** | Catat to-do list harian dengan sticky notes berwarna pastel. Tekan tombol `+` untuk membuat note baru, drag note ke mana saja di papan, edit teks, dan centang tugas selesai. |
| ⏰ **Jam Dinding Analog** | Jarum jam, menit, dan detik berputar secara realtime sesuai jam MacBook kamu. |
| 📅 **Kalender Dinding** | Menampilkan nama bulan dan tanggal hari ini. Klik kalender untuk membuka aplikasi **Kalender macOS** (`Calendar.app`). |
| ✉️ **Amplop Surat di Meja** | Klik amplop surat dengan segel merah untuk membuka aplikasi **Mail macOS** (`Mail.app`). |
| 💡 **Lampu Meja (Mode Malam / Lights Out)** | Klik lampu meja belajar untuk menyalakan/mematikan lampu. Saat dimatikan, layar desktop meredup ke suasana malam (*cozy ambient night mode*). |
| 📻 **Radio Vintage & Spotify** | Klik radio antik di atas meja untuk membuka mini player Spotify: kontrol musik (⏮ Play/Pause ⏭), lihat judul lagu & penyanyi, dan tombol "Buka Spotify". |
| 🗑️ **Tempat Sampah** | Drag file atau folder ke tong sampah samping meja untuk membuangnya langsung ke Trash macOS dengan efek suara. |
| 🎨 **Ganti Tema Ruangan** | Pilihan 3 tema estetis: <br>1. **Perpustakaan Klasik (Library)**<br>2. **Kamar Kos-Kosan** (Lengkap dengan galon air dispenser, kipas angin, dan kasur lantai)<br>3. **Taman Santai (Outdoor)**. |
| 🍏 **macOS Menu Bar Item** | Ikon rumah kecil di menu bar pojok kanan atas layar Mac untuk akses cepat ke kontrol posisi jendela, sembunyikan ikon asli desktop, dan buka folder penyimpanan. |

---

## 📂 Lokasi Penyimpanan File

Semua data dan file tersimpan rapi di direktori lokal kamu:
`~/DesktopOrganizer/`
- `Photos/` — Foto-foto yang dipajang di bingkai dinding
- `Bookshelf/` — File dan folder yang disimpan di rak buku
- `MagicCarpet/` — File yang disembunyikan di bawah karpet
- `notes.json` — Catatan sticky notes dan to-do list kamu
