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
        let spacing: CGFloat = 1.5
        
        for url in storage.bookshelfItems {
            let isFolder = ShelfItemView.isFolder(url)
            let itemWidth = ShelfItemView.calculateItemWidth(for: url, isFolder: isFolder)
            
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
        HStack(alignment: .bottom, spacing: 1.5) {
            ForEach(Array(items.enumerated()), id: \.element) { index, url in
                ShelfItemView(url: url, theme: theme, shelfIndex: shelfIndex, itemIndex: index)
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
    let itemIndex: Int
    let isFolder: Bool
    let bookHeight: CGFloat
    let itemWidth: CGFloat
    let subItemsCount: Int

    init(url: URL, theme: RoomTheme, shelfIndex: Int, itemIndex: Int = 0) {
        self.url = url
        self.theme = theme
        self.shelfIndex = shelfIndex
        self.itemIndex = itemIndex
        let isDir = ShelfItemView.isFolder(url)
        self.isFolder = isDir
        if isDir {
            let count = (try? FileManager.default.contentsOfDirectory(atPath: url.path))?.count ?? 0
            self.subItemsCount = count
            self.itemWidth = ShelfItemView.calculateItemWidth(for: url, isFolder: true, subItemsCount: count)
        } else {
            self.subItemsCount = 0
            self.itemWidth = ShelfItemView.calculateItemWidth(for: url, isFolder: false, subItemsCount: 0)
        }
        self.bookHeight = ShelfItemView.calculateBookHeight(for: url)
    }

    // Check if an item is a true folder (not an application .app bundle or file package)
    public static func isFolder(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue else {
            return false
        }
        if url.pathExtension.lowercased() == "app" || NSWorkspace.shared.isFilePackage(atPath: url.path) {
            return false
        }
        return true
    }

    public static func calculateItemWidth(for url: URL, isFolder: Bool, subItemsCount: Int = -1) -> CGFloat {
        if isFolder {
            let subItems = subItemsCount >= 0 ? subItemsCount : ((try? FileManager.default.contentsOfDirectory(atPath: url.path))?.count ?? 0)
            if subItems > 35 {
                return 80
            } else if subItems > 10 {
                return 72
            } else {
                return 64
            }
        } else {
            let seed = abs(url.lastPathComponent.hashValue)
            let widths: [CGFloat] = [23, 26, 29, 33, 24]
            return widths[seed % widths.count]
        }
    }

    public static func calculateBookHeight(for url: URL) -> CGFloat {
        var fileBytes = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        if fileBytes <= 4096, url.pathExtension.lowercased() == "app" {
            let appName = url.deletingPathExtension().lastPathComponent
            let binURL = url.appendingPathComponent("Contents/MacOS/\(appName)")
            if let binSize = (try? FileManager.default.attributesOfItem(atPath: binURL.path)[.size] as? Int64), binSize > 0 {
                fileBytes = binSize
            } else {
                fileBytes = 40 * 1024 * 1024
            }
        }
        let bytes = max(Double(fileBytes), 1024.0)
        let logVal = log10(bytes)
        let normalized = min(max((logVal - 3.0) / 5.0, 0.0), 1.0)
        return 65 + CGFloat(normalized) * 36
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

    // Classic rich library palette for book spines
    private static let bookColors: [Color] = [
        Color(red: 0.58, green: 0.16, blue: 0.18), // Crimson Wine
        Color(red: 0.14, green: 0.22, blue: 0.35), // Prussian Navy
        Color(red: 0.16, green: 0.34, blue: 0.22), // Forest Green
        Color(red: 0.72, green: 0.44, blue: 0.15), // Warm Ochre
        Color(red: 0.20, green: 0.22, blue: 0.26), // Dark Charcoal
        Color(red: 0.48, green: 0.16, blue: 0.42), // Royal Plum
        Color(red: 0.68, green: 0.28, blue: 0.18), // Terracotta
        Color(red: 0.15, green: 0.35, blue: 0.38), // Petrol Teal
        Color(red: 0.42, green: 0.25, blue: 0.18), // Rich Mocha
        Color(red: 0.25, green: 0.20, blue: 0.38)  // Midnight Violet
    ]

    // MARK: - Varied Book Spines (5 Distinct Illustrated Archetypes)
    private var fileView: some View {
        let seed = abs(url.lastPathComponent.hashValue)
        let colorIndex = (itemIndex * 7 + shelfIndex * 3 + seed) % ShelfItemView.bookColors.count
        let color = ShelfItemView.bookColors[colorIndex]
        let styleIdx = (itemIndex * 3 + shelfIndex * 2 + (seed / 7)) % 5
        let label = url.deletingPathExtension().lastPathComponent
        let bookW = itemWidth
        let bookH = bookHeight
        let ext = url.pathExtension.uppercased()

        return ZStack(alignment: .bottom) {
            ZStack(alignment: .center) {
                // Book spine base with curvature shading
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.82),
                                color,
                                color.opacity(0.96),
                                color.opacity(0.78)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 2.5)
                            .stroke(Color.white.opacity(0.20), lineWidth: 0.6)
                    )
                    .frame(width: bookW, height: bookH)
                
                // Headband cloth rim at top and bottom
                VStack {
                    BookHeadbandStrip(width: bookW)
                    Spacer()
                    BookHeadbandStrip(width: bookW)
                }
                .frame(width: bookW, height: bookH)
                
                // Visual Style Variants
                Group {
                    switch styleIdx {
                    case 0:
                        ClassicGiltSpineAccents(width: bookW, height: bookH)
                    case 1:
                        ModernRibbonSpineAccents(width: bookW, height: bookH, seed: seed)
                    case 2:
                        VintageShieldSpineAccents(width: bookW, height: bookH)
                    case 3:
                        TechManualSpineAccents(width: bookW, height: bookH, ext: ext)
                    default:
                        PocketStarSpineAccents(width: bookW, height: bookH)
                    }
                }
                
                // Rotated Spine Title Text
                Text(label)
                    .font(.system(size: bookW >= 28 ? 9 : 8, weight: .bold))
                    .foregroundColor(styleIdx == 2 ? Color(red: 0.15, green: 0.12, blue: 0.10) : Color(red: 0.98, green: 0.96, blue: 0.92))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.55)
                    .frame(width: bookH - 26, height: bookW - 4)
                    .rotationEffect(.degrees(-90))
                    .frame(width: bookW, height: bookH)
                    .shadow(color: styleIdx == 2 ? .clear : .black.opacity(0.7), radius: 1, y: 0.5)
                    .allowsHitTesting(false)
            }
            .frame(width: bookW, height: bookH)
            .shadow(color: .black.opacity(0.25), radius: 2.5, y: 2.5)
            // Subtle artistic lean for pocket volumes
            .rotationEffect(.degrees(styleIdx == 4 ? ((seed % 2 == 0) ? -3.5 : 3.5) : 0), anchor: .bottom)
        }
        .frame(width: bookW, height: bookH)
    }

    // MARK: - Varied Cardboard Archive Boxes (4 Distinct Box Types)
    private var folderView: some View {
        let subItems = subItemsCount
        let label = url.lastPathComponent
        let boxStyle = (itemIndex + shelfIndex * 3) % 4
        let boxW = itemWidth
        
        let normalized = min(sqrt(Double(subItems)) / 6.0, 1.0)
        let boxH: CGFloat = 66 + CGFloat(normalized) * 36

        return ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                switch boxStyle {
                case 0:
                    ClassicBankerBoxView(width: boxW, height: boxH, label: label, count: subItems)
                case 1:
                    IndustrialMetalBoxView(width: boxW, height: boxH, label: label, count: subItems)
                case 2:
                    TwoToneLidBoxView(width: boxW, height: boxH, label: label, count: subItems, seed: itemIndex)
                default:
                    BrassCornerBoxView(width: boxW, height: boxH, label: label, count: subItems)
                }
            }
            .frame(width: boxW, height: boxH)
            .shadow(color: .black.opacity(0.25), radius: 3, y: 3)
        }
        .frame(width: boxW, height: boxH)
    }
}

// MARK: - Book Spine Style Helpers

// Top and bottom woven cloth headband (kapitalband)
struct BookHeadbandStrip: View {
    let width: CGFloat
    var body: some View {
        HStack(spacing: 1.5) {
            ForEach(0..<Int(width / 2.5), id: \.self) { i in
                Rectangle()
                    .fill((i % 2 == 0) ? Color(red: 0.94, green: 0.92, blue: 0.85) : Color(red: 0.70, green: 0.20, blue: 0.20))
                    .frame(width: 1.2, height: 1.8)
            }
        }
        .frame(width: width, height: 1.8)
    }
}

// Style 0: Classic Gilt Embossed Antique Leather (Raised Bands)
struct ClassicGiltSpineAccents: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack {
            // Top gilt double lines
            VStack(spacing: 2) {
                Rectangle().fill(Color(red: 0.92, green: 0.82, blue: 0.52).opacity(0.85)).frame(height: 1)
                Rectangle().fill(Color(red: 0.92, green: 0.82, blue: 0.52).opacity(0.85)).frame(height: 1)
            }
            .padding(.horizontal, 2)
            .padding(.top, 6)
            
            // Raised embossed rib
            SpineRib(width: width)
                .padding(.top, 4)
            
            Spacer()
            
            // Center gold filigree star
            Image(systemName: "sparkle")
                .font(.system(size: 7))
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.55).opacity(0.85))
            
            Spacer()
            
            // Raised embossed rib
            SpineRib(width: width)
                .padding(.bottom, 4)
            
            // Bottom gilt double lines
            VStack(spacing: 2) {
                Rectangle().fill(Color(red: 0.92, green: 0.82, blue: 0.52).opacity(0.85)).frame(height: 1)
                Rectangle().fill(Color(red: 0.92, green: 0.82, blue: 0.52).opacity(0.85)).frame(height: 1)
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 6)
        }
        .frame(width: width, height: height)
    }
}

// Embossed raised band ridge across spine
struct SpineRib: View {
    let width: CGFloat
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.25)).frame(width: width, height: 0.7)
            Rectangle().fill(Color.black.opacity(0.35)).frame(width: width, height: 0.8)
        }
    }
}

// Style 1: Modern Journal with Silk Bookmark Ribbon
struct ModernRibbonSpineAccents: View {
    let width: CGFloat
    let height: CGFloat
    let seed: Int
    
    var body: some View {
        let ribbonColors: [Color] = [
            Color(red: 0.85, green: 0.15, blue: 0.22), // Crimson silk
            Color(red: 0.90, green: 0.74, blue: 0.32), // Gold silk
            Color(red: 0.18, green: 0.65, blue: 0.42), // Emerald silk
            Color(red: 0.25, green: 0.55, blue: 0.88)  // Cerulean silk
        ]
        let ribbonColor = ribbonColors[seed % ribbonColors.count]
        
        ZStack(alignment: .topTrailing) {
            // Silk bookmark ribbon extending slightly above the spine
            VStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [ribbonColor.opacity(0.85), ribbonColor, ribbonColor.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3.5, height: 18)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: -0.5, y: 1)
            }
            .offset(x: -width * 0.22, y: -4)
            
            // Clean modern top/bottom borders
            VStack {
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: width * 0.75, height: 1)
                    .padding(.top, 7)
                
                Spacer()
                
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: width * 0.75, height: 1)
                    .padding(.bottom, 7)
            }
        }
        .frame(width: width, height: height)
    }
}

// Style 2: Vintage Linen with Paper Title Shield
struct VintageShieldSpineAccents: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // Darker quarters at top and bottom
            VStack {
                Rectangle()
                    .fill(Color.black.opacity(0.22))
                    .frame(width: width, height: 12)
                Spacer()
                Rectangle()
                    .fill(Color.black.opacity(0.22))
                    .frame(width: width, height: 12)
            }
            
            // Cream paper title shield in upper center
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.97, green: 0.96, blue: 0.91), Color(red: 0.92, green: 0.89, blue: 0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(red: 0.72, green: 0.62, blue: 0.44), lineWidth: 0.8)
                )
                .frame(width: width - 4, height: height - 30)
                .shadow(color: .black.opacity(0.20), radius: 1.5, y: 1)
        }
        .frame(width: width, height: height)
    }
}

// Style 3: Technical Manual with Color Classification Tag Badge
struct TechManualSpineAccents: View {
    let width: CGFloat
    let height: CGFloat
    let ext: String
    
    var body: some View {
        VStack {
            // Colored classification tag pill at top
            let tagColor: Color = ext == "APP" ? Color.purple : (ext == "PDF" ? Color.red : (ext == "SWIFT" ? Color.orange : Color(red: 0.20, green: 0.68, blue: 0.75)))
            
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tagColor)
                    .frame(width: width - 5, height: 11)
                
                Text(ext.isEmpty ? "DOC" : String(ext.prefix(3)))
                    .font(.system(size: 6.5, weight: .heavy))
                    .foregroundColor(.white)
            }
            .padding(.top, 6)
            
            Spacer()
            
            // Horizontal index grooves at bottom
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 3, height: 1.2)
                }
            }
            .padding(.bottom, 6)
        }
        .frame(width: width, height: height)
    }
}

// Style 4: Pocket Edition with Gold Foil Stars
struct PocketStarSpineAccents: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .font(.system(size: 6))
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.52))
                .padding(.top, 7)
            
            Spacer()
            
            Image(systemName: "star.fill")
                .font(.system(size: 6))
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.52))
                .padding(.bottom, 7)
        }
        .frame(width: width, height: height)
    }
}


// MARK: - Box Style Helpers (4 Distinct Archive Box Designs)

// Box Style 0: Classic Banker's Corrugated Box with Handle Hole & Taped Label
struct ClassicBankerBoxView: View {
    let width: CGFloat
    let height: CGFloat
    let label: String
    let count: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            // Corrugated kraft body
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.78, green: 0.60, blue: 0.42), Color(red: 0.68, green: 0.50, blue: 0.33)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(red: 0.52, green: 0.38, blue: 0.24), lineWidth: 0.8))
            
            // Darker cardboard lid fold
            Rectangle()
                .fill(Color(red: 0.60, green: 0.42, blue: 0.26))
                .frame(height: 8.5)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.horizontal, 2)
                .padding(.top, 2)
            
            // Stamped shipping arrow stencil at bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("↑ ↑")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Color.black.opacity(0.28))
                        .padding(.trailing, 6)
                        .padding(.bottom, 4)
                }
            }
            
            // White label attached with masking tape
            VStack(spacing: 3) {
                // Oval finger-pull handle cutout
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.20, green: 0.15, blue: 0.10), Color(red: 0.38, green: 0.28, blue: 0.20)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 6)
                    .overlay(Capsule().stroke(Color(red: 0.45, green: 0.32, blue: 0.22), lineWidth: 0.6))
                    .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                    .padding(.top, 14)
                
                // Masking-taped index card
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color(red: 0.76, green: 0.72, blue: 0.66), lineWidth: 0.7))
                        .frame(width: width * 0.84, height: min(34, height - 28))
                        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
                    
                    VStack(spacing: 1.5) {
                        Text(label)
                            .font(.system(size: 8.5, weight: .bold))
                            .foregroundColor(Color(red: 0.16, green: 0.13, blue: 0.10))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.65)
                        Text("\(count) file")
                            .font(.system(size: 7.5, weight: .medium))
                            .foregroundColor(Color(red: 0.48, green: 0.44, blue: 0.38))
                    }
                    .padding(.horizontal, 3)
                    
                    // Two masking tape strips on top & bottom edge
                    VStack {
                        Rectangle()
                            .fill(Color(red: 0.94, green: 0.92, blue: 0.82).opacity(0.75))
                            .frame(width: width * 0.45, height: 3.5)
                        Spacer()
                        Rectangle()
                            .fill(Color(red: 0.94, green: 0.92, blue: 0.82).opacity(0.75))
                            .frame(width: width * 0.45, height: 3.5)
                    }
                    .frame(width: width * 0.84, height: min(34, height - 28) + 4)
                }
            }
        }
    }
}

// Box Style 1: Industrial Slate Grayboard Box with Metal Brass Rivet Frame
struct IndustrialMetalBoxView: View {
    let width: CGFloat
    let height: CGFloat
    let label: String
    let count: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            // Dark industrial pressed grayboard body
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.34, green: 0.37, blue: 0.43), Color(red: 0.26, green: 0.28, blue: 0.33)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(red: 0.20, green: 0.22, blue: 0.26), lineWidth: 0.8))
            
            // Black reinforced cloth lid
            Rectangle()
                .fill(Color(red: 0.18, green: 0.19, blue: 0.22))
                .frame(height: 9)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 0.8, dash: [2, 2]))
                        .frame(height: 1)
                        .padding(.top, 7),
                    alignment: .top
                )
                .padding(.horizontal, 2)
                .padding(.top, 2)
            
            VStack(spacing: 5) {
                // Metallic brass label frame holder with 4 corner rivets
                ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.88, green: 0.76, blue: 0.45), Color(red: 0.65, green: 0.52, blue: 0.28)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: width * 0.86, height: min(34, height - 28))
                        .shadow(color: .black.opacity(0.25), radius: 1.5, y: 1)
                    
                    // Inner paper card
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color(red: 0.95, green: 0.94, blue: 0.89))
                        .frame(width: width * 0.86 - 4, height: min(34, height - 28) - 4)
                        .overlay(
                            VStack(spacing: 1.5) {
                                Text(label)
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.65)
                                Text("\(count) file")
                                    .font(.system(size: 7, weight: .semibold))
                                    .foregroundColor(Color(red: 0.45, green: 0.42, blue: 0.38))
                            }
                            .padding(.horizontal, 3)
                        )
                    
                    // 4 metallic rivets in corners
                    VStack {
                        HStack {
                            Circle().fill(Color(red: 0.35, green: 0.25, blue: 0.12)).frame(width: 2.2, height: 2.2)
                            Spacer()
                            Circle().fill(Color(red: 0.35, green: 0.25, blue: 0.12)).frame(width: 2.2, height: 2.2)
                        }
                        Spacer()
                        HStack {
                            Circle().fill(Color(red: 0.35, green: 0.25, blue: 0.12)).frame(width: 2.2, height: 2.2)
                            Spacer()
                            Circle().fill(Color(red: 0.35, green: 0.25, blue: 0.12)).frame(width: 2.2, height: 2.2)
                        }
                    }
                    .frame(width: width * 0.86 - 1.5, height: min(34, height - 28) - 1.5)
                }
                .padding(.top, 16)
                
                // Metal brass grommet finger-pull ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 0.90, green: 0.78, blue: 0.48), Color(red: 0.65, green: 0.52, blue: 0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.4
                    )
                    .background(Circle().fill(Color(red: 0.12, green: 0.13, blue: 0.15)))
                    .frame(width: 9, height: 9)
                    .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
            }
        }
    }
}

// Box Style 2: Two-Tone Studio Box with Dark Contrast Lid (Navy or Forest Green)
struct TwoToneLidBoxView: View {
    let width: CGFloat
    let height: CGFloat
    let label: String
    let count: Int
    let seed: Int
    
    var body: some View {
        let isNavy = seed % 2 == 0
        let lidColor = isNavy ? Color(red: 0.12, green: 0.18, blue: 0.28) : Color(red: 0.12, green: 0.25, blue: 0.16)
        
        ZStack(alignment: .top) {
            // Light tan cardboard body
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.82, green: 0.68, blue: 0.52), Color(red: 0.74, green: 0.58, blue: 0.42)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(red: 0.58, green: 0.45, blue: 0.32), lineWidth: 0.8))
            
            // Heavy contrast lid with overhang
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [lidColor.opacity(0.92), lidColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 11)
                .clipShape(RoundedRectangle(cornerRadius: 2.5))
                .shadow(color: .black.opacity(0.28), radius: 1.5, y: 1.5)
                .padding(.horizontal, 1)
                .padding(.top, 1)
            
            // Red vertical archive classification stripe
            HStack {
                Rectangle()
                    .fill(Color(red: 0.80, green: 0.22, blue: 0.22))
                    .frame(width: 3.5)
                    .padding(.leading, 8)
                    .padding(.top, 12)
                Spacer()
            }
            
            // Clean white/manila shipping card
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.98, green: 0.98, blue: 0.96))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.12), lineWidth: 0.7))
                        .frame(width: width * 0.76, height: min(34, height - 26))
                        .shadow(color: .black.opacity(0.10), radius: 1, y: 1)
                    
                    VStack(spacing: 2) {
                        HStack(spacing: 3) {
                            Circle().fill(Color(red: 0.25, green: 0.65, blue: 0.35)).frame(width: 4, height: 4)
                            Text(label)
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(Color(red: 0.14, green: 0.12, blue: 0.10))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.65)
                        }
                        Text("\(count) file")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.42, blue: 0.38))
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Small round string-tie button
                Circle()
                    .fill(Color(red: 0.88, green: 0.78, blue: 0.60))
                    .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 0.6))
                    .frame(width: 5.5, height: 5.5)
                    .padding(.bottom, 6)
            }
        }
    }
}

// Box Style 3: Vintage Reinforced Box with Brass Metal Corners
struct BrassCornerBoxView: View {
    let width: CGFloat
    let height: CGFloat
    let label: String
    let count: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            // Warm leatherboard kraft body
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.76, green: 0.54, blue: 0.35), Color(red: 0.65, green: 0.44, blue: 0.26)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(red: 0.48, green: 0.32, blue: 0.18), lineWidth: 0.8))
            
            // Top lid rim
            Rectangle()
                .fill(Color(red: 0.56, green: 0.38, blue: 0.22))
                .frame(height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.horizontal, 2)
                .padding(.top, 2)
            
            // Horizontal reinforced brown tape band across middle
            Rectangle()
                .fill(Color(red: 0.50, green: 0.32, blue: 0.18).opacity(0.38))
                .frame(width: width, height: 12)
                .position(x: width * 0.5, y: height * 0.5)
            
            // 4 Brass metallic corner brackets
            VStack {
                HStack {
                    BrassCornerBracket(isTop: true, isLeading: true)
                    Spacer()
                    BrassCornerBracket(isTop: true, isLeading: false)
                }
                Spacer()
                HStack {
                    BrassCornerBracket(isTop: false, isLeading: true)
                    Spacer()
                    BrassCornerBracket(isTop: false, isLeading: false)
                }
            }
            .frame(width: width, height: height)
            
            // Clean white label
            VStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.98, green: 0.97, blue: 0.94))
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color(red: 0.68, green: 0.55, blue: 0.38), lineWidth: 0.8))
                    .frame(width: width * 0.80, height: min(34, height - 26))
                    .overlay(
                        VStack(spacing: 1.5) {
                            Text(label)
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.65)
                            Text("\(count) file")
                                .font(.system(size: 7.5, weight: .medium))
                                .foregroundColor(Color(red: 0.48, green: 0.42, blue: 0.36))
                        }
                        .padding(.horizontal, 3)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 1.5, y: 1)
                    .padding(.top, 16)
            }
        }
    }
}

// Metallic brass corner protector with center rivet
struct BrassCornerBracket: View {
    let isTop: Bool
    let isLeading: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.92, green: 0.80, blue: 0.48), Color(red: 0.65, green: 0.52, blue: 0.26)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 7, height: 7)
                .overlay(Rectangle().stroke(Color(red: 0.45, green: 0.35, blue: 0.15), lineWidth: 0.4))
            
            Circle()
                .fill(Color(red: 0.30, green: 0.22, blue: 0.10))
                .frame(width: 1.8, height: 1.8)
        }
        .padding(.top, isTop ? 2 : 0)
        .padding(.bottom, isTop ? 0 : 2)
        .padding(.leading, isLeading ? 2 : 0)
        .padding(.trailing, isLeading ? 0 : 2)
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
