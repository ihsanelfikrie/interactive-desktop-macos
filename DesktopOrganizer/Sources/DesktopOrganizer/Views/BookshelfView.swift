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
                    .fill(appState.isBookshelfTargeted ? Color.blue.opacity(0.22) : Color.clear)
                    .overlay(
                        Group {
                            if appState.isBookshelfTargeted {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.yellow, lineWidth: 3)
                                    .overlay(
                                        VStack(spacing: 6) {
                                            Image(systemName: "square.and.arrow.down.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(.yellow)
                                            Text(dropPromptText)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                                .shadow(color: .black, radius: 4)
                                        }
                                    )
                            }
                        }
                    )
                    .contentShape(Rectangle())
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
                
                // 4 Interactive Shelf Levels (Flushed exactly onto the 4 illustrated wooden planks)
                // Shelf 1 (top): plank at 0.180 * h
                shelfRow(shelfIndex: 0, width: w)
                    .position(x: w * 0.48, y: h * 0.135)
                
                // Shelf 2: plank at 0.375 * h
                shelfRow(shelfIndex: 1, width: w)
                    .position(x: w * 0.48, y: h * 0.330)
                
                // Shelf 3: plank at 0.570 * h
                shelfRow(shelfIndex: 2, width: w)
                    .position(x: w * 0.48, y: h * 0.525)
                
                // Shelf 4: plank at 0.766 * h (Leaves room for illustrated plant on the right)
                shelfRow(shelfIndex: 3, width: w * 0.75)
                    .position(x: w * 0.38, y: h * 0.720)
                
                // Sliding Library Ladder (scaled to full bookcase height, draggable across track)
                if theme == .library {
                    LadderView(shelfHeight: h)
                        .position(x: min(w * 0.75, max(w * 0.12, appState.ladderX)), y: h * 0.50)
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
    
    private var dropPromptText: String {
        switch theme {
        case .library: return "Simpan File Jadi Buku di Rak"
        case .kos: return "Simpan File Jadi Map & Kardus"
        case .garden: return "Tanam Folder Jadi Pot Bunga"
        }
    }
    
    @ViewBuilder
    private func shelfRow(shelfIndex: Int, width: CGFloat) -> some View {
        let items = storage.bookshelfItems
        let itemsForThisShelf = items.enumerated().filter { $0.offset % 4 == shelfIndex }.map { $0.element }
        
        HStack(alignment: .bottom, spacing: 4) {
            if itemsForThisShelf.isEmpty {
                // Subtle decorative ambient books when shelf is empty
                ambientBooks(shelfIndex: shelfIndex)
            } else {
                ForEach(itemsForThisShelf, id: \.self) { url in
                    ShelfItemView(url: url, theme: theme)
                }
            }
            Spacer()
        }
        .frame(width: width, height: 65, alignment: .bottomLeading)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func ambientBooks(shelfIndex: Int) -> some View {
        let count = (shelfIndex == 1) ? 4 : (shelfIndex == 2 ? 6 : 3)
        let colors: [Color] = [
            Color(red: 0.70, green: 0.22, blue: 0.22),
            Color(red: 0.22, green: 0.38, blue: 0.65),
            Color(red: 0.22, green: 0.55, blue: 0.35),
            Color(red: 0.75, green: 0.55, blue: 0.22),
            Color(red: 0.45, green: 0.25, blue: 0.55)
        ]
        
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<count, id: \.self) { i in
                let h = CGFloat(26 + (i * 6) % 18)
                let c = colors[(shelfIndex * 2 + i) % colors.count]
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(c.opacity(0.85))
                    .frame(width: 7, height: h)
            }
        }
    }
}

// MARK: - Individual Shelf Item (File / Folder representation)
struct ShelfItemView: View {
    @ObservedObject var storage = StorageManager.shared
    let url: URL
    let theme: RoomTheme
    
    var isDirectory: Bool {
        url.hasDirectoryPath || (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }
    
    var body: some View {
        Group {
            if theme == .kos {
                kosRepresentation
            } else if theme == .garden {
                gardenRepresentation
            } else {
                libraryRepresentation
            }
        }
        .contentShape(Rectangle())
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
    
    // Library Theme: Book Spine or Archive Box
    private var libraryRepresentation: some View {
        VStack(spacing: 1) {
            if isDirectory {
                // Archive Box
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.78, green: 0.68, blue: 0.52))
                        .frame(width: 28, height: 38)
                        .overlay(
                            VStack {
                                Rectangle().fill(Color.white.opacity(0.4)).frame(height: 1).padding(.top, 3)
                                Spacer()
                            }
                        )
                    Text("ARCH")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.15))
                }
            } else {
                // Book Spine
                let hash = abs(url.lastPathComponent.hashValue)
                let bookColors: [Color] = [
                    Color(red: 0.72, green: 0.18, blue: 0.18),
                    Color(red: 0.18, green: 0.35, blue: 0.68),
                    Color(red: 0.20, green: 0.55, blue: 0.32),
                    Color(red: 0.80, green: 0.58, blue: 0.18),
                    Color(red: 0.50, green: 0.25, blue: 0.60)
                ]
                let color = bookColors[hash % bookColors.count]
                let h = CGFloat(30 + (hash % 14))
                
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: 10, height: h)
                    .overlay(
                        VStack {
                            Rectangle().fill(Color.white.opacity(0.5)).frame(height: 1).padding(.top, 2)
                            Spacer()
                        }
                    )
            }
            
            Text(url.deletingPathExtension().lastPathComponent)
                .font(.system(size: 6, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 28)
        }
    }
    
    // Kos Room Theme: Plastic File or Indomie Box
    private var kosRepresentation: some View {
        VStack(spacing: 1) {
            if isDirectory {
                if let boxImg = AssetLoader.image(named: "kos-folder-0-0") {
                    Image(nsImage: boxImg)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 30, height: 36)
                } else {
                    Image(systemName: "archivebox.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.brown)
                }
            } else {
                let hash = abs(url.lastPathComponent.hashValue) % 6
                if let fileImg = AssetLoader.image(named: "kos-file-\(hash)") {
                    Image(nsImage: fileImg)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 18, height: 32)
                } else {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.cyan)
                }
            }
            
            Text(url.deletingPathExtension().lastPathComponent)
                .font(.system(size: 6, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 28)
        }
    }
    
    // Garden Theme: Seed Packet or Flower Pot
    private var gardenRepresentation: some View {
        VStack(spacing: 1) {
            if isDirectory {
                if let potImg = AssetLoader.image(named: "garden-folder-0-0") {
                    Image(nsImage: potImg)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 26, height: 34)
                } else {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
            } else {
                let hash = abs(url.lastPathComponent.hashValue) % 6
                if let seedImg = AssetLoader.image(named: "garden-file-\(hash)") {
                    Image(nsImage: seedImg)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 16, height: 28)
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }
            }
            
            Text(url.deletingPathExtension().lastPathComponent)
                .font(.system(size: 6, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 28)
        }
    }
}

// MARK: - Leaning & Sliding Ladder View
struct LadderView: View {
    @ObservedObject var appState = AppState.shared
    let shelfHeight: CGFloat
    
    var body: some View {
        Group {
            if let ladderImg = AssetLoader.image(named: "ladder") {
                Image(nsImage: ladderImg)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(height: shelfHeight * 0.94)
            } else {
                Rectangle()
                    .fill(Color(red: 0.45, green: 0.28, blue: 0.16))
                    .frame(width: 28, height: shelfHeight * 0.94)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { val in
                    appState.ladderX += val.translation.width
                }
        )
        .help("Geser tangga ke kiri atau kanan")
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
