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
        ZStack(alignment: .center) {
            // LAYER 1 (Bottom, lying directly on the wooden floor):
            // The secret files & folders hidden under the carpet (revealed when carpet slides)
            CarpetFloorSecretView(items: storage.carpetItems)
                .frame(width: 320, height: 60)
                .opacity(abs(appState.carpetSlideOffset) > 6 ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.2), value: abs(appState.carpetSlideOffset) > 6)
            
            // LAYER 2 (Top, sits over the files and physically slides when held/dragged):
            // The Carpet / Rug itself
            CarpetMatBodyView(theme: theme, itemCount: storage.carpetItems.count)
                .offset(x: appState.carpetSlideOffset, y: 0)
                .zIndex(2)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 3)
                        .onChanged { value in
                            appState.isCarpetDragging = true
                            let base: CGFloat = appState.isCarpetLifted ? (appState.carpetSlideOffset > 0 ? 160.0 : -160.0) : 0.0
                            let newOffset = max(-220, min(220, base + value.translation.width))
                            appState.carpetSlideOffset = newOffset
                        }
                        .onEnded { value in
                            appState.isCarpetDragging = false
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                                if appState.carpetSlideOffset > 45 {
                                    appState.carpetSlideOffset = 160
                                    appState.isCarpetLifted = true
                                } else if appState.carpetSlideOffset < -45 {
                                    appState.carpetSlideOffset = -160
                                    appState.isCarpetLifted = true
                                } else {
                                    appState.carpetSlideOffset = 0
                                    appState.isCarpetLifted = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.75)) {
                        appState.isCarpetLifted.toggle()
                        appState.carpetSlideOffset = appState.isCarpetLifted ? -160 : 0
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
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                                appState.carpetSlideOffset = 0
                                appState.isCarpetLifted = false
                            }
                        }
                    } else {
                        Button("Geser Karpet ke Kiri") {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                                appState.carpetSlideOffset = -160
                                appState.isCarpetLifted = true
                            }
                        }
                        Button("Geser Karpet ke Kanan") {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                                appState.carpetSlideOffset = 160
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
    @ObservedObject var storage = StorageManager.shared
    
    var iconImage: NSImage {
        NSWorkspace.shared.icon(forFile: itemURL.path)
    }
    
    var body: some View {
        Button(action: {
            NSWorkspace.shared.open(itemURL)
        }) {
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
        }
        .buttonStyle(.plain)
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

// MARK: - Carpet / Rug Mat Body
struct CarpetMatBodyView: View {
    let theme: RoomTheme
    let itemCount: Int
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        ZStack {
            // Carpet oval body
            if let matImg = AssetLoader.image(named: theme.matImageName) {
                Image(nsImage: matImg)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 360, height: 80)
                    .shadow(color: .black.opacity(0.35), radius: 5, y: 4)
            } else {
                proceduralMat
            }
            
            // Physical bumps on top of carpet when items are hidden inside (Desktop Organizer reference)
            if itemCount > 0 {
                ZStack {
                    CarpetLumpView()
                        .offset(x: -45, y: -5)
                    
                    if itemCount > 1 {
                        CarpetLumpView()
                            .offset(x: 10, y: 6)
                    }
                    
                    if itemCount > 2 {
                        CarpetLumpView()
                            .offset(x: 55, y: -3)
                    }
                }
                .transition(.scale)
            }
            
            // Drop target or Hidden items count indicator
            VStack {
                if appState.isCarpetTargeted {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Sembunyikan ke Bawah Karpet")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.75)))
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
                    .background(Capsule().fill(Color.black.opacity(0.55)))
                    .transition(.opacity)
                }
            }
        }
        .scaleEffect(appState.isCarpetDragging ? 0.98 : 1.0)
    }
    
    private var proceduralMat: some View {
        ZStack {
            Ellipse()
                .fill(carpetColor)
                .frame(width: 360, height: 80)
                .overlay(
                    Ellipse()
                        .stroke(appState.isCarpetTargeted ? Color.yellow : borderRimColor, lineWidth: appState.isCarpetTargeted ? 4 : 2.5)
                        .frame(width: 346, height: 68)
                )
                .shadow(color: .black.opacity(0.35), radius: 5, y: 4)
        }
    }
    
    private var carpetColor: Color {
        Color(red: 0.50, green: 0.12, blue: 0.14) // Authentic Deep Burgundy
    }
    
    private var borderRimColor: Color {
        Color(red: 0.85, green: 0.72, blue: 0.42) // Warm Gold Trim
    }
}

// MARK: - 3D Mound Lump on Carpet Surface
struct CarpetLumpView: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.35))
                .frame(width: 50, height: 18)
                .blur(radius: 3)
                .offset(y: 3)
            
            Ellipse()
                .fill(Color.white.opacity(0.15))
                .frame(width: 42, height: 12)
                .blur(radius: 2)
                .offset(y: -2)
        }
    }
}

struct TasselGroupView: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<5) { _ in
                Rectangle()
                    .fill(Color(red: 0.92, green: 0.82, blue: 0.60))
                    .frame(width: 7, height: 2)
            }
        }
    }
}
