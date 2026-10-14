import SwiftUI
import AppKit

public struct DesktopRootView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Floor baseline elevated above the macOS Dock (~85pt)
            let dockPadding: CGFloat = 85
            
            ZStack(alignment: .bottom) {
                // 1. Procedural Room Background (Wall & Floor)
                ThemeBackgroundView(theme: appState.currentTheme, isNightMode: appState.isNightMode)
                    .frame(width: w, height: h)
                
                // 2. Wall-Mounted Elements (Corkboard, Clock/Calendar, Photo Gallery)
                VStack {
                    HStack(alignment: .top, spacing: 20) {
                        // Spacer for Left Bookshelf area
                        Spacer()
                            .frame(width: 210)
                        
                        // Center-Left: Corkboard (Memo Board)
                        CorkboardView()
                        
                        // Center-Right: Wall Clock & Wall Calendar
                        WallClockCalendarView()
                            .padding(.top, 20)
                        
                        // Right: Photo Gallery Frames
                        PhotoGalleryView()
                            .padding(.trailing, 24)
                    }
                    .padding(.top, 55)
                    
                    Spacer()
                }
                .frame(width: w, height: h)
                
                // 3. Furniture & Floor Elements (Elevated above macOS Dock)
                VStack(spacing: 0) {
                    Spacer()
                    
                    HStack(alignment: .bottom, spacing: 18) {
                        // LEFT: Bookshelf & Floor Plant
                        HStack(alignment: .bottom, spacing: 10) {
                            BookshelfView(theme: appState.currentTheme)
                            
                            HousePlantView()
                                .padding(.bottom, 6)
                        }
                        .padding(.leading, 32)
                        
                        Spacer()
                        
                        // Kos-Kosan Special Props: Standing Fan
                        if appState.currentTheme == .kosKosan {
                            StandingFanView()
                                .padding(.bottom, 6)
                        }
                        
                        // CENTER: Executive Desk
                        DeskView(
                            theme: appState.currentTheme,
                            isNightMode: Binding(
                                get: { appState.isNightMode },
                                set: { appState.isNightMode = $0 }
                            ),
                            showSpotifyPopup: Binding(
                                get: { appState.showSpotifyPopup },
                                set: { appState.showSpotifyPopup = $0 }
                            )
                        )
                        
                        // Kos-Kosan Special Props: Water Dispenser
                        if appState.currentTheme == .kosKosan {
                            WaterDispenserView()
                                .padding(.bottom, 6)
                        }
                        
                        // RIGHT: Trash Can
                        TrashCanView()
                            .padding(.bottom, 8)
                            .padding(.trailing, 40)
                        
                        Spacer()
                    }
                    .frame(width: w)
                    
                    // Center Carpet (Resting in front of Desk)
                    MagicCarpetView(theme: appState.currentTheme)
                        .padding(.top, -28)
                        .padding(.bottom, dockPadding)
                }
                .frame(width: w, height: h)
                
                // 4. Spotify Mini Player Card (Floating right above radio)
                if appState.showSpotifyPopup {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            SpotifyMiniPlayerView(isPresented: Binding(
                                get: { appState.showSpotifyPopup },
                                set: { appState.showSpotifyPopup = $0 }
                            ))
                            .offset(x: 160, y: -(dockPadding + 140))
                            Spacer()
                        }
                    }
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(10)
                }
                
                // 5. Ambient Night Mode Dark Overlay
                if appState.isNightMode {
                    Color.black.opacity(0.70)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(20)
                }
                
                // 6. Top Control Bar (Pill Toolbar)
                VStack {
                    HStack(spacing: 8) {
                        ControlButton(title: "Tema Ruangan", icon: "paintpalette.fill") {
                            withAnimation(.spring()) {
                                appState.showThemePicker = true
                            }
                        }
                        
                        ControlButton(title: appState.isNightMode ? "Nyalakan Lampu" : "Mode Malam", icon: appState.isNightMode ? "sun.max.fill" : "moon.stars.fill") {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                appState.isNightMode.toggle()
                            }
                        }
                        
                        ControlButton(
                            title: storage.areDesktopIconsHidden ? "Tampilkan Ikon Mac" : "Sembunyikan Ikon Mac",
                            icon: storage.areDesktopIconsHidden ? "eye.fill" : "eye.slash.fill"
                        ) {
                            storage.toggleNativeDesktopIcons()
                        }
                        
                        ControlButton(title: "Folder Penyimpanan", icon: "folder.fill") {
                            storage.openBaseFolder()
                        }
                        
                        ControlButton(title: "Panduan", icon: "questionmark.circle.fill") {
                            withAnimation(.spring()) {
                                appState.showHelpModal = true
                            }
                        }
                        
                        // Close / Minimize button
                        Button(action: {
                            NSApplication.shared.miniaturizeAll(nil)
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(6)
                        }
                        .buttonStyle(.plain)
                        .help("Perkecil Jendela")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(NSColor.windowBackgroundColor).opacity(0.95))
                            .shadow(color: .black.opacity(0.35), radius: 10, y: 3)
                    )
                    .padding(.top, 14)
                    
                    Spacer()
                }
                .zIndex(30)
                
                // MARK: - In-App Seamless Modals (Never glitch, 100% clickable)
                // Bookshelf Drawer Modal
                if appState.showBookshelfDrawer {
                    ModalBackdrop(isPresented: $appState.showBookshelfDrawer) {
                        BookshelfDrawerView(isPresented: $appState.showBookshelfDrawer)
                    }
                    .zIndex(40)
                }
                
                // Theme Picker Modal
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
                
                // Help Guide Modal
                if appState.showHelpModal {
                    ModalBackdrop(isPresented: $appState.showHelpModal) {
                        HelpGuideModalView(isPresented: $appState.showHelpModal)
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
                    }
                    .zIndex(40)
                }
            }
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

// MARK: - Potted Floor Houseplant
struct HousePlantView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Leaf cluster
            ZStack {
                LeafShape()
                    .fill(Color(red: 0.18, green: 0.52, blue: 0.28))
                    .frame(width: 32, height: 48)
                    .rotationEffect(.degrees(-35))
                    .offset(x: -16, y: -8)
                
                LeafShape()
                    .fill(Color(red: 0.22, green: 0.60, blue: 0.32))
                    .frame(width: 34, height: 52)
                    .rotationEffect(.degrees(30))
                    .offset(x: 16, y: -10)
                
                LeafShape()
                    .fill(Color(red: 0.15, green: 0.45, blue: 0.22))
                    .frame(width: 30, height: 46)
                    .offset(y: -14)
            }
            
            // Terracotta pot
            Path { path in
                path.move(to: CGPoint(x: 4, y: 0))
                path.addLine(to: CGPoint(x: 8, y: 34))
                path.addLine(to: CGPoint(x: 32, y: 34))
                path.addLine(to: CGPoint(x: 36, y: 0))
                path.closeSubpath()
            }
            .fill(Color(red: 0.82, green: 0.42, blue: 0.25))
            .frame(width: 40, height: 34)
            .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
        }
        .frame(width: 70, height: 86)
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX - 4, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX + 4, y: rect.midY))
        return path
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
                    GuideRow(icon: "photo.stack.fill", color: .purple, title: "Bingkai Foto di Dinding Kanan", desc: "Drag & drop foto atau klik bingkai kosong untuk memilih foto dari Mac. Klik foto untuk melihat ukuran penuh.")
                    GuideRow(icon: "books.vertical.fill", color: .brown, title: "Rak Buku File & Folder Organizer", desc: "Klik rak buku untuk membuka koleksi buku! Drag & drop file/folder ke rak atau tekan tombol tambah file.")
                    GuideRow(icon: "oval.inset.filled", color: .red, title: "Magic Carpet (Sembunyikan File)", desc: "Klik karpet untuk mengangkatnya dan melihat item tersembunyi. Drag file ke atas karpet untuk menyembunyikannya dari desktop.")
                    GuideRow(icon: "note.text", color: .orange, title: "Memo Board (Papan Catatan)", desc: "Klik tombol '+' di pojok papan gabus untuk membuat sticky note baru. Geser posisi note, edit judul & to-do list.")
                    GuideRow(icon: "calendar", color: .red, title: "Kalender & Jam Dinding Realtime", desc: "Menampilkan waktu dan tanggal live. Klik kalender untuk membuka aplikasi Kalender macOS.")
                    GuideRow(icon: "lightbulb.fill", color: .yellow, title: "Lampu Meja (Mode Malam)", desc: "Klik kap lampu hijau di atas meja untuk mematikan/menyalakan lampu dan meredupkan ruangan.")
                    GuideRow(icon: "radio.fill", color: .green, title: "Radio Vintage Spotify", desc: "Klik radio di atas meja untuk membuka mini player Spotify, memutar musik, dan melihat judul lagu.")
                    GuideRow(icon: "trash.fill", color: .gray, title: "Tempat Sampah", desc: "Drag file apa pun ke tong sampah di samping meja untuk membuangnya langsung ke Trash macOS.")
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
