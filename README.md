# 🏠 Custom Desktop Mac

Aplikasi ruang desktop interaktif native untuk macOS yang dibuat 100% menggunakan **SwiftUI & AppKit**. Aplikasi ini mentransformasikan tampilan desktop Mac Anda menjadi ruangan kerja digital berilustrasi yang interaktif, dinamis, dan terorganisir rapi.

---

## 💻 Daftar Mac yang Kompatibel (Compatibility List)

Aplikasi ini mendukung arsitektur **Apple Silicon (ARM64)** dan **Intel (x86_64)** dengan sistem operasi **macOS 13.0 Ventura atau yang lebih baru**.

### 1. Apple Silicon Mac (Sangat Direkomendasikan ⚡)
Didesain dan dioptimalkan secara native untuk arsitektur Apple Silicon dengan efisiensi daya maksimal dan pemakaian CPU idle mendekati 0%:
- **MacBook Air**:
  - MacBook Air M1 (2020)
  - MacBook Air M2 (13" & 15", 2022 – 2023)
  - MacBook Air M3 (13" & 15", 2024 atau lebih baru)
- **MacBook Pro**:
  - MacBook Pro 13" (M1 2020, M2 2022)
  - MacBook Pro 14" & 16" (M1 Pro/Max 2021, M2 Pro/Max 2023, M3/M3 Pro/Max 2023, M4 2024 atau lebih baru)
- **Mac mini**: Mac mini M1 (2020), Mac mini M2 / M2 Pro (2023 atau lebih baru)
- **iMac**: iMac 24" (M1 2021, M3 2023 atau lebih baru)
- **Mac Studio**: Mac Studio M1 / M2 Max & Ultra (2022 – 2023 atau lebih baru)
- **Mac Pro**: Mac Pro M2 Ultra (2023 atau lebih baru)

### 2. Intel-based Mac (macOS 13.0 Ventura+)
Dapat berjalan pada seluruh komputer Mac berbasis prosesor Intel yang kompatibel dengan macOS Ventura atau yang diperbarui menggunakan OpenCore Legacy Patcher:
- MacBook Pro (Model 2017 – 2020 dengan Port Thunderbolt 3)
- MacBook Air (Model Retina 2018 – 2020)
- MacBook 12" Retina (Model 2017)
- Mac mini (Model 2018 ke atas)
- iMac (Model 21.5" & 27" Retina 4K/5K 2017 ke atas)
- iMac Pro (2017)
- Mac Pro (2019)

### 3. Persyaratan Sistem Minimal
- **Sistem Operasi**: macOS 13.0 (Ventura), macOS 14.0 (Sonoma), macOS 15.0 (Sequoia), atau versi lebih baru.
- **Resolusi Layar**: Dioptimalkan untuk layar Retina MacBook (13", 14", 15", 16") serta monitor eksternal Full HD, 2K, 4K, dan 5K.
- **Ruang Penyimpanan**: ~25 MB ruang kosong.

---

## 📥 Panduan Instalasi di MacBook (Installation Guide)

Tersedia beberapa cara mudah untuk menginstal dan menjalankan Custom Desktop Mac:

### 🌟 Cara 1: Menggunakan Installer DMG (Paling Mudah & Disarankan)

1. **Buka File Installer**:
   - Double-click file `Custom-Desktop-Mac-Installer.dmg` yang tersedia di direktori proyek atau dari rilis.
2. **Install ke Applications**:
   - Jendela installer akan muncul. Cukup **drag (tarik) ikon `Custom Desktop Mac` ke shortcut folder `Applications`**.
3. **Eject Disk Image**:
   - Klik kanan pada ikon drive `Custom Desktop Mac` di desktop atau sidebar Finder, lalu pilih **Eject**.
4. **Buka Aplikasi**:
   - Buka folder **Applications** (atau melalui **Launchpad** / pencarian **Spotlight** dengan menekan `Cmd + Space` dan ketik `Custom Desktop Mac`).

#### ⚠️ Cara Mengatasi Peringatan Keamanan macOS (Gatekeeper)
Karena aplikasi ini dibuat mandiri (di luar Mac App Store), macOS mungkin menampilkan pesan:  
*“Custom Desktop Mac cannot be opened because it is from an unidentified developer”* atau *“tidak dapat dibuka karena pengembang tidak terverifikasi”*.

Pilih salah satu cara cepat berikut untuk mengizinkannya:
- **Metode A (Klik Kanan - Paling Cepat)**:
  1. Buka folder `/Applications` di Finder.
  2. Klik kanan (atau tahan tombol `Control` lalu klik) pada aplikasi **Custom Desktop Mac**.
  3. Pilih **Open** (Buka) dari menu konteks.
  4. Klik tombol **Open** pada jendela konfirmasi yang muncul. macOS akan mengingat izin ini secara permanen.
- **Metode B (Lewat System Settings)**:
  1. Buka menu Apple () di pojok kiri atas > **System Settings** (*Pengaturan Sistem*).
  2. Masuk ke tab **Privacy & Security** (*Privasi & Keamanan*).
  3. Gulir ke bawah ke bagian **Security** (*Keamanan*). Anda akan melihat teks *“Custom Desktop Mac was blocked...”*.
  4. Klik tombol **Open Anyway** (*Tetap Buka*), lalu masukkan Touch ID atau password Mac Anda.
- **Metode C (Via Terminal - 1 Perintah Langsung Beres)**:
  Jalankan perintah berikut di Terminal untuk menghapus atribut karantina Gatekeeper:
  ```bash
  xattr -cr "/Applications/Custom Desktop Mac.app"
  ```

---

### 🚀 Cara 2: Menjalankan Langsung via Script Portable

Jika Anda tidak ingin menginstalnya ke folder `/Applications`, aplikasi dapat langsung dijalankan dari folder repository:
1. Buka Terminal pada root direktori project ini.
2. Jalankan perintah:
   ```bash
   ./start.sh
   ```
   *(Script ini otomatis mengecek kelengkapan bundle, mengompilasi jika belum ada, dan langsung membuka aplikasi).*

---

### 🛠️ Cara 3: Membangun Sendiri dari Source Code (Build from Source)

Jika Anda seorang pengembang dan ingin memodifikasi atau mengompilasi sendiri dari kode sumber:

1. **Pastikan Swift & Xcode Command Line Tools Terpasang**:
   ```bash
   xcode-select --install
   ```
2. **Kompilasi dan Bundle Aplikasi**:
   Cukup jalankan script build pada root direktori:
   ```bash
   ./build.sh
   ```
   *Atau langsung melalui Swift Package Manager:*
   ```bash
   cd DesktopOrganizer
   ./bundle_app.sh
   ```
3. **Membuat Installer DMG Baru**:
   ```bash
   cd DesktopOrganizer
   ./make_dmg.sh
   ```
   File `Custom-Desktop-Mac-Installer.dmg` baru akan terbuat secara otomatis di root folder.

---

## 🔒 Pengaturan Izin Sistem (Permissions)

Untuk pengalaman interaktif terbaik, beberapa fitur opsional memanfaatkan API native macOS:

| Izin Sistem | Lokasi Pengaturan | Fungsi dalam Aplikasi |
|---|---|---|
| **Aksesibilitas (Accessibility)** | *System Settings > Privacy & Security > Accessibility* | Mengizinkan penataan otomatis posisi ikon desktop Finder agar tidak bertumpuk dengan rak buku, karpet, atau lemari. |
| **Otomatisasi / AppleEvents** | *System Settings > Privacy & Security > Automation* | Mengintegrasikan mini player di atas meja dengan aplikasi Spotify (membaca judul lagu, artis, serta kontrol Play/Pause). |
| **Folder Dokumen** | *System Settings > Privacy & Security > Files and Folders* | Menyimpan berkas catatan sticky notes, foto album, dan dokumen yang Anda simpan di rak. |

---

## ✨ Fitur & Interaksi Elemen Ruangan

| Elemen Ruangan | Interaksi & Fungsi |
|---|---|
| 🕌 **Kaligrafi Arab (Bismillah)** | Tulisan kaligrafi Arab Thuluth (*Bismillahir-Rahmanir-Rahim*) terpasang anggun di bagian atas papan memo dengan zona eksklusif yang terlindungi dari tumpukan sticky notes. |
| 📝 **Papan Memo (Corkboard)** | Buat to-do list dengan sticky notes berwarna pastel. Klik tombol `+ Memo`, seret memo ke mana saja, edit isi catatan, dan centang tugas yang telah selesai. |
| 🖥️ **Meja Kerja & Komputer iMac** | Meja belajar putih dengan iMac, keyboard, dan mouse yang tertata rapi di atas bidang kedalaman meja 2.5D berbayangan nyata. |
| 🏆 **Plakat Penghargaan Akrilik** | Dua plakat akrilik meja (Tegoer Sapa & SANS Studio). Klik plakat untuk membuka detail popover dan mengakses file logo vektor asli. |
| 🎸 **Gitar Akustik & Elektrik** | Gitar akustik dreadnought proporsional di kiri dan gitar elektrik Stratocaster hitam elegan di kanan. Klik popover untuk opsi instrumen. |
| 💡 **Lampu Meja (Mode Malam)** | Klik lampu belajar untuk mematikan/menyalakan lampu. Saat dimatikan, ruangan beralih ke mode malam (*cozy ambient night mode*). |
| 📻 **Speaker Marshall & Spotify** | Terkoneksi realtime dengan pemutar Spotify: kontrol musik (⏮ Play/Pause ⏭), melihat cover dan judul lagu, serta animasi equalizer floating notes. |
| 📚 **Rak Buku Interaktif** | Drag & drop folder atau file ke rak buku di dinding kiri. Klik rak untuk membuka drawer buku bersampul judul file Anda. |
| 🪄 **Magic Carpet (Karpet Ajaib)** | Drag & drop file atau folder ke karpet permadani untuk menyembunyikannya. Klik karpet untuk membuka lipatan dan melihat file rahasia di bawahnya. |
| 🖼️ **Galeri Foto Dinding** | Drag & drop gambar (PNG/JPG/HEIC) dari Finder ke bingkai foto. Klik foto untuk melihat ukuran penuh atau mengganti foto kenangan. |
| ⏰ **Jam & Kalender Dinding** | Jarum jam berputar realtime sesuai waktu Mac Anda. Menampilkan potret resmi kenegaraan dan tanggal kalender aktif. |
| 🌿 **Tanaman Hias & Sandal** | Tanaman hias hijau beranimasi ayunan daun alami serta sepasang sandal santai di samping karpet. |
| 🗑️ **Tempat Sampah** | Drag file atau folder yang tidak diinginkan ke tong sampah di samping meja untuk langsung memindahkannya ke macOS Trash dengan efek suara. |
| 🍏 **macOS Status Bar Menu** | Ikon rumah praktis di menu bar macOS (kanan atas) untuk beralih mode, menyembunyikan ikon desktop asli, membuka preferensi, atau menutup aplikasi. |

---

## 📂 Lokasi Penyimpanan Data Lokal

Aplikasi tidak mengirimkan data apa pun ke server luar (100% offline & privat). Semua data disimpan di direktori pengguna:
```
~/Documents/DesktopRoom/
├── Album/       # Foto-foto yang dipajang di galeri dinding
├── Rak/         # File dan folder yang dimasukkan ke dalam rak buku
├── Karpet/      # Dokumen yang disembunyikan di bawah karpet
└── notes.json   # Data teks sticky notes dan daftar tugas
```

---

## 🗂️ Struktur Direktori Proyek

```
Custom Desktop Mac/
├── .agents/                        # Konfigurasi custom agent & skill
├── Assets/                         # Aset logo vektor resmi (SVG)
│   └── Logos/
├── DesktopOrganizer/               # Source code Swift Package Manager (SPM)
│   ├── Package.swift               # Konfigurasi target & dependency SPM
│   ├── bundle_app.sh               # Script bundling aplikasi macOS (.app)
│   ├── make_dmg.sh                 # Script pembuat disk image (.dmg)
│   └── Sources/DesktopOrganizer/
│       ├── Models/                 # State management, Spotify service, Storage
│       ├── Views/                  # Komponen visual SwiftUI & animasi ruangan
│       ├── Window/                 # Manajemen window level desktop & menu bar
│       └── Resources/              # Ikon aplikasi, wallpaper, suara & tekstur
├── Custom Desktop Mac.app          # Bundle aplikasi siap jalan
├── Custom-Desktop-Mac-Installer.dmg# File installer DMG untuk distribusi
├── build.sh                        # Script 1-langkah untuk build & bundle dari root
├── start.sh                        # Script peluncur cepat aplikasi
├── LICENSE.txt                     # Lisensi perangkat lunak
└── README.md                       # Dokumentasi resmi dan panduan instalasi
```

---

## 🙏 Kredit & Inspirasi (Credits & Inspiration)

- **Konsep Kreatif**: Konsep visual ruangan desktop interaktif terinspirasi dari karya konsep kreatif oleh **Chelsy Lifardy** ([@chelsylifardy](https://www.instagram.com/chelsylifardy/)).
- **Rekayasa & Pengembangan Perangkat Lunak**: Seluruh kode sumber dibangun dan direkayasa ulang secara mandiri dari awal (*clean-room engineering*) sebagai aplikasi native macOS 100% menggunakan **SwiftUI, AppKit, dan Metal** dengan efisiensi daya tinggi (0% idle CPU). Ditambah dengan integrasi Spotify lokal, instrumen musik prosedural (Martin D-28 & Fender Stratocaster), mode rahasia kebakaran ruangan, jam analog realtime, kaligrafi Bismillah, serta plakat akrilik oleh **Ihsan Elfikrie & SANS Studio**.

---

## 📄 Lisensi & Hak Cipta

Copyright © 2026 **Ihsan Elfikrie & SANS Studio**. All rights reserved.  
Lihat berkas [LICENSE.txt](file:///Users/macbook/Custom%20Desktop%20Mac/LICENSE.txt) untuk ketentuan penggunaan.
