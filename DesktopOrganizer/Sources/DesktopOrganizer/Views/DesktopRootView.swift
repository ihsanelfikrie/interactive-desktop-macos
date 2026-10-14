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
            
            ZStack(alignment: .topLeading) {
                // 1. Procedural Room Background (Wall & Floor)
                ThemeBackgroundView(theme: appState.currentTheme, isNightMode: !appState.lampOn)
                    .frame(width: w, height: h)
                
                // 2. Customizable Movable Room Elements Layer
                Group {
                    // Bookshelf (Rak Buku)
                    CustomizableElement(
                        id: "bookshelf",
                        title: "Rak Buku",
                        defaultPos: CGPoint(x: 40, y: max(100, h - 510)),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        BookshelfView(theme: appState.currentTheme)
                    }
                    
                    // Potted Plant (Tanaman Lantai)
                    CustomizableElement(
                        id: "plant",
                        title: "Tanaman Hias",
                        defaultPos: CGPoint(x: 230, y: max(200, h - 180)),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        HousePlantView()
                    }
                    
                    // Corkboard (Papan Catatan)
                    CustomizableElement(
                        id: "corkboard",
                        title: "Papan Catatan",
                        defaultPos: CGPoint(x: max(260, w * 0.5 - 340), y: 70),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        CorkboardView()
                    }
                    
                    // Wall Clock & Calendar (Jam & Kalender Dinding)
                    CustomizableElement(
                        id: "clockCalendar",
                        title: "Jam & Kalender",
                        defaultPos: CGPoint(x: max(320, w * 0.5 + 130), y: 75),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        WallClockCalendarView()
                    }
                    
                    // Photo Gallery (Bingkai Foto)
                    CustomizableElement(
                        id: "photoGallery",
                        title: "Galeri Foto",
                        defaultPos: CGPoint(x: max(400, w - 280), y: 80),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        PhotoGalleryView()
                    }
                    
                    // Executive Desk (Meja Belajar & Kerja)
                    CustomizableElement(
                        id: "desk",
                        title: "Meja Kerja & Lampu",
                        defaultPos: CGPoint(x: max(200, w * 0.5 - 340), y: max(150, h - 250)),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        DeskView(
                            theme: appState.currentTheme,
                            isNightMode: Binding(
                                get: { !appState.lampOn },
                                set: { appState.lampOn = !$0 }
                            ),
                            showSpotifyPopup: Binding(
                                get: { appState.showSpotifyPopup },
                                set: { appState.showSpotifyPopup = $0 }
                            )
                        )
                    }
                    
                    // Magic Carpet (Karpet Ajaib)
                    CustomizableElement(
                        id: "carpet",
                        title: "Magic Carpet",
                        defaultPos: CGPoint(x: max(220, w * 0.5 - 180), y: max(150, h - 170)),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        MagicCarpetView(theme: appState.currentTheme)
                    }
                    
                    // Trash Can (Tempat Sampah)
                    CustomizableElement(
                        id: "trashCan",
                        title: "Tempat Sampah",
                        defaultPos: CGPoint(x: max(300, w * 0.5 + 360), y: max(150, h - 165)),
                        isEditMode: appState.isEditLayoutMode
                    ) {
                        TrashCanView()
                    }
                    
                    // Kos-Kosan Props (Kipas & Dispenser)
                    if appState.currentTheme == .kos {
                        CustomizableElement(
                            id: "standingFan",
                            title: "Kipas Angin",
                            defaultPos: CGPoint(x: max(150, w * 0.5 - 430), y: max(150, h - 210)),
                            isEditMode: appState.isEditLayoutMode
                        ) {
                            StandingFanView()
                        }
                        
                        CustomizableElement(
                            id: "waterDispenser",
                            title: "Galon Dispenser",
                            defaultPos: CGPoint(x: max(300, w * 0.5 + 360), y: max(150, h - 220)),
                            isEditMode: appState.isEditLayoutMode
                        ) {
                            WaterDispenserView()
                        }
                    }
                }
                .frame(width: w, height: h)
                
                // 3. Spotify Mini Player Card (Floating near radio)
                if appState.showSpotifyPopup {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            SpotifyMiniPlayerView(isPresented: Binding(
                                get: { appState.showSpotifyPopup },
                                set: { appState.showSpotifyPopup = $0 }
                            ))
                            .offset(x: 140, y: -220)
                            Spacer()
                        }
                    }
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(10)
                }
                
                // 4. Ambient Night Mode / Lamp Dimmed Dark Overlay (LampOffShade)
                if !appState.lampOn {
                    Color.black.opacity(0.68)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(20)
                }
                
                // 5. Top Control Bar (Pill Toolbar)
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Layout Customization Toggle
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                appState.isEditLayoutMode.toggle()
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: appState.isEditLayoutMode ? "checkmark.circle.fill" : "arrow.up.and.down.and.arrow.left.and.right")
                                    .font(.system(size: 11, weight: .bold))
                                Text(appState.isEditLayoutMode ? "Selesai Atur Posisi" : "Atur Tata Letak")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(appState.isEditLayoutMode ? Color.yellow : Color.white.opacity(0.18))
                            .foregroundColor(appState.isEditLayoutMode ? .black : .primary)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .help(appState.isEditLayoutMode ? "Simpan dan kunci posisi furnitur" : "Aktifkan mode geser untuk mengatur posisi perabotan")
                        
                        // Reset Layout Button (Visible when in edit mode)
                        if appState.isEditLayoutMode {
                            Button(action: {
                                withAnimation(.spring()) {
                                    storage.resetLayout(screenSize: CGSize(width: w, height: h))
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset Posisi")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(Color.red.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .help("Kembalikan tata letak semua perabotan ke posisi default")
                        }
                        
                        ControlButton(title: "Tema Ruangan", icon: "paintpalette.fill") {
                            withAnimation(.spring()) {
                                appState.showThemePicker = true
                            }
                        }
                        
                        ControlButton(title: appState.lampOn ? "Matikan Lampu" : "Nyalakan Lampu", icon: appState.lampOn ? "moon.stars.fill" : "sun.max.fill") {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                appState.lampOn.toggle()
                            }
                        }
                        
                        ControlButton(title: "Geser Ikon", icon: "arrow.right.to.line.compact") {
                            storage.moveCoveredIcons()
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
                        
                        // Minimize Window button
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
                .frame(width: w)
                .zIndex(30)
                
                // MARK: - In-App Seamless Modals
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
            .onAppear {
                storage.loadLayout(screenSize: CGSize(width: w, height: h))
            }
        }
    }
}

// MARK: - Customizable Element Wrapper (Supports Dragging to Reposition)
struct CustomizableElement<Content: View>: View {
    @ObservedObject var storage = StorageManager.shared
    let id: String
    let title: String
    let defaultPos: CGPoint
    let isEditMode: Bool
    @ViewBuilder let content: () -> Content
    
    var currentPos: CGPoint {
        storage.layoutPositions[id] ?? defaultPos
    }
    
    var body: some View {
        content()
            .overlay(
                Group {
                    if isEditMode {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                            .background(Color.yellow.opacity(0.12))
                            .overlay(
                                VStack {
                                    HStack {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                                            Text(title)
                                        }
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.yellow))
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(4)
                            )
                    }
                }
            )
            .offset(x: currentPos.x, y: currentPos.y)
            .gesture(
                isEditMode ? DragGesture()
                    .onChanged { value in
                        var newPos = storage.layoutPositions[id] ?? defaultPos
                        newPos.x += value.translation.width
                        newPos.y += value.translation.height
                        storage.layoutPositions[id] = newPos
                    }
                    .onEnded { _ in
                        storage.saveLayout()
                    } : nil
            )
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
                    GuideRow(icon: "arrow.up.and.down.and.arrow.left.and.right", color: .yellow, title: "Kustomisasi Tata Letak Bebas", desc: "Klik tombol 'Atur Tata Letak' di toolbar atas. Setiap perabotan (meja, rak, papan catatan, karpet, jam) bisa kamu geser bebas ke posisi mana pun di layar MacBook kamu!")
                    GuideRow(icon: "photo.stack.fill", color: .purple, title: "Bingkai Foto di Dinding", desc: "Drag & drop foto atau klik bingkai kosong untuk memilih foto dari Mac. Klik foto untuk melihat ukuran penuh.")
                    GuideRow(icon: "books.vertical.fill", color: .brown, title: "Rak Buku File & Folder", desc: "Klik rak buku untuk membuka koleksi buku! Drag & drop file/folder ke rak atau tekan tombol tambah file.")
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
