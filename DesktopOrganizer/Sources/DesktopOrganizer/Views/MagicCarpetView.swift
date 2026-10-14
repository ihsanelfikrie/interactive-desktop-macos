import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct MagicCarpetView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let theme: RoomTheme
    
    public init(theme: RoomTheme) {
        self.theme = theme
    }
    
    public var body: some View {
        let dragRatio = max(-1.0, min(1.0, appState.carpetSlideOffset / 320.0))
        let dragAngle = Double(dragRatio) * (appState.isCarpetDragging ? 2.8 : 0.6)
        let liftAngle = Double(-dragRatio) * (appState.isCarpetDragging ? 7.2 : 1.8)
        
        ZStack(alignment: .center) {
            // LAYER 1 (Bottom, lying directly on the wooden floor):
            // The secret files & folders hidden under the carpet (revealed when carpet slides)
            CarpetFloorSecretView(items: storage.carpetItems)
                .frame(width: 660, height: 125)
                .opacity(abs(appState.carpetSlideOffset) > 6 ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.2), value: abs(appState.carpetSlideOffset) > 6)
            
            // LAYER 2 (Top, sits over the files and physically slides when held/dragged):
            // The Carpet / Rug itself with realistic cloth drag dynamics
            CarpetMatBodyView(theme: theme, itemCount: storage.carpetItems.count)
                .offset(x: appState.carpetSlideOffset, y: appState.isCarpetDragging ? -5 : 0)
                .rotationEffect(.degrees(dragAngle))
                .rotation3DEffect(
                    .degrees(liftAngle),
                    axis: (x: 0, y: 1, z: 0.12),
                    anchor: dragRatio >= 0 ? .leading : .trailing
                )
                .shadow(
                    color: Color.black.opacity(appState.isCarpetDragging ? 0.48 : 0.35),
                    radius: appState.isCarpetDragging ? 16 : 8,
                    x: CGFloat(dragRatio * -8),
                    y: appState.isCarpetDragging ? 14 : 6
                )
                .zIndex(2)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 3)
                        .onChanged { value in
                            appState.isCarpetDragging = true
                            let base: CGFloat = appState.isCarpetLifted ? (appState.carpetSlideOffset > 0 ? 320.0 : -320.0) : 0.0
                            let newOffset = max(-420, min(420, base + value.translation.width))
                            appState.carpetSlideOffset = newOffset
                        }
                        .onEnded { value in
                            appState.isCarpetDragging = false
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                                if appState.carpetSlideOffset > 50 {
                                    appState.carpetSlideOffset = 320
                                    appState.isCarpetLifted = true
                                } else if appState.carpetSlideOffset < -50 {
                                    appState.carpetSlideOffset = -320
                                    appState.isCarpetLifted = true
                                } else {
                                    appState.carpetSlideOffset = 0
                                    appState.isCarpetLifted = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.70)) {
                        appState.isCarpetLifted.toggle()
                        appState.carpetSlideOffset = appState.isCarpetLifted ? -320 : 0
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: Binding(
                    get: { appState.isCarpetTargeted },
                    set: { appState.isCarpetTargeted = $0 }
                )) { providers in
                    for provider in providers {
                        StorageManager.extractFileURL(from: provider) { url in
                            withAnimation(.spring()) {
                                storage.addCarpetItem(from: url)
                            }
                        }
                    }
                    return true
                }
                .contextMenu {
                    if abs(appState.carpetSlideOffset) > 10 {
                        Button("Tutup Karpet (Sembunyikan File)") {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.70)) {
                                appState.carpetSlideOffset = 0
                                appState.isCarpetLifted = false
                            }
                        }
                    } else {
                        Button("Geser Karpet ke Kiri") {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.70)) {
                                appState.carpetSlideOffset = -320
                                appState.isCarpetLifted = true
                            }
                        }
                        Button("Geser Karpet ke Kanan") {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.70)) {
                                appState.carpetSlideOffset = 320
                                appState.isCarpetLifted = true
                            }
                        }
                    }
                    
                    Button("Pilih File untuk Disembunyikan...") {
                        storage.pickCarpetItem()
                    }
                    
                    if !storage.carpetItems.isEmpty {
                        Divider()
                        Button("Kembalikan Semua File ke Desktop") {
                            withAnimation(.spring()) {
                                storage.restoreAllCarpetItems()
                            }
                        }
                    }
                    
                    Divider()
                    Button("Buka Folder Karpet di Finder") {
                        storage.openInFinder(url: storage.carpetDirectory)
                    }
                }
        }
        // 3D Floor Perspective: Tilts carpet flat on the floor in authentic perspective
        .rotation3DEffect(
            .degrees(50),
            axis: (x: 1, y: 0, z: 0),
            anchor: .center,
            perspective: 0.55
        )
        .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 8)
        .help("Karpet: Geser atau klik untuk membuka. Tarik file ke atas karpet untuk menyembunyikannya.")
    }
}

// MARK: - Secret Floor Stash (Revealed when carpet slides aside)
struct CarpetFloorSecretView: View {
    let items: [URL]
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        ZStack {
            if items.isEmpty {
                // Empty guide dashed outline on floor
                if appState.carpetSlideOffset > 25 {
                    HStack(spacing: 6) {
                        Image(systemName: "tray.and.arrow.down")
                            .font(.system(size: 13, weight: .bold))
                        Text("Tarik file ke sini untuk menyembunyikan")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Color.white.opacity(0.45))
                    .frame(width: 320, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundColor(Color.white.opacity(0.25))
                    )
                    .transition(.opacity)
                }
            } else {
                // Secret files lying on the wooden floor planks
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            FloorFileItemView(itemURL: item)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
                .frame(width: 360, height: 75)
            }
        }
    }
}

// MARK: - Individual File lying on the floor
struct FloorFileItemView: View {
    let itemURL: URL
    let iconImage: NSImage
    @ObservedObject var storage = StorageManager.shared
    
    init(itemURL: URL) {
        self.itemURL = itemURL
        self.iconImage = NSWorkspace.shared.icon(forFile: itemURL.path)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                // Physical file icon on floor with cast shadow
                Image(nsImage: iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                
                // Quick restore button
                Button(action: {
                    withAnimation(.spring()) {
                        storage.restoreCarpetItemToDesktop(itemURL: itemURL)
                    }
                }) {
                    Image(systemName: "arrow.up.forward.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.yellow)
                        .background(Circle().fill(Color.black.opacity(0.85)))
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
                .help("Kembalikan file ini ke Desktop")
            }
            
            // Filename pill
            Text(itemURL.lastPathComponent)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 68)
                .padding(.horizontal, 4)
                .padding(.vertical, 1.5)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.65))
                )
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            NSWorkspace.shared.open(itemURL)
        }
        .onTapGesture {
            AppState.shared.toggleQuickView(.carpetItem(url: itemURL))
        }
        .help("\(itemURL.lastPathComponent): Klik untuk melihat detail, klik 2x untuk membuka")
        .contextMenu {
            Button("Buka \(itemURL.lastPathComponent)") {
                NSWorkspace.shared.open(itemURL)
            }
            Button("Kembalikan ke Desktop") {
                withAnimation(.spring()) {
                    storage.restoreCarpetItemToDesktop(itemURL: itemURL)
                }
            }
            Button("Tampilkan di Finder") {
                storage.openInFinder(url: itemURL)
            }
            Divider()
            Button("Buang ke Tempat Sampah", role: .destructive) {
                withAnimation(.spring()) {
                    _ = storage.moveToTrash(url: itemURL)
                    storage.refreshCarpet()
                }
            }
        }
    }
}

// MARK: - Carpet / Rug Mat Body (Authentic Rectangular Arabic / Persian Oriental Rug)
struct CarpetMatBodyView: View {
    let theme: RoomTheme
    let itemCount: Int
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        ZStack {
            // Rectangular Arabic Carpet Body with Fringes & Ornate Arabesque Pattern
            ArabicRugView()
            
            // Physical bumps on top of carpet when items are hidden inside
            if itemCount > 0 {
                ZStack {
                    CarpetLumpView()
                        .offset(x: -80, y: -6)
                    
                    if itemCount > 1 {
                        CarpetLumpView()
                            .offset(x: 15, y: 8)
                    }
                    
                    if itemCount > 2 {
                        CarpetLumpView()
                            .offset(x: 95, y: -4)
                    }
                }
                .transition(.scale)
            }
            
            // Drop target or Hidden items count indicator
            VStack {
                if appState.isCarpetTargeted {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Sembunyikan ke Bawah Karpet Arabik")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.98, green: 0.88, blue: 0.50))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.80)))
                    .overlay(Capsule().stroke(Color(red: 0.88, green: 0.74, blue: 0.40), lineWidth: 1))
                    .transition(.scale)
                } else if itemCount > 0 && abs(appState.carpetSlideOffset) < 20 {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 9))
                        Text("\(itemCount) file tersembunyi")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.95))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2.5)
                    .background(Capsule().fill(Color.black.opacity(0.65)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.8))
                    .transition(.opacity)
                }
            }
        }
        .scaleEffect(appState.isCarpetDragging ? 0.98 : 1.0)
    }
}

// MARK: - Dynamic Realistic Cloth Wrinkle & Wave Folds Overlay
struct CarpetClothFoldsView: View {
    let width: CGFloat
    let height: CGFloat
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        let offset = appState.carpetSlideOffset
        let isMoving = appState.isCarpetDragging || abs(offset) > 10
        let foldOpacity = appState.isCarpetDragging ? 0.85 : (abs(offset) > 20 ? 0.45 : 0.14)
        let dragDir: CGFloat = offset >= 0 ? 1.0 : -1.0
        
        ZStack {
            // Realistic undulating wave wrinkles across the velvet fabric body
            HStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { i in
                    let foldPhase = CGFloat(i)
                    // Wave ripple traveling displacement based on drag offset
                    let waveShift = sin((offset * 0.038) + foldPhase * 1.3) * 11.0
                    
                    HStack(spacing: 0) {
                        // Crease Shadow Trough (dark fold indention)
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.32 * foldOpacity),
                                Color.black.opacity(0.08 * foldOpacity)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: width * 0.038)
                        
                        // Crease Highlight Ridge (elevated wave crest catching light)
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22 * foldOpacity),
                                Color.white.opacity(0.06 * foldOpacity),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: width * 0.042)
                    }
                    .offset(x: waveShift, y: 0)
                    .rotationEffect(.degrees(Double((i % 2 == 0 ? 1 : -1) * 3) * (appState.isCarpetDragging ? 1.2 : 0.4)))
                    
                    if i < 5 {
                        Spacer()
                    }
                }
            }
            .frame(width: width * 0.86, height: height * 0.92)
            .blendMode(.multiply)
            .allowsHitTesting(false)
            
            // Dynamic Edge Bunching & Tension Lines when dragged
            if isMoving {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.38 * foldOpacity),
                        Color.clear
                    ],
                    startPoint: dragDir > 0 ? .leading : .trailing,
                    endPoint: dragDir > 0 ? .trailing : .leading
                )
                .frame(width: width * 0.22, height: height)
                .offset(x: dragDir > 0 ? -width * 0.38 : width * 0.38)
                .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .animation(.easeInOut(duration: 0.18), value: appState.isCarpetDragging)
    }
}

// MARK: - Authentic Rectangular Arabic / Oriental Persian Rug View (Enlarged with Cloth Dynamics)
struct ArabicRugView: View {
    @ObservedObject var appState = AppState.shared
    
    let rugWidth: CGFloat = 610
    let rugHeight: CGFloat = 156
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Ivory Fringe Tassels
            RugFringeEdge(isLeading: true)
                .frame(width: 12, height: 148)
            
            // Main Rectangular Carpet Body
            ZStack {
                // Base Velvet Foundation (Deep Midnight Indigo)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.10, green: 0.12, blue: 0.18))
                    .frame(width: rugWidth, height: rugHeight)
                    .shadow(color: .black.opacity(0.38), radius: 6, y: 5)
                
                // Outer Deep Persian Wine Velvet Body
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.56, green: 0.11, blue: 0.15),
                                Color(red: 0.46, green: 0.08, blue: 0.12),
                                Color(red: 0.52, green: 0.10, blue: 0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: rugWidth - 2, height: rugHeight - 2)
                
                // Outer Golden Guard Stripe
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(red: 0.88, green: 0.74, blue: 0.40).opacity(0.85), lineWidth: 1.2)
                    .frame(width: rugWidth - 10, height: rugHeight - 10)
                
                // Main Arabesque Border Band (Midnight Navy)
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(red: 0.10, green: 0.15, blue: 0.25), lineWidth: 8)
                    .frame(width: rugWidth - 20, height: rugHeight - 20)
                
                // Gold geometric star chain dashed rosettes
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(
                        Color(red: 0.90, green: 0.78, blue: 0.48).opacity(0.9),
                        style: StrokeStyle(lineWidth: 1.5, dash: [3, 4])
                    )
                    .frame(width: rugWidth - 20, height: rugHeight - 20)
                
                // Inner Golden Guard Border
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(red: 0.88, green: 0.74, blue: 0.40), lineWidth: 1.2)
                    .frame(width: rugWidth - 32, height: rugHeight - 32)
                
                // Central Crimson Inner Field
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.62, green: 0.12, blue: 0.16),
                                Color(red: 0.50, green: 0.08, blue: 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: rugWidth - 34, height: rugHeight - 34)
                
                // 4 Arabic Corner Spandrels
                ZStack {
                    ArabicCornerSpandrel()
                        .offset(x: -270, y: -47)
                    
                    ArabicCornerSpandrel()
                        .rotationEffect(.degrees(90))
                        .offset(x: 270, y: -47)
                    
                    ArabicCornerSpandrel()
                        .rotationEffect(.degrees(180))
                        .offset(x: 270, y: 47)
                    
                    ArabicCornerSpandrel()
                        .rotationEffect(.degrees(270))
                        .offset(x: -270, y: 47)
                }
                .allowsHitTesting(false)
                
                // Field Geometric Star Sprinkles
                HStack(spacing: 44) {
                    ForEach(0..<9, id: \.self) { i in
                        if i != 4 {
                            ArabicFieldStar()
                                .opacity(0.85)
                        } else {
                            Spacer().frame(width: 90)
                        }
                    }
                }
                .allowsHitTesting(false)
                
                // Grand Central Arabic 8-Pointed Star Medallion
                ArabicCentralMedallion()
                    .allowsHitTesting(false)
                
                // Realistic Dynamic Cloth Wrinkles & Fabric Wave Folds
                CarpetClothFoldsView(width: rugWidth, height: rugHeight)
                    .allowsHitTesting(false)
                
                // Interactive Drop Target Highlight
                if appState.isCarpetTargeted {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.yellow, lineWidth: 3)
                        .shadow(color: Color.yellow.opacity(0.8), radius: 8)
                        .frame(width: rugWidth, height: rugHeight)
                }
                
                // Subtle Woven Wool Sheen Overlay
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.clear,
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: rugWidth, height: rugHeight)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .allowsHitTesting(false)
            }
            .frame(width: rugWidth, height: rugHeight)
            
            // Right Ivory Fringe Tassels
            RugFringeEdge(isLeading: false)
                .frame(width: 12, height: 148)
        }
        .frame(width: rugWidth + 24, height: rugHeight)
    }
}

// MARK: - Left & Right Fringe Tassels (Rumbai Ujung Karpet dengan Efek Kibasan Kain)
struct RugFringeEdge: View {
    let isLeading: Bool
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        let dragRatio = max(-1.0, min(1.0, appState.carpetSlideOffset / 320.0))
        let flutterAngle = Double(dragRatio) * (isLeading ? -6.5 : 6.5) * (appState.isCarpetDragging ? 1.0 : 0.3)
        
        HStack(spacing: 0) {
            if !isLeading {
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.72, blue: 0.42))
                    .frame(width: 1.5, height: 148)
            }
            
            VStack(spacing: 2.1) {
                ForEach(0..<42, id: \.self) { i in
                    Rectangle()
                        .fill(
                            (i % 2 == 0)
                                ? Color(red: 0.96, green: 0.94, blue: 0.89)
                                : Color(red: 0.86, green: 0.82, blue: 0.74)
                        )
                        .frame(width: (i % 3 == 0) ? 9.5 : 8.0, height: 1.4)
                        .shadow(color: .black.opacity(0.12), radius: 0.5, y: 0.5)
                }
            }
            .frame(width: 9.5)
            .rotationEffect(.degrees(flutterAngle), anchor: isLeading ? .trailing : .leading)
            
            if isLeading {
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.72, blue: 0.42))
                    .frame(width: 1.5, height: 148)
            }
        }
    }
}

// MARK: - Central 8-Pointed Star Arabic Medallion
struct ArabicCentralMedallion: View {
    var body: some View {
        ZStack {
            // Horizontal Flanking Pendants
            HStack(spacing: 58) {
                ArabicFinialPendant()
                    .rotationEffect(.degrees(-90))
                ArabicFinialPendant()
                    .rotationEffect(.degrees(90))
            }
            
            // Outer 8-Pointed Star (Antique Gold)
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.76, blue: 0.42))
                    .frame(width: 44, height: 44)
                
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.76, blue: 0.42))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(45))
            }
            .shadow(color: .black.opacity(0.3), radius: 2)
            
            // Inner Midnight Navy 8-Pointed Star
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.12, green: 0.18, blue: 0.32))
                    .frame(width: 36, height: 36)
                
                Rectangle()
                    .fill(Color(red: 0.12, green: 0.18, blue: 0.32))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(45))
            }
            
            // Core Crimson Rosette with Jewel Dot
            ZStack {
                Circle()
                    .fill(Color(red: 0.65, green: 0.12, blue: 0.16))
                    .frame(width: 22, height: 22)
                
                Circle()
                    .stroke(Color(red: 0.92, green: 0.82, blue: 0.52), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                
                Circle()
                    .fill(Color(red: 0.22, green: 0.72, blue: 0.68))
                    .frame(width: 7, height: 7)
                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 0.8))
            }
        }
    }
}

// Medallion Finial Pendant
struct ArabicFinialPendant: View {
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(Color(red: 0.88, green: 0.76, blue: 0.42))
                .frame(width: 4, height: 4)
            
            Rectangle()
                .fill(Color(red: 0.88, green: 0.76, blue: 0.42))
                .frame(width: 7, height: 7)
                .rotationEffect(.degrees(45))
            
            Circle()
                .fill(Color(red: 0.88, green: 0.76, blue: 0.42))
                .frame(width: 3, height: 3)
        }
    }
}

// Arabic Corner Spandrel Motif
struct ArabicCornerSpandrel: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 28, y: 0))
                path.addLine(to: CGPoint(x: 28, y: 6))
                path.addLine(to: CGPoint(x: 16, y: 6))
                path.addLine(to: CGPoint(x: 16, y: 16))
                path.addLine(to: CGPoint(x: 6, y: 16))
                path.addLine(to: CGPoint(x: 6, y: 24))
                path.addLine(to: CGPoint(x: 0, y: 24))
                path.closeSubpath()
            }
            .fill(Color(red: 0.12, green: 0.18, blue: 0.32))
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 24, y: 0))
                path.addLine(to: CGPoint(x: 14, y: 6))
                path.addLine(to: CGPoint(x: 6, y: 14))
                path.addLine(to: CGPoint(x: 0, y: 20))
                path.closeSubpath()
            }
            .stroke(Color(red: 0.88, green: 0.76, blue: 0.42), lineWidth: 1.2)
        }
        .frame(width: 28, height: 24)
    }
}

// Arabic Field Star Sprinkle
struct ArabicFieldStar: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.88, green: 0.76, blue: 0.42).opacity(0.85))
                .frame(width: 6, height: 6)
                .rotationEffect(.degrees(45))
            
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 2, height: 2)
        }
    }
}

// MARK: - 3D Mound Lump on Carpet Surface
struct CarpetLumpView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.35))
                .frame(width: 50, height: 22)
                .blur(radius: 3)
                .offset(y: 3)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.15))
                .frame(width: 44, height: 16)
                .blur(radius: 2)
                .offset(y: -2)
        }
    }
}
