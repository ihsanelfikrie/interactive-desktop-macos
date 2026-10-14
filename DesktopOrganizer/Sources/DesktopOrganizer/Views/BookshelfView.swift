import SwiftUI
import UniformTypeIdentifiers
import AppKit

public struct BookshelfView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let theme: RoomTheme
    
    public init(theme: RoomTheme) {
        self.theme = theme
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack(alignment: .topLeading) {
                // Drop Target Area (Spans the entire bookcase interior)
                Rectangle()
                    .fill(appState.isBookshelfTargeted ? SANSColors.primaryBlue.opacity(0.18) : Color.clear)
                    .overlay(
                        Group {
                            if appState.isBookshelfTargeted {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(SANSColors.lime, lineWidth: 3)
                                    .overlay(
                                        VStack(spacing: 6) {
                                            Image(systemName: "square.and.arrow.down.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(SANSColors.lime)
                                            Text("Simpan ke Rak Buku SANS")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                                .shadow(color: .black, radius: 4)
                                        }
                                    )
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            appState.showBookshelfDrawer = true
                        }
                    }
                    .contextMenu {
                        Button("Buka Rak Buku") {
                            withAnimation(.spring()) {
                                appState.showBookshelfDrawer = true
                            }
                        }
                        Button("Tambah File/Folder...") {
                            storage.pickBookshelfItem()
                        }
                        Button("Buka di Finder") {
                            storage.openBaseFolder()
                        }
                        if !storage.bookshelfItems.isEmpty {
                            Divider()
                            Button("Kembalikan Semua ke Desktop") {
                                storage.restoreAllBookshelfItems()
                            }
                        }
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
                
                // 5 Interactive Shelf Levels (Flushed exactly onto the 5 white shelf planks)
                // Shelves 0, 1, 2: 100% Books (stacked full, folder/file names on covers)
                // Shelves 3, 4: 100% Cardboard Archive Boxes (folder names on front labels)
                // Shelf 0 (top plank)
                shelfRow(shelfIndex: 0, width: w * 0.90)
                    .position(x: w * 0.48, y: h * 0.140)
                
                // Shelf 1
                shelfRow(shelfIndex: 1, width: w * 0.90)
                    .position(x: w * 0.48, y: h * 0.330)
                
                // Shelf 2
                shelfRow(shelfIndex: 2, width: w * 0.90)
                    .position(x: w * 0.48, y: h * 0.520)
                
                // Shelf 3
                shelfRow(shelfIndex: 3, width: w * 0.90)
                    .position(x: w * 0.48, y: h * 0.710)
                
                // Shelf 4 (bottom plank)
                shelfRow(shelfIndex: 4, width: w * 0.88)
                    .position(x: w * 0.48, y: h * 0.900)
                
                // Item Count Badge (Top-right of bookcase)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            appState.showBookshelfDrawer = true
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "books.vertical.fill")
                                    .font(.system(size: 9))
                                Text("\(storage.bookshelfItems.count)")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.black.opacity(0.65)))
                        }
                        .buttonStyle(.plain)
                        .help("Buka Rak Buku di Laci / Finder")
                        .padding(6)
                    }
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Book & Box Color Palettes and Companion Metadata
    private let bookColors: [Color] = [
        Color(red: 0.65, green: 0.18, blue: 0.20), // Crimson Wine
        Color(red: 0.15, green: 0.22, blue: 0.35), // Prussian Navy
        Color(red: 0.16, green: 0.34, blue: 0.24), // Forest Green
        Color(red: 0.72, green: 0.44, blue: 0.14), // Amber Ochre
        Color(red: 0.20, green: 0.22, blue: 0.25), // Dark Charcoal
        Color(red: 0.52, green: 0.28, blue: 0.40), // Vintage Mauve
        Color(red: 0.70, green: 0.32, blue: 0.20), // Terracotta
        Color(red: 0.20, green: 0.38, blue: 0.42), // Slate Teal
        Color(red: 0.38, green: 0.22, blue: 0.45), // Deep Plum
        Color(red: 0.35, green: 0.42, blue: 0.25)  // Olive Sage
    ]
    
    private let bookHeights: [CGFloat] = [54, 56, 52, 57, 53, 55, 52, 56, 54, 55]
    
    private let companionBookTitles: [String] = [
        "Skripsi Bab 2",
        "Moodboard",
        "Tiket Pesawat",
        "Desain Logo",
        "Foto Produk",
        "Arsip 2025",
        "Laporan Q3",
        "Proposal Klien",
        "Catatan Kuliah",
        "Invoice Okt",
        "Resep Masak",
        "Kontrak Kerja",
        "Ide Konten",
        "Budget 2026",
        "CV Terbaru",
        "Jadwal Shoot",
        "Portofolio",
        "Dokumen",
        "Project AG",
        "Asset Gambar",
        "Sertifikat",
        "Draft Artikel",
        "Bahan Riset",
        "Source Code",
        "Backup Mac",
        "Materi Belajar",
        "Reading List",
        "Finansial",
        "Ide Bisnis",
        "Referensi UI"
    ]
    
    private let companionBoxTitles: [String] = [
        "Arsip\nProject",
        "Dokumen\nLegal",
        "Desain &\nIlustrasi",
        "Photo Raw\nArchive",
        "Backup\nDatabase",
        "Invoice &\nResi",
        "File\nDownload",
        "Koleksi\nE-Book"
    ]
    
    @ViewBuilder
    private func shelfRow(shelfIndex: Int, width: CGFloat) -> some View {
        if shelfIndex < 3 {
            // Shelves 0, 1, 2: 100% Books (10 books per shelf = 30 books total)
            booksRow(shelfIndex: shelfIndex, width: width)
        } else {
            // Shelves 3, 4: 100% Cardboard Archive Boxes (4 boxes per shelf = 8 boxes total)
            boxesRow(shelfIndex: shelfIndex, width: width)
        }
    }
    
    @ViewBuilder
    private func booksRow(shelfIndex: Int, width: CGFloat) -> some View {
        let booksPerShelf = 10
        let bookWidth = (width - 40) / CGFloat(booksPerShelf)
        
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<booksPerShelf, id: \.self) { i in
                let globalIndex = shelfIndex * booksPerShelf + i
                let userItem = globalIndex < storage.bookshelfItems.count ? storage.bookshelfItems[globalIndex] : nil
                let title = userItem?.deletingPathExtension().lastPathComponent ?? companionBookTitles[globalIndex % companionBookTitles.count]
                let color = bookColors[globalIndex % bookColors.count]
                let height = bookHeights[globalIndex % bookHeights.count]
                let id = "book-\(globalIndex)"
                
                BookSpineView(
                    id: id,
                    title: title,
                    url: userItem,
                    color: color,
                    bookWidth: bookWidth,
                    bookHeight: height
                )
            }
        }
        .frame(width: width, height: 60, alignment: .bottomLeading)
        .padding(.horizontal, 6)
    }
    
    @ViewBuilder
    private func boxesRow(shelfIndex: Int, width: CGFloat) -> some View {
        let boxShelfIndex = shelfIndex - 3 // 0 for shelf 3, 1 for shelf 4
        let boxesPerShelf = 4
        let boxWidth = (width - 36) / CGFloat(boxesPerShelf)
        
        // Find real user directories from storage.bookshelfItems
        let userDirectories = storage.bookshelfItems.filter { url in
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            return isDir.boolValue
        }
        
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<boxesPerShelf, id: \.self) { i in
                let globalIndex = boxShelfIndex * boxesPerShelf + i
                let userDir = globalIndex < userDirectories.count ? userDirectories[globalIndex] : nil
                let title: String = {
                    if let userDir = userDir {
                        let raw = userDir.lastPathComponent
                        let words = raw.split(separator: " ")
                        if words.count >= 2 {
                            return "\(words[0])\n\(words.dropFirst().joined(separator: " "))"
                        }
                        return raw
                    }
                    return companionBoxTitles[globalIndex % companionBoxTitles.count]
                }()
                let id = "box-\(globalIndex)"
                
                ArchiveBoxView(
                    id: id,
                    title: title,
                    url: userDir,
                    boxWidth: boxWidth
                )
            }
        }
        .frame(width: width, height: 60, alignment: .bottomLeading)
        .padding(.horizontal, 6)
    }
}

// MARK: - Book Spine View (Top Shelves 1-3: Books with Folder/File Title on Spine)
struct BookSpineView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var storage = StorageManager.shared
    let id: String
    let title: String
    let url: URL?
    let color: Color
    let bookWidth: CGFloat
    let bookHeight: CGFloat
    
    var isHovered: Bool {
        appState.hoveredShelfItemId == id
    }
    
    var isDirectory: Bool {
        guard let url = url else { return false }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // Main book spine body with subtle curvature gradient
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.92),
                            color,
                            color.opacity(0.85)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(isHovered ? Color.white : Color.white.opacity(0.25), lineWidth: isHovered ? 1.5 : 0.6)
                )
            
            // Spine gold / embossed accent bands (top and bottom)
            VStack {
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 1)
                    .padding(.horizontal, 2)
                    .padding(.top, 4)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 1)
                    .padding(.horizontal, 2)
                    .padding(.bottom, 4)
            }
            
            // Vertical spine title text (reads bottom to top along the spine)
            Text(title)
                .font(.system(size: 7.5, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .frame(width: bookHeight - 6)
                .rotationEffect(.degrees(-90))
                .shadow(color: .black.opacity(0.6), radius: 1, y: 1)
            
            // Hover Tooltip Tag
            if isHovered {
                VStack(spacing: 2) {
                    Text(url != nil ? (isDirectory ? "📁 " : "📄 ") + (url?.lastPathComponent ?? title) : "📚 " + title)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if url != nil {
                        Text(isDirectory ? "Folder di Rak" : "File di Rak")
                            .font(.system(size: 7.5))
                            .foregroundColor(SANSColors.lime)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.88)))
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                .offset(y: -bookHeight / 2 - 18)
                .allowsHitTesting(false)
                .zIndex(30)
            }
        }
        .frame(width: bookWidth, height: bookHeight)
        .shadow(color: .black.opacity(isHovered ? 0.45 : 0.22), radius: isHovered ? 3 : 1.5, y: 1)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .contentShape(Rectangle())
        .onHover { hovering in
            if hovering {
                appState.hoveredShelfItemId = id
            } else if appState.hoveredShelfItemId == id {
                appState.hoveredShelfItemId = nil
            }
        }
        .onTapGesture(count: 2) {
            handleOpen()
        }
        .onTapGesture(count: 1) {
            handleOpen()
        }
        .contextMenu {
            if let url = url {
                Button("Buka") {
                    NSWorkspace.shared.open(url)
                }
                Button("Tampilkan di Finder") {
                    storage.openInFinder(url: url)
                }
                Divider()
                Button("Kembalikan ke Desktop") {
                    storage.restoreBookshelfItemToDesktop(itemURL: url)
                }
                Button("Buang ke Tempat Sampah", role: .destructive) {
                    storage.removeBookshelfItem(itemURL: url)
                }
            } else {
                Button("Buka Rak Buku di Finder") {
                    storage.openBaseFolder()
                }
                Button("Tambah File / Folder ke Rak...") {
                    storage.pickBookshelfItem()
                }
                Divider()
                Button("Buka Laci Rak Buku") {
                    withAnimation(.spring()) {
                        appState.showBookshelfDrawer = true
                    }
                }
            }
        }
        .help(url?.lastPathComponent ?? title)
    }
    
    private func handleOpen() {
        if let url = url {
            NSWorkspace.shared.open(url)
        } else {
            storage.openBaseFolder()
        }
    }
}

// MARK: - Archive Box View (Bottom Shelves 4-5: Cardboard Boxes with Folder Label Sticker)
struct ArchiveBoxView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var storage = StorageManager.shared
    let id: String
    let title: String
    let url: URL?
    let boxWidth: CGFloat
    
    var isHovered: Bool {
        appState.hoveredShelfItemId == id
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main kraft cardboard body
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.77, green: 0.60, blue: 0.42),
                            Color(red: 0.71, green: 0.54, blue: 0.36)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isHovered ? Color.white : Color(red: 0.55, green: 0.40, blue: 0.25), lineWidth: isHovered ? 1.5 : 0.8)
                )
            
            // Top lid fold flap
            Rectangle()
                .fill(Color(red: 0.65, green: 0.48, blue: 0.32))
                .frame(height: 6)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.horizontal, 2)
                .padding(.top, 2)
            
            // Front white label card
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.95, green: 0.97, blue: 1.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(red: 0.65, green: 0.72, blue: 0.82), lineWidth: 0.8)
                )
                .frame(width: boxWidth * 0.84, height: 26)
                .overlay(
                    Text(title)
                        .font(.system(size: 7.5, weight: .bold))
                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.28))
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 3)
                )
                .padding(.top, 12)
            
            // Hover Tooltip Tag
            if isHovered {
                VStack(spacing: 2) {
                    Text("🗃️ " + (url?.lastPathComponent ?? title.replacingOccurrences(of: "\n", with: " ")))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if url != nil {
                        Text("Folder Kardus Arsip")
                            .font(.system(size: 7.5))
                            .foregroundColor(SANSColors.lime)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.88)))
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                .offset(y: -42)
                .allowsHitTesting(false)
                .zIndex(30)
            }
        }
        .frame(width: boxWidth, height: 44)
        .shadow(color: .black.opacity(isHovered ? 0.35 : 0.15), radius: isHovered ? 4 : 2, y: 1.5)
        .scaleEffect(isHovered ? 1.04 : 1.0)
        .contentShape(Rectangle())
        .onHover { hovering in
            if hovering {
                appState.hoveredShelfItemId = id
            } else if appState.hoveredShelfItemId == id {
                appState.hoveredShelfItemId = nil
            }
        }
        .onTapGesture(count: 2) {
            handleOpen()
        }
        .onTapGesture(count: 1) {
            handleOpen()
        }
        .contextMenu {
            if let url = url {
                Button("Buka Folder") {
                    NSWorkspace.shared.open(url)
                }
                Button("Tampilkan di Finder") {
                    storage.openInFinder(url: url)
                }
                Divider()
                Button("Kembalikan ke Desktop") {
                    storage.restoreBookshelfItemToDesktop(itemURL: url)
                }
                Button("Buang ke Tempat Sampah", role: .destructive) {
                    storage.removeBookshelfItem(itemURL: url)
                }
            } else {
                Button("Buka Rak Buku di Finder") {
                    storage.openBaseFolder()
                }
                Button("Tambah Folder ke Rak...") {
                    storage.pickBookshelfItem()
                }
                Divider()
                Button("Buka Laci Rak Buku") {
                    withAnimation(.spring()) {
                        appState.showBookshelfDrawer = true
                    }
                }
            }
        }
        .help(url?.lastPathComponent ?? title.replacingOccurrences(of: "\n", with: " "))
    }
    
    private func handleOpen() {
        if let url = url {
            NSWorkspace.shared.open(url)
        } else {
            storage.openBaseFolder()
        }
    }
}

// MARK: - Bookshelf Drawer View (Opens when Bookshelf is Clicked)
public struct BookshelfDrawerView: View {
    @ObservedObject var storage = StorageManager.shared
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "books.vertical.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18))
                
                Text("Koleksi Rak Buku (\(storage.bookshelfItems.count) Item)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    storage.pickBookshelfItem()
                }) {
                    Label("Tambah File", systemImage: "plus")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
                
                Button(action: {
                    storage.openBaseFolder()
                }) {
                    Text("Buka di Finder")
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                
                if !storage.bookshelfItems.isEmpty {
                    Button(action: {
                        storage.restoreAllBookshelfItems()
                    }) {
                        Text("Kembalikan Semua ke Desktop")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.3))
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Content List
            if storage.bookshelfItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 42))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Rak buku masih kosong.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Seret file atau folder dari desktop ke rak buku untuk merapikannya.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 14)], spacing: 14) {
                        ForEach(storage.bookshelfItems, id: \.self) { item in
                            VStack(spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    Button(action: {
                                        NSWorkspace.shared.open(item)
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: item.hasDirectoryPath ? "folder.fill" : "doc.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(item.hasDirectoryPath ? .yellow : .cyan)
                                            
                                            Text(item.lastPathComponent)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 90, height: 80)
                                        .padding(8)
                                        .background(Color.white.opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button(action: {
                                        storage.restoreBookshelfItemToDesktop(itemURL: item)
                                    }) {
                                        Image(systemName: "arrow.up.forward.app.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.yellow)
                                            .background(Circle().fill(Color.black))
                                    }
                                    .buttonStyle(.plain)
                                    .offset(x: 4, y: -4)
                                    .help("Kembalikan ke Desktop")
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 580, height: 380)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.16, green: 0.14, blue: 0.12).opacity(0.96))
                .shadow(color: .black.opacity(0.6), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
