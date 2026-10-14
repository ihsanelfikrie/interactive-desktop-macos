import SwiftUI
import UniformTypeIdentifiers

public struct BookshelfView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let theme: RoomTheme
    
    public init(theme: RoomTheme) {
        self.theme = theme
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Main Bookshelf structure
            ZStack(alignment: .topLeading) {
                // Outer wooden frame
                RoundedRectangle(cornerRadius: 6)
                    .fill(shelfWoodColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(appState.isBookshelfTargeted ? Color.yellow : shelfShadowColor, lineWidth: appState.isBookshelfTargeted ? 4 : 2)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                
                // Interior back panel
                RoundedRectangle(cornerRadius: 4)
                    .fill(shelfInteriorColor)
                    .padding(8)
                
                // Shelves & Book Spines
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { shelfIndex in
                        VStack(spacing: 0) {
                            Spacer()
                            
                            // Shelf contents
                            HStack(alignment: .bottom, spacing: 3) {
                                renderShelfBooks(shelfIndex: shelfIndex)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            
                            // Wooden horizontal shelf plank
                            Rectangle()
                                .fill(shelfWoodColor)
                                .frame(height: 10)
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Library Rolling Ladder leaning against shelf (Draggable!)
                if theme == .library {
                    HStack {
                        LadderView()
                            .offset(y: 10)
                        Spacer()
                    }
                }
                
                // Top label button
                HStack {
                    Spacer()
                    Text("\(storage.bookshelfItems.count) Item")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.black.opacity(0.45)))
                        .padding(6)
                }
                
                // Drop overlay indicator
                if appState.isBookshelfTargeted {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.35))
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                Text("Lepaskan File/Folder di Rak")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
            .frame(width: 175, height: 400)
            .contentShape(Rectangle())
            .onTapGesture {
                appState.showBookshelfDrawer = true
            }
            .onDrop(of: [.fileURL], isTargeted: Binding(
                get: { appState.isBookshelfTargeted },
                set: { appState.isBookshelfTargeted = $0 }
            )) { providers in
                for provider in providers {
                    StorageManager.extractFileURL(from: provider) { url in
                        storage.addBookshelfItem(from: url)
                    }
                }
                return true
            }
            .help(shelfTooltip)
        }
    }
    
    private var shelfTooltip: String {
        switch theme {
        case .library: return "Tarik file ke sini jadi buku. Folder jadi kardus arsip"
        case .kos: return "Tarik file ke sini jadi map plastik. Folder jadi kardus mi"
        case .garden: return "Tarik file ke sini jadi paket benih. Folder jadi pot bunga"
        }
    }
    
    // MARK: - Book decoration on shelves
    @ViewBuilder
    private func renderShelfBooks(shelfIndex: Int) -> some View {
        let colors: [Color] = [
            Color(red: 0.72, green: 0.18, blue: 0.18),
            Color(red: 0.18, green: 0.35, blue: 0.65),
            Color(red: 0.18, green: 0.52, blue: 0.32),
            Color(red: 0.75, green: 0.55, blue: 0.20),
            Color(red: 0.45, green: 0.25, blue: 0.55),
            Color(red: 0.25, green: 0.25, blue: 0.25)
        ]
        
        let bookCount = (shelfIndex == 1) ? 5 : (shelfIndex == 2 ? 7 : 4)
        
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<bookCount, id: \.self) { i in
                let h = CGFloat(45 + (i * 7) % 25)
                let color = colors[(shelfIndex * 3 + i) % colors.count]
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 11, height: h)
                    .overlay(
                        VStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(height: 1.5)
                                .padding(.top, 4)
                            Spacer()
                        }
                    )
            }
            
            if shelfIndex == 3 {
                // Little potted cactus / succulent on top shelf
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green.opacity(0.9))
                    .padding(.leading, 4)
            }
        }
    }
    
    private var shelfWoodColor: Color {
        switch theme {
        case .library: return Color(red: 0.35, green: 0.20, blue: 0.12)
        case .kos: return Color(red: 0.68, green: 0.50, blue: 0.35)
        case .garden: return Color(red: 0.40, green: 0.26, blue: 0.16)
        }
    }
    
    private var shelfInteriorColor: Color {
        switch theme {
        case .library: return Color(red: 0.20, green: 0.12, blue: 0.08)
        case .kos: return Color(red: 0.88, green: 0.82, blue: 0.75)
        case .garden: return Color(red: 0.28, green: 0.18, blue: 0.12)
        }
    }
    
    private var shelfShadowColor: Color {
        Color.black.opacity(0.3)
    }
}

// MARK: - Leaning & Sliding Ladder View
struct LadderView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        Group {
            if let ladderImg = AssetLoader.image(named: "ladder") {
                Image(nsImage: ladderImg)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 50, height: 380)
            } else {
                proceduralLadder
            }
        }
        .offset(x: appState.ladderX)
        .gesture(
            DragGesture()
                .onChanged { val in
                    appState.ladderX += val.translation.width
                    appState.ladderX = max(-20, min(140, appState.ladderX))
                }
        )
        .help("Geser tangga ke kiri atau kanan")
    }
    
    private var proceduralLadder: some View {
        ZStack {
            // Two rails
            HStack(spacing: 28) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.45, green: 0.28, blue: 0.16))
                    .frame(width: 5, height: 380)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.45, green: 0.28, blue: 0.16))
                    .frame(width: 5, height: 380)
            }
            
            // Rungs
            VStack(spacing: 36) {
                ForEach(0..<9, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color(red: 0.38, green: 0.22, blue: 0.12))
                        .frame(width: 34, height: 4)
                }
            }
        }
        .rotationEffect(.degrees(-6))
    }
}

// MARK: - Bookshelf Drawer View (Opens when Bookshelf is Clicked)
public struct BookshelfDrawerView: View {
    @ObservedObject var storage = StorageManager.shared
    @Binding var isPresented: Bool
    
    let bookColors: [Color] = [
        Color(red: 0.65, green: 0.15, blue: 0.15),
        Color(red: 0.15, green: 0.35, blue: 0.65),
        Color(red: 0.15, green: 0.50, blue: 0.30),
        Color(red: 0.70, green: 0.50, blue: 0.18),
        Color(red: 0.45, green: 0.22, blue: 0.55),
        Color(red: 0.30, green: 0.20, blue: 0.15),
        Color(red: 0.20, green: 0.45, blue: 0.55)
    ]
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.brown)
                Text("Lemari & Rak Organizer (\(storage.bookshelfItems.count) Item)")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Button(action: {
                    storage.pickBookshelfItem()
                }) {
                    Label("Tambah File/Folder", systemImage: "plus")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    storage.openInFinder(url: storage.bookshelfDirectory)
                }) {
                    Label("Buka di Finder", systemImage: "folder.fill")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Shelf contents
            ScrollView(.horizontal, showsIndicators: true) {
                if storage.bookshelfItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("Lemari masih kosong.")
                            .font(.headline)
                        Text("Tarik file (akan jadi Buku) atau folder (akan jadi Kardus Arsip) ke sini!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .padding()
                } else {
                    HStack(alignment: .bottom, spacing: 14) {
                        ForEach(Array(storage.bookshelfItems.enumerated()), id: \.element) { index, fileURL in
                            let isFolder = fileURL.hasDirectoryPath || (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
                            let color = bookColors[index % bookColors.count]
                            
                            Button(action: {
                                storage.openInFinder(url: fileURL)
                            }) {
                                if isFolder {
                                    // Kardus Arsip (Archive Box for Folders)
                                    ArchiveBoxView(title: fileURL.lastPathComponent)
                                } else {
                                    // Buku Bersampul (Book Spine for Files)
                                    BookSpineView(title: fileURL.lastPathComponent, color: color)
                                }
                            }
                            .buttonStyle(.plain)
                            .help("Klik untuk membuka: \(fileURL.lastPathComponent)")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .frame(height: 280)
            .background(Color(NSColor.underPageBackgroundColor))
        }
        .frame(width: 720, height: 360)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
    }
}

// MARK: - Kardus Arsip View (Untuk Folder, persis seperti di video)
struct ArchiveBoxView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack {
                // Brown Cardboard Box Body
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.78, green: 0.63, blue: 0.44))
                    .frame(width: 76, height: 180)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(red: 0.58, green: 0.44, blue: 0.28), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                
                VStack(spacing: 8) {
                    // Box Top Flap fold line
                    Rectangle()
                        .fill(Color(red: 0.65, green: 0.50, blue: 0.32))
                        .frame(height: 4)
                        .padding(.top, 12)
                    
                    // Oval Hand Cutout
                    Capsule()
                        .fill(Color(red: 0.38, green: 0.26, blue: 0.16))
                        .frame(width: 26, height: 8)
                        .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                    
                    Spacer()
                    
                    // White Shipping/Archive Label with Title
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(white: 0.95))
                            .frame(width: 62, height: 85)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            )
                        
                        VStack(spacing: 2) {
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.55, green: 0.38, blue: 0.22))
                            
                            Text(title)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Barcode lines at bottom
                    HStack(spacing: 2) {
                        ForEach(0..<8) { i in
                            Rectangle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: i % 2 == 0 ? 1.5 : 2.5, height: 8)
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
            
            Text("Kardus Arsip")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
}

// MARK: - Book Spine View (Untuk File)
struct BookSpineView: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 52, height: 210)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                
                // Gold foil bands
                VStack {
                    Rectangle()
                        .fill(Color(red: 0.95, green: 0.85, blue: 0.45))
                        .frame(height: 3)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // Vertical title text
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 140)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color(red: 0.95, green: 0.85, blue: 0.45))
                        .frame(height: 3)
                        .padding(.bottom, 10)
                }
            }
            
            Text("Buku File")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
}
