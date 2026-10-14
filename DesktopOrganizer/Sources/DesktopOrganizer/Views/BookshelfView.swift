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
                
                // Empty state prompt on shelf
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
                            .fill(Color.black.opacity(0.72))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SANSColors.lime.opacity(0.4), lineWidth: 1))
                    )
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    .position(x: w * 0.48, y: h * 0.43)
                    .allowsHitTesting(false)
                }
                
                // 5 Interactive Shelf Levels (Flushed exactly onto the 5 white shelf planks)
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
    
    @ViewBuilder
    private func shelfRow(shelfIndex: Int, width: CGFloat) -> some View {
        let items = storage.bookshelfItems
        let itemsPerShelf = 6
        let startIndex = shelfIndex * itemsPerShelf
        let endIndex = min(items.count, startIndex + itemsPerShelf)
        let itemsForThisShelf = (startIndex < items.count) ? Array(items[startIndex..<endIndex]) : []
        
        HStack(alignment: .bottom, spacing: 6) {
            if itemsForThisShelf.isEmpty {
                // Subtle decorative ambient books when shelf has no user items
                ambientBooks(shelfIndex: shelfIndex)
            } else {
                ForEach(itemsForThisShelf, id: \.self) { url in
                    ShelfItemView(url: url, theme: theme)
                }
            }
            Spacer()
        }
        .frame(width: width, height: 60, alignment: .bottomLeading)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private func ambientBooks(shelfIndex: Int) -> some View {
        let count = (shelfIndex == 1) ? 4 : (shelfIndex == 2 ? 5 : (shelfIndex == 3 ? 3 : 2))
        let colors: [Color] = [
            Color(red: 0.70, green: 0.22, blue: 0.22),
            Color(red: 0.22, green: 0.38, blue: 0.65),
            Color(red: 0.22, green: 0.55, blue: 0.35),
            Color(red: 0.75, green: 0.55, blue: 0.22),
            Color(red: 0.45, green: 0.25, blue: 0.55)
        ]
        
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<count, id: \.self) { i in
                let h = CGFloat(28 + (i * 5) % 16)
                let c = colors[(shelfIndex * 2 + i) % colors.count]
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(c.opacity(0.85))
                    .frame(width: 8, height: h)
            }
        }
    }
}

// MARK: - Individual Shelf Item (File becomes Book 📚, Folder becomes Archive Box 🗃️)
struct ShelfItemView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let url: URL
    let theme: RoomTheme
    
    var isHovered: Bool {
        appState.hoveredShelfURL == url
    }
    
    var isDirectory: Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    var body: some View {
        Group {
            if isDirectory {
                archiveBoxRepresentation
            } else {
                bookRepresentation
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            if hovering {
                appState.hoveredShelfURL = url
            } else if appState.hoveredShelfURL == url {
                appState.hoveredShelfURL = nil
            }
        }
        .onTapGesture(count: 2) {
            NSWorkspace.shared.open(url)
        }
        .onTapGesture(count: 1) {
            NSWorkspace.shared.open(url)
        }
        .contextMenu {
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
        }
        .help(url.lastPathComponent)
    }
    
    // File -> Authentic Book Spine Binder (using Desktop Organizer official asset)
    private var bookRepresentation: some View {
        let hash = abs(url.lastPathComponent.hashValue)
        let colorIdx = hash % 6
        let bookImgName = "file-\(colorIdx)"
        
        return ZStack(alignment: .bottom) {
            if let img = AssetLoader.image(named: bookImgName) {
                Image(nsImage: img)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(height: 52)
                    .shadow(color: .black.opacity(isHovered ? 0.4 : 0.2), radius: isHovered ? 4 : 2, y: 2)
            } else {
                // High-fidelity procedural book fallback
                RoundedRectangle(cornerRadius: 2)
                    .fill(SANSColors.primaryBlue)
                    .frame(width: 14, height: 50)
            }
            
            // Hover title tooltip tag
            if isHovered {
                Text(url.deletingPathExtension().lastPathComponent)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.85)))
                    .offset(y: -58)
                    .allowsHitTesting(false)
                    .zIndex(10)
            }
        }
    }
    
    // Folder -> Authentic Cardboard Archive Box (using Desktop Organizer official asset)
    private var archiveBoxRepresentation: some View {
        let hash = abs(url.lastPathComponent.hashValue)
        let colorIdx = hash % 6
        let subItems = (try? FileManager.default.contentsOfDirectory(atPath: url.path))?.count ?? 0
        let fullnessLevel = subItems == 0 ? 0 : (subItems <= 4 ? 1 : 2)
        let folderImgName = "folder-\(colorIdx)-\(fullnessLevel)"
        
        return ZStack(alignment: .bottom) {
            if let img = AssetLoader.image(named: folderImgName) {
                Image(nsImage: img)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(height: 48)
                    .shadow(color: .black.opacity(isHovered ? 0.4 : 0.2), radius: isHovered ? 4 : 2, y: 2)
            } else {
                // High-fidelity procedural box fallback
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.72, green: 0.55, blue: 0.38))
                    .frame(width: 38, height: 44)
            }
            
            // Hover title and item count tooltip tag
            if isHovered {
                VStack(spacing: 2) {
                    Text(url.lastPathComponent)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text("\(subItems) item")
                        .font(.system(size: 8))
                        .foregroundColor(SANSColors.lime)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.85)))
                .offset(y: -54)
                .allowsHitTesting(false)
                .zIndex(10)
            }
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
