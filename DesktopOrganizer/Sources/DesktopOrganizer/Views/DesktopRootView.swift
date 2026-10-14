import SwiftUI
import AppKit

public struct DesktopRootView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    @ObservedObject var spotify = SpotifyService.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack(alignment: .topLeading) {
                // 1. Pixel Art Room Background (100% full screen)
                ThemeBackgroundView(theme: appState.currentTheme, isNightMode: !appState.lampOn)
                    .frame(width: w, height: h)
                
                // 2. Interactive Hot Zones (Mapped 1:1 onto the illustrated furniture)
                
                // Bookshelf (Left Wall: 4 shelves of books/boxes & sliding ladder)
                BookshelfView(theme: appState.currentTheme)
                    .frame(width: w * 0.23, height: h * 0.64)
                    .position(x: w * 0.145, y: h * 0.430)
                
                // Corkboard Notes (Center Wall: Sticky notes & Add Memo inside wooden frame)
                CorkboardView()
                    .frame(width: w * 0.370, height: h * 0.293)
                    .position(x: w * 0.549, y: h * 0.236)
                
                // Live Analog Wall Clock (Hour, minute, and second hands moving in real time)
                AnalogWallClockView(currentDate: appState.currentDate)
                    .frame(width: w * 0.080, height: w * 0.080)
                    .position(x: w * 0.7025, y: h * 0.2010)
                
                // Wall Calendar (Click to open Calendar.app)
                Button(action: {
                    if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                        NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
                    }
                }) {
                    Color.clear
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: w * 0.055, height: h * 0.080)
                .position(x: w * 0.7020, y: h * 0.3200)
                .help("Kalender: Klik untuk membuka aplikasi Calendar macOS")
                
                // Desk Lamp Hot Zone (Over the illustrated green Banker's Lamp)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        appState.lampOn.toggle()
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                        
                        if appState.lampOn {
                            Circle()
                                .fill(Color.yellow.opacity(0.15))
                                .frame(width: 45, height: 45)
                                .blur(radius: 8)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help("Lampu Meja: Klik untuk menyalakan/mematikan lampu")
                .frame(width: w * 0.075, height: h * 0.110)
                .position(x: w * 0.472, y: h * 0.552)
                
                // Desk Radio (Official vintage radio sitting on desk surface)
                VintageRadioView()
                    .position(x: w * 0.628, y: h * 0.490)
                
                // Desk Photo Frame (Framed photo resting on desk surface)
                DeskPhotoFrameView()
                    .frame(width: w * 0.055, height: h * 0.070)
                    .position(x: w * 0.566, y: h * 0.485)
                
                // Photo Gallery (Right Wall: 6 photo frames matching official design)
                PhotoGalleryView()
                    .frame(width: w * 0.170, height: h * 0.380)
                    .position(x: w * 0.865, y: h * 0.320)
                
                // Woven Wastebasket / Trash Can (Floor beside desk)
                BasketTrashHotZoneView()
                    .frame(width: w * 0.065, height: h * 0.115)
                    .position(x: w * 0.683, y: h * 0.732)
                
                // Floor Rug / Magic Carpet (Floor)
                MagicCarpetView(theme: appState.currentTheme)
                    .frame(width: w * 0.280, height: h * 0.120)
                    .position(x: w * 0.650, y: h * 0.810)
                
                // 3. Ambient Night Dimmer when Lamp is Off
                if !appState.lampOn {
                    Color.black.opacity(0.65)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(20)
                }
                

                // 5. Modals (Bookshelf Drawer, Theme Picker, Help Guide)
                if appState.showBookshelfDrawer {
                    ModalBackdrop(isPresented: $appState.showBookshelfDrawer) {
                        BookshelfDrawerView(isPresented: $appState.showBookshelfDrawer)
                    }
                    .zIndex(40)
                }
                
                if appState.showThemePicker {
                    ModalBackdrop(isPresented: $appState.showThemePicker) {
                        ThemePickerView(
                            currentTheme: Binding(
                                get: { appState.currentTheme },
                                set: { appState.currentTheme = $0 }
                            ),
                            isPresented: $appState.showThemePicker
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
                    }
                    .zIndex(40)
                }
                
                if appState.showSpotifyPopup {
                    ModalBackdrop(isPresented: $appState.showSpotifyPopup) {
                        SpotifyMiniPlayerView(isPresented: $appState.showSpotifyPopup)
                    }
                    .zIndex(40)
                }
            }
        }
    }
}

// MARK: - Desk Photo Frame Hot Zone (Over the illustrated desk picture frame)
struct DeskPhotoFrameView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let slotIndex: Int = 6
    
    var photoURL: URL? {
        storage.photoSlots[slotIndex]
    }
    
    var cachedImage: NSImage? {
        storage.cachedPhotos[slotIndex]
    }
    
    var body: some View {
        ZStack {
            if let image = cachedImage {
                ZStack(alignment: .topTrailing) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(3)
                        .onTapGesture {
                            if let url = photoURL {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .help("Klik untuk melihat foto di Preview")
                    
                    Button(action: {
                        storage.removePhoto(slotIndex: slotIndex)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(SANSColors.pink)
                            .background(Circle().fill(Color.white))
                    }
                    .buttonStyle(.plain)
                    .padding(2)
                    .help("Hapus foto dari meja")
                }
            } else {
                Button(action: {
                    storage.pickPhoto(forSlot: slotIndex)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.85))
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(SANSColors.border, lineWidth: 1))
                            .shadow(color: .black.opacity(0.12), radius: 2)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 11))
                                .foregroundColor(SANSColors.primaryBlue)
                            Text("+ Foto")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(SANSColors.dark)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help("Klik atau drag foto ke sini untuk memajangnya di meja")
            }
        }
        .overlay(
            Group {
                if appState.targetedPhotoSlot == slotIndex {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(SANSColors.lime, lineWidth: 2)
                }
            }
        )
        .onDrop(of: [.fileURL], isTargeted: Binding(
            get: { appState.targetedPhotoSlot == slotIndex },
            set: { targeted in appState.targetedPhotoSlot = targeted ? slotIndex : nil }
        )) { providers in
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    storage.assignPhoto(sourceURL: url, slotIndex: slotIndex)
                }
            }
            return true
        }
    }
}

// MARK: - Woven Wastebasket Hot Zone (Directly over the illustrated trash basket)
struct BasketTrashHotZoneView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        Button(action: {
            if let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first {
                NSWorkspace.shared.open(trashURL)
            }
        }) {
            ZStack {
                Rectangle()
                    .fill(appState.isTrashTargeted ? Color.red.opacity(0.25) : Color.clear)
                    .contentShape(Rectangle())
                
                if appState.isTrashTargeted {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.red, lineWidth: 2)
                        .overlay(
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .help("Tempat Sampah: Seret file ke sini untuk membuangnya, atau klik untuk buka Trash")
        .onDrop(of: [.fileURL], isTargeted: Binding(
            get: { appState.isTrashTargeted },
            set: { appState.isTrashTargeted = $0 }
        )) { providers in
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    _ = storage.moveToTrash(url: url)
                }
            }
            return true
        }
    }
}

// MARK: - Reusable In-App Modal Backdrop
struct ModalBackdrop<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            
            content()
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }
}

// MARK: - Control Button in Top Bar
struct ControlButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.18))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Help Guide Modal
struct HelpGuideModalView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Panduan Fitur Desktop Organizer")
                    .font(.title2.bold())
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GuideRow(icon: "books.vertical.fill", color: .brown, title: "Rak Buku File & Folder", desc: "Seret file/folder dari desktop ke rak buku untuk menyimpannya. Klik dua kali untuk membuka file, atau klik kanan untuk melihat opsi.")
                    GuideRow(icon: "oval.inset.filled", color: .red, title: "Magic Carpet (Sembunyikan File)", desc: "Seret file ke atas karpet untuk menyembunyikannya. Klik karpet untuk mengangkatnya dan melihat/mengembalikan file.")
                    GuideRow(icon: "note.text", color: .orange, title: "Memo Board (Catatan Dinding)", desc: "Klik tombol 'Memo' di pojok papan gabus untuk membuat sticky note baru. Tulis to-do list dan centang saat selesai.")
                    GuideRow(icon: "photo.fill", color: .purple, title: "Bingkai Foto di Meja", desc: "Seret foto ke bingkai di atas meja atau klik untuk memajang foto favorit kamu.")
                    GuideRow(icon: "lightbulb.fill", color: .yellow, title: "Lampu Meja (Mode Malam)", desc: "Klik kap lampu di atas meja untuk mematikan/menyalakan lampu dan meredupkan ruangan.")
                    GuideRow(icon: "radio.fill", color: .green, title: "Radio Spotify", desc: "Klik radio di atas meja untuk memutar/menjeda lagu di Spotify langsung dari desktop.")
                    GuideRow(icon: "trash.fill", color: .gray, title: "Tempat Sampah", desc: "Seret file apa pun ke keranjang sampah di lantai untuk membuangnya langsung ke Trash macOS.")
                }
                .padding(.vertical, 8)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Tutup") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 580, height: 460)
    }
}

struct GuideRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}
