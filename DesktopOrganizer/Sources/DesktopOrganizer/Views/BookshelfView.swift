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
                
                // Empty state prompt on shelf when no items are added
                if storage.bookshelfItems.isEmpty {
                    VStack(spacing: 3) {
                        Text("Tarik file ke sini")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        Text("jadi buku 📚")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(SANSColors.lime)
                        Text("Folder jadi kardus arsip 🗃️")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(SANSColors.cleanWhite.opacity(0.9))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.70))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SANSColors.lime.opacity(0.4), lineWidth: 1))
                    )
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    .position(x: w * 0.48, y: h * 0.25)
                    .allowsHitTesting(false)
                }
                
                
                let shelfWidth = w * 0.90
                let rowHeight: CGFloat = 114
                let plankY: [CGFloat] = [
                    h * 0.491,
                    h * 0.928
                ]
                let distributedShelves = itemsForShelves(totalWidth: shelfWidth)
                
                ForEach(0..<2, id: \.self) { i in
                    shelfRow(items: distributedShelves[i], width: shelfWidth, rowHeight: rowHeight, shelfIndex: i)
                        .position(x: w * 0.50, y: plankY[i] - (rowHeight / 2))
                }
                
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
    
    // Distribute files & folders across the 2 shelves based on available shelf width
    private func itemsForShelves(totalWidth: CGFloat) -> [[URL]] {
        var shelves: [[URL]] = [[], []]
        var currentShelf = 0
        var currentWidth: CGFloat = 0
        let spacing: CGFloat = 1
        
        for url in storage.bookshelfItems {
            let isFolder = ShelfItemView.isFolder(url)
            let itemWidth: CGFloat = isFolder ? 72 : 26
            
            if currentWidth + itemWidth > totalWidth && !shelves[currentShelf].isEmpty {
                currentShelf += 1
                if currentShelf >= 2 { break }
                currentWidth = 0
            }
            
            shelves[currentShelf].append(url)
            currentWidth += itemWidth + spacing
        }
        
        return shelves
    }
    
    @ViewBuilder
    private func shelfRow(items: [URL], width: CGFloat, rowHeight: CGFloat, shelfIndex: Int) -> some View {
        HStack(alignment: .bottom, spacing: 1) {
            ForEach(items, id: \.self) { url in
                ShelfItemView(url: url, theme: theme, shelfIndex: shelfIndex)
            }
            Spacer()
        }
        .frame(width: width, height: rowHeight, alignment: .bottomLeading)
        .padding(.horizontal, 8)
    }
}

// MARK: - Shelf Item View (Authentic Desktop Organizer Books & Archive Boxes)
struct ShelfItemView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let url: URL
    let theme: RoomTheme
    let shelfIndex: Int
    let isFolder: Bool
    let bookHeight: CGFloat

    init(url: URL, theme: RoomTheme, shelfIndex: Int) {
        self.url = url
        self.theme = theme
        self.shelfIndex = shelfIndex
        self.isFolder = ShelfItemView.isFolder(url)
        self.bookHeight = ShelfItemView.calculateBookHeight(for: url)
    }

    // Check if an item is a true folder (not an application .app bundle or file package)
    public static func isFolder(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue else {
            return false
        }
        // Application bundles (.app) and file packages are single applications/files -> represented as books
        if url.pathExtension.lowercased() == "app" || NSWorkspace.shared.isFilePackage(atPath: url.path) {
            return false
        }
        return true
    }

    public static func calculateBookHeight(for url: URL) -> CGFloat {
        var fileBytes = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        if fileBytes <= 4096, url.pathExtension.lowercased() == "app" {
            let appName = url.deletingPathExtension().lastPathComponent
            let binURL = url.appendingPathComponent("Contents/MacOS/\(appName)")
            if let binSize = (try? FileManager.default.attributesOfItem(atPath: binURL.path)[.size] as? Int64), binSize > 0 {
                fileBytes = binSize
            } else {
                fileBytes = 40 * 1024 * 1024 // 40MB app standard
            }
        }
        let bytes = max(Double(fileBytes), 1024.0)
        let logVal = log10(bytes)
        let normalized = min(max((logVal - 3.0) / 5.0, 0.0), 1.0)
        return 64 + CGFloat(normalized) * 38
    }

    var body: some View {
        Group {
            if isFolder { folderView } else { fileView }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            NSWorkspace.shared.open(url)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                if appState.activeShelfPopoverURL == url {
                    appState.activeShelfPopoverURL = nil
                } else {
                    appState.activeShelfPopoverURL = url
                    appState.activeShelfIndex = shelfIndex
                }
            }
        }
        .contextMenu {
            Button("Buka") { NSWorkspace.shared.open(url) }
            Button("Tampilkan di Finder") { storage.openInFinder(url: url) }
            Divider()
            Button("Kembalikan ke Desktop") { storage.restoreBookshelfItemToDesktop(itemURL: url) }
            Button("Buang ke Tempat Sampah", role: .destructive) { storage.removeBookshelfItem(itemURL: url) }
        }
        .help("\(url.lastPathComponent) (Klik untuk melihat info/file terbaru, klik 2x untuk membuka)")
    }

    // Classic library palette for book spines
    private static let bookColors: [Color] = [
        Color(red: 0.58, green: 0.16, blue: 0.18), // Crimson Wine
        Color(red: 0.14, green: 0.22, blue: 0.35), // Prussian Navy
        Color(red: 0.16, green: 0.34, blue: 0.22), // Forest Green
        Color(red: 0.68, green: 0.42, blue: 0.15), // Warm Ochre
        Color(red: 0.20, green: 0.22, blue: 0.25), // Dark Charcoal
        Color(red: 0.45, green: 0.16, blue: 0.40), // Vintage Plum
        Color(red: 0.65, green: 0.28, blue: 0.18)  // Terracotta
    ]

    // File → Authentic Book Spine. Height scales with file size (heavier = taller).
    private var fileView: some View {
        let colorIdx = abs(url.lastPathComponent.hashValue) % ShelfItemView.bookColors.count
        let color = ShelfItemView.bookColors[colorIdx]
        let label = url.deletingPathExtension().lastPathComponent
        let bookWidth: CGFloat = 26

        return ZStack(alignment: .bottom) {
            ZStack(alignment: .center) {
                // Book spine curvature gradient
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.88),
                                color,
                                color.opacity(0.82)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.6)
                    )
                    .frame(width: bookWidth, height: bookHeight)

                // Gold foil embossed accent lines (2 top, 2 bottom)
                VStack {
                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color(red: 0.92, green: 0.82, blue: 0.55).opacity(0.75))
                            .frame(height: 1)
                        Rectangle()
                            .fill(Color(red: 0.92, green: 0.82, blue: 0.55).opacity(0.75))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 6)

                    Spacer()

                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color(red: 0.92, green: 0.82, blue: 0.55).opacity(0.75))
                            .frame(height: 1)
                        Rectangle()
                            .fill(Color(red: 0.92, green: 0.82, blue: 0.55).opacity(0.75))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 6)
                }
                .frame(width: bookWidth, height: bookHeight)

                // Rotated Spine Title Text
                Text(label)
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(Color(red: 0.97, green: 0.95, blue: 0.90))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.55)
                    .frame(width: bookHeight - 24, height: bookWidth)
                    .rotationEffect(.degrees(-90))
                    .frame(width: bookWidth, height: bookHeight)
                    .shadow(color: .black.opacity(0.75), radius: 1, y: 1)
                    .allowsHitTesting(false)
            }
            .frame(width: bookWidth, height: bookHeight)
            .clipped()
            .shadow(color: .black.opacity(0.25), radius: 3, y: 3)
        }
        .frame(width: bookWidth, height: bookHeight)
    }

    // Folder → Kraft Archive Box. Height scales with number of items inside (heavier folder = taller box).
    private var folderView: some View {
        let subItems = (try? FileManager.default.contentsOfDirectory(atPath: url.path))?.count ?? 0
        let label = url.lastPathComponent
        let boxWidth: CGFloat = 72
        
        // Map item count → box height 64–102pt; heavier folder with more files = taller archive box
        // shortcut: counts top-level items with sqrt scaling for instant 60fps render without disk blocking; when to upgrade: if recursive byte sum is cached in background
        let normalized = min(sqrt(Double(subItems)) / 6.0, 1.0)
        let boxHeight: CGFloat = 64 + CGFloat(normalized) * 38

        return ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                // Cardboard box body
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.77, green: 0.59, blue: 0.41),
                                Color(red: 0.69, green: 0.51, blue: 0.34)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(red: 0.52, green: 0.38, blue: 0.24), lineWidth: 0.8)
                    )

                // Top lid fold flap
                Rectangle()
                    .fill(Color(red: 0.62, green: 0.44, blue: 0.28))
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .padding(.horizontal, 2)
                    .padding(.top, 2)

                // Front white paper label card
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.97, green: 0.97, blue: 0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(red: 0.74, green: 0.70, blue: 0.65), lineWidth: 0.7)
                    )
                    .frame(width: boxWidth * 0.85, height: min(38, boxHeight - 20))
                    .overlay(
                        VStack(spacing: 2) {
                            Text(label)
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(Color(red: 0.15, green: 0.12, blue: 0.10))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.65)

                            Text("\(subItems) file")
                                .font(.system(size: 7.5, weight: .medium))
                                .foregroundColor(Color(red: 0.45, green: 0.42, blue: 0.38))
                        }
                        .padding(.horizontal, 3)
                    )
                    .padding(.top, 18)
            }
            .frame(width: boxWidth, height: boxHeight)
            .shadow(color: .black.opacity(0.22), radius: 3, y: 3)
        }
        .frame(width: boxWidth, height: boxHeight)
    }
}

// MARK: - File Rack Popup View (Shows latest files, metadata, and quick actions)
public struct BookshelfDrawerView: View {
    @ObservedObject var storage = StorageManager.shared
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    // Sort items by modification date (newest first)
    private var sortedRecentItems: [URL] {
        storage.bookshelfItems.sorted { url1, url2 in
            let date1 = (try? FileManager.default.attributesOfItem(atPath: url1.path)[.modificationDate] as? Date) ?? Date.distantPast
            let date2 = (try? FileManager.default.attributesOfItem(atPath: url2.path)[.modificationDate] as? Date) ?? Date.distantPast
            return date1 > date2
        }
    }
    
    private func formattedDate(for url: URL) -> String {
        guard let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
              let date = attr[.modificationDate] as? Date else {
            return "Baru saja"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func itemSubtitle(for url: URL) -> String {
        if ShelfItemView.isFolder(url) {
            let count = (try? FileManager.default.contentsOfDirectory(atPath: url.path))?.count ?? 0
            return "Kardus Arsip • \(count) file"
        } else {
            let ext = url.pathExtension.uppercased()
            let kind = ext == "APP" ? "Aplikasi" : (ext.isEmpty ? "Dokumen" : ext)
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            let formattedSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            return "Buku • \(kind) • \(formattedSize)"
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "books.vertical.fill")
                        .foregroundColor(SANSColors.lime)
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rak File Desktop")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(storage.bookshelfItems.count) item tersimpan • Menampilkan file terbaru")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        storage.pickBookshelfItem()
                    }) {
                        Label("Tambah File", systemImage: "plus")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SANSColors.primaryBlue)
                    
                    Button(action: {
                        storage.openBaseFolder()
                    }) {
                        Label("Buka di Finder", systemImage: "folder")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.bordered)
                    
                    if !storage.bookshelfItems.isEmpty {
                        Button(action: {
                            storage.restoreAllBookshelfItems()
                        }) {
                            Text("Kembalikan Semua")
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
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.35))
            
            Divider()
                .background(Color.white.opacity(0.12))
            
            // Content
            if storage.bookshelfItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 42))
                        .foregroundColor(.white.opacity(0.35))
                    Text("Rak buku masih kosong.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                    Text("Seret file atau folder dari desktop ke lemari buku untuk menyimpannya.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SANSColors.lime)
                        Text("File & Folder Terbaru di Rak")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SANSColors.lime)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(sortedRecentItems, id: \.self) { item in
                                let isFolder = ShelfItemView.isFolder(item)
                                let isApp = item.pathExtension.lowercased() == "app"
                                
                                HStack(spacing: 12) {
                                    // Visual badge
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isFolder ? Color(red: 0.72, green: 0.54, blue: 0.36).opacity(0.3) : (isApp ? Color.purple.opacity(0.3) : SANSColors.primaryBlue.opacity(0.3)))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: isFolder ? "archivebox.fill" : (isApp ? "app.fill" : "doc.text.fill"))
                                            .font(.system(size: 16))
                                            .foregroundColor(isFolder ? Color(red: 0.95, green: 0.82, blue: 0.60) : (isApp ? Color.purple : Color.cyan))
                                    }
                                    
                                    // Name & info
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.lastPathComponent)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 4) {
                                            Text(itemSubtitle(for: item))
                                                .font(.system(size: 10))
                                                .foregroundColor(.white.opacity(0.65))
                                            Text("•")
                                                .font(.system(size: 9))
                                                .foregroundColor(.white.opacity(0.4))
                                            Text(formattedDate(for: item))
                                                .font(.system(size: 10))
                                                .foregroundColor(SANSColors.lime.opacity(0.9))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Quick action buttons
                                    HStack(spacing: 6) {
                                        Button(action: {
                                            NSWorkspace.shared.open(item)
                                            withAnimation { isPresented = false }
                                        }) {
                                            Text("Buka")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Capsule().fill(SANSColors.primaryBlue))
                                        }
                                        .buttonStyle(.plain)
                                        .help("Buka file ini")
                                        
                                        Button(action: {
                                            storage.openInFinder(url: item)
                                        }) {
                                            Image(systemName: "folder")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.8))
                                                .frame(width: 26, height: 26)
                                                .background(Circle().fill(Color.white.opacity(0.12)))
                                        }
                                        .buttonStyle(.plain)
                                        .help("Tampilkan di Finder")
                                        
                                        Button(action: {
                                            storage.restoreBookshelfItemToDesktop(itemURL: item)
                                        }) {
                                            Image(systemName: "arrow.up.forward.app")
                                                .font(.system(size: 12))
                                                .foregroundColor(.yellow)
                                                .frame(width: 26, height: 26)
                                                .background(Circle().fill(Color.white.opacity(0.12)))
                                        }
                                        .buttonStyle(.plain)
                                        .help("Kembalikan ke Desktop")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .frame(width: 600, height: 420)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.97))
                .shadow(color: .black.opacity(0.6), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
}
