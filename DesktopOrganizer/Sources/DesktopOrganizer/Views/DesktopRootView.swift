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
                // 1. Pixel Art Room Background (Fills entire screen crisp and seamless)
                ThemeBackgroundView(theme: appState.currentTheme, isNightMode: !appState.lampOn)
                    .frame(width: w, height: h)
                
                // 2. Interactive Hot Zones (Directly aligned with room pixel art)
                
                // Bookshelf Zone (Left Wall - 4 tiers of pixel art books/boxes & sliding ladder)
                BookshelfView(theme: appState.currentTheme)
                    .frame(width: w * 0.19, height: h * 0.78)
                    .position(x: w * 0.105, y: h * 0.49)
                
                // Sticky Notes Board (Center Wall Corkboard)
                CorkboardView()
                    .frame(width: w * 0.30, height: h * 0.38)
                    .position(x: w * 0.39, y: h * 0.27)
                
                // Wall Clock & Calendar (Upper Wall)
                WallClockCalendarView()
                    .frame(width: w * 0.10, height: h * 0.16)
                    .position(x: w * 0.62, y: h * 0.14)
                
                // Photo Gallery Frames (Right Wall Frames)
                PhotoGalleryView()
                    .frame(width: w * 0.22, height: h * 0.36)
                    .position(x: w * 0.79, y: h * 0.26)
                
                // Desk Lamp Hot Zone (Tabletop Lamp)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        appState.lampOn.toggle()
                    }
                }) {
                    ZStack {
                        // Invisible tap target over the illustrated lamp
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                        
                        // Subtle light glow when on
                        if appState.lampOn {
                            Circle()
                                .fill(Color.yellow.opacity(0.18))
                                .frame(width: 60, height: 60)
                                .blur(radius: 10)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help("Lampu Meja: Klik untuk menyalakan/mematikan lampu")
                .frame(width: w * 0.11, height: h * 0.20)
                .position(x: w * 0.32, y: h * 0.55)
                
                // Desk Radio Hot Zone (Tabletop Radio)
                Button(action: {
                    spotify.playPause()
                }) {
                    ZStack {
                        let radioImgName = spotify.isPlaying ? appState.currentTheme.radioOnImageName : appState.currentTheme.radioOffImageName
                        if let radioImg = AssetLoader.image(named: radioImgName) {
                            Image(nsImage: radioImg)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(height: 50)
                                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
                        } else {
                            Image(systemName: "radio.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.brown)
                        }
                        
                        if spotify.isPlaying {
                            Text("♪ ♫")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                                .offset(x: 20, y: -24)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("Buka Spotify") { spotify.openSpotify() }
                    Button(spotify.isPlaying ? "Jeda Lagu" : "Putar Lagu") { spotify.playPause() }
                    Button("Lagu Berikutnya") { spotify.nextTrack() }
                    Button("Lagu Sebelumnya") { spotify.previousTrack() }
                }
                .help("Radio: \(spotify.isPlaying ? "\(spotify.trackTitle) - \(spotify.artistName)" : "Klik untuk memutar Spotify")")
                .frame(width: w * 0.10, height: h * 0.14)
                .position(x: w * 0.44, y: h * 0.58)
                
                // Potted Plant (Left Floor)
                HousePlantView()
                    .frame(width: w * 0.08, height: h * 0.24)
                    .position(x: w * 0.22, y: h * 0.72)
                
                // Magic Carpet / Rug Zone (Floor)
                MagicCarpetView(theme: appState.currentTheme)
                    .frame(width: w * 0.32, height: h * 0.24)
                    .position(x: w * 0.65, y: h * 0.81)
                
                // Trash Can Zone (Right Floor)
                TrashCanView()
                    .frame(width: w * 0.09, height: h * 0.18)
                    .position(x: w * 0.90, y: h * 0.82)
                
                // 3. Ambient Night Overlay when Lamp is Off (LampOffShade)
                if !appState.lampOn {
                    Color.black.opacity(0.68)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(20)
                }
                
                // 4. Floating Top Control Bar (Clean Glass Pill)
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ControlButton(title: "Tema", icon: "paintpalette.fill") {
                            withAnimation(.spring()) {
                                appState.showThemePicker = true
                            }
                        }
                        
                        ControlButton(title: appState.lampOn ? "Matikan Lampu" : "Nyalakan Lampu", icon: appState.lampOn ? "moon.stars.fill" : "sun.max.fill") {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                appState.lampOn.toggle()
                            }
                        }
                        
                        ControlButton(title: "Kembalikan Semua", icon: "arrow.uturn.backward.circle.fill") {
                            storage.restoreEverything()
                        }
                        
                        ControlButton(title: "Geser Ikon Mac", icon: "arrow.right.to.line.compact") {
                            storage.moveCoveredIcons()
                        }
                        
                        ControlButton(title: "Folder Ruangan", icon: "folder.fill") {
                            storage.openBaseFolder()
                        }
                        
                        ControlButton(title: "Panduan", icon: "questionmark.circle.fill") {
                            withAnimation(.spring()) {
                                appState.showHelpModal = true
                            }
                        }
                        
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
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color(NSColor.windowBackgroundColor).opacity(0.92))
                            .shadow(color: .black.opacity(0.3), radius: 8, y: 3)
                    )
                    .padding(.top, 14)
                    Spacer()
                }
                .frame(width: w)
                .zIndex(30)
                
                // 5. In-App Seamless Modals
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

// MARK: - Potted Floor Houseplant & Swaying Leaves
struct HousePlantView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Swaying Leaves layer
            if let leavesImg = AssetLoader.image(named: "plant-leaves") {
                Image(nsImage: leavesImg)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 82, height: 68)
                    .rotationEffect(.degrees(appState.isLowPower ? 0 : 3))
                    .animation(appState.isLowPower ? .default : .easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: appState.isLowPower)
                    .offset(y: -28)
            } else {
                proceduralLeaves
            }
            
            // Potted Base
            if let potImg = AssetLoader.image(named: "plant-pot") {
                Image(nsImage: potImg)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 52, height: 42)
            } else {
                proceduralPot
            }
        }
        .frame(width: 86, height: 100)
    }
    
    private var proceduralLeaves: some View {
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
        .offset(y: -24)
    }
    
    private var proceduralPot: some View {
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
                    GuideRow(icon: "books.vertical.fill", color: .brown, title: "Rak Buku File & Folder", desc: "Seret file/folder dari desktop ke rak buku untuk menyimpannya. Klik dua kali untuk membuka file, atau klik kanan untuk melihat opsi.")
                    GuideRow(icon: "oval.inset.filled", color: .red, title: "Magic Carpet (Sembunyikan File)", desc: "Seret file ke atas karpet untuk menyembunyikannya. Klik karpet untuk mengangkatnya dan melihat/mengembalikan file.")
                    GuideRow(icon: "note.text", color: .orange, title: "Memo Board (Catatan Dinding)", desc: "Klik tombol '+' di pojok catatan untuk menambah memo baru. Tulis to-do list dan centang saat selesai.")
                    GuideRow(icon: "photo.stack.fill", color: .purple, title: "Bingkai Foto di Dinding", desc: "Seret foto ke bingkai dinding atau klik bingkai kosong untuk memajang foto favorit kamu.")
                    GuideRow(icon: "lightbulb.fill", color: .yellow, title: "Lampu Meja (Mode Malam)", desc: "Klik kap lampu di atas meja untuk mematikan/menyalakan lampu dan menikmati suasana malam yang tenang.")
                    GuideRow(icon: "radio.fill", color: .green, title: "Radio Spotify", desc: "Klik radio di atas meja untuk memutar/menjeda lagu di Spotify langsung dari desktop.")
                    GuideRow(icon: "trash.fill", color: .gray, title: "Tempat Sampah", desc: "Seret file apa pun ke tempat sampah di lantai untuk membuangnya langsung ke Trash macOS.")
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
