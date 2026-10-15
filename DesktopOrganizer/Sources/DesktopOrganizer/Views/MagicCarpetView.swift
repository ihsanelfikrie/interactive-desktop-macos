import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Fast In-Memory Icon Cache (Prevents Blocking I/O During Drag Passes)
final class FileIconCache {
    static let shared = FileIconCache()
    private let cache: NSCache<NSURL, NSImage> = {
        let c = NSCache<NSURL, NSImage>()
        c.countLimit = 32
        return c
    }()
    
    func icon(for url: URL) -> NSImage {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            return cached
        }
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        cache.setObject(icon, forKey: key)
        return icon
    }
    
    func purge() {
        cache.removeAllObjects()
    }
}


// MARK: - Magic Carpet & Grass Floor File Interactive View
public struct MagicCarpetView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var floorState = FloorInteractionState.shared
    let theme: RoomTheme
    let screenSize: CGSize
    
    public init(theme: RoomTheme, screenSize: CGSize = CGSize(width: 1440, height: 900)) {
        self.theme = theme
        self.screenSize = screenSize
    }
    
    public var body: some View {
        let w = screenSize.width
        let h = screenSize.height
        
        let baseCarpetX = storage.carpetPositionNorm.x * w
        let baseCarpetY = storage.carpetPositionNorm.y * h
        
        let liveCarpetCenterX = baseCarpetX + floorState.carpetDragOffset.width
        let liveCarpetCenterY = baseCarpetY + floorState.carpetDragOffset.height
        
        // Rug effective visual bounding box on floor:
        // Visual carpet is 610 pt wide, 156 pt tall with 50° floor tilt (approx ~100 pt height)
        let rugW: CGFloat = 610
        let rugH: CGFloat = 100
        let carpetRect = CGRect(
            x: liveCarpetCenterX - (rugW * 0.5),
            y: liveCarpetCenterY - (rugH * 0.5),
            width: rugW,
            height: rugH
        )
        
        // Count how many files are covered beneath the carpet
        let coveredFilesCount = storage.carpetItems.filter { item in
            let pos = storage.positionForFloorItem(filename: item.lastPathComponent, index: 0, total: 1)
            let fX = pos.x * w
            let fY = pos.y * h
            return carpetRect.contains(CGPoint(x: fX, y: fY))
        }.count
        
        ZStack(alignment: .topLeading) {
            // Native macOS Finder Rubber-Band Selection Box ("Drag Blok")
            if floorState.isMarqueeSelecting,
               let start = floorState.marqueeStart,
               let curr = floorState.marqueeCurrent {
                let box = CGRect(
                    x: min(start.x, curr.x),
                    y: min(start.y, curr.y),
                    width: max(abs(curr.x - start.x), 1),
                    height: max(abs(curr.y - start.y), 1)
                )
                Rectangle()
                    .fill(Color(NSColor.selectedControlColor).opacity(0.24))
                    .overlay(
                        Rectangle()
                            .stroke(Color(NSColor.controlAccentColor).opacity(0.85), lineWidth: 1.0)
                    )
                    .frame(width: box.width, height: box.height)
                    .position(x: box.midX, y: box.midY)
                    .allowsHitTesting(false)
                    .zIndex(45)
            }
            
            // LAYER 2: Files & Folders placed on the grass lawn
            ForEach(Array(storage.carpetItems.enumerated()), id: \.element) { idx, item in
                let basePos = storage.positionForFloorItem(filename: item.lastPathComponent, index: idx, total: storage.carpetItems.count)
                let basePixelX = basePos.x * w
                let basePixelY = basePos.y * h
                let isCovered = carpetRect.contains(CGPoint(x: basePixelX, y: basePixelY))
                let isThisDragging = floorState.draggingFloorFileName == item.lastPathComponent
                let isSelected = floorState.selectedFileNames.contains(item.lastPathComponent)
                let isPartDragging = isSelected && floorState.draggingFloorFileName != nil
                let liveOffset = (isThisDragging || isPartDragging) ? floorState.floorFileDragTranslation : .zero
                let isVisible = !isCovered || floorState.isCarpetLifted
                
                if isVisible {
                    FloorItemView(itemURL: item, isCovered: isCovered, screenSize: screenSize)
                        .position(x: basePixelX, y: basePixelY)
                        .offset(liveOffset)
                        .zIndex(isThisDragging ? 40 : (isPartDragging ? 38 : (isSelected ? 32 : (floorState.isCarpetLifted ? 25 : (isCovered ? 5 : 22)))))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // LAYER 3: The Movable Arabic Carpet (Can be moved to any area to cover files)
            MovableCarpetMatView(theme: theme, coveredCount: coveredFilesCount, screenSize: screenSize)
                .position(x: baseCarpetX, y: baseCarpetY)
                .offset(floorState.carpetDragOffset)
                .zIndex(20)
            
            // LAYER 4: Floating Multi-Select ("Blok") Action Bar
            if !floorState.selectedFileNames.isEmpty && !floorState.isCarpetDragging && floorState.draggingFloorFileName == nil {
                FloorMultiSelectActionBar(
                    selectedCount: floorState.selectedFileNames.count,
                    onAddToBookshelf: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            storage.moveFloorItemsToBookshelf(filenames: Array(floorState.selectedFileNames))
                            floorState.clearSelection()
                        }
                    },
                    onClearSelection: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            floorState.clearSelection()
                        }
                    },
                    onTrashAll: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            for name in floorState.selectedFileNames {
                                storage.removeFloorItem(itemURL: storage.carpetDirectory.appendingPathComponent(name))
                            }
                            floorState.clearSelection()
                        }
                    }
                )
                .position(x: w * 0.5, y: h * 0.88)
                .zIndex(50)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .frame(width: w, height: h)
    }
}

// MARK: - Floor Drop Highlight Overlay
struct FloorDropHighlightOverlay: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color(red: 0.40, green: 0.90, blue: 0.50).opacity(0.85),
                    style: StrokeStyle(lineWidth: 2.5, dash: [8, 6])
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.20, green: 0.80, blue: 0.40).opacity(0.12))
                )
                .padding(14)
            
            HStack(spacing: 8) {
                Image(systemName: "tray.and.arrow.down.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Taruh File / Folder di Desktop")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.black.opacity(0.78)))
            .overlay(Capsule().stroke(Color(red: 0.40, green: 0.90, blue: 0.50).opacity(0.85), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
        }
        .allowsHitTesting(false)
        .transition(.opacity)
    }
}

// MARK: - Floating Multi-Select Action Bar ("Blok")
struct FloorMultiSelectActionBar: View {
    let selectedCount: Int
    let onAddToBookshelf: () -> Void
    let onClearSelection: () -> Void
    let onTrashAll: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SANSColors.lime)
                    .font(.system(size: 14, weight: .bold))
                Text("\(selectedCount) File Dipilih")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 4)
            
            Button(action: onAddToBookshelf) {
                HStack(spacing: 5) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 11))
                    Text("Simpan ke Rak Buku")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(SANSColors.lime))
            }
            .buttonStyle(.plain)
            .help("Pindahkan semua file yang diblok ke rak buku")
            
            Button(action: onTrashAll) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red.opacity(0.9))
                    .padding(5)
                    .background(Circle().fill(Color.white.opacity(0.12)))
            }
            .buttonStyle(.plain)
            .help("Buang semua file yang diblok ke tong sampah")
            
            Button(action: onClearSelection) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(5)
            }
            .buttonStyle(.plain)
            .help("Lepas pilihan blok")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.95))
                .shadow(color: .black.opacity(0.55), radius: 10, y: 5)
        )
        .overlay(
            Capsule()
                .stroke(SANSColors.lime.opacity(0.6), lineWidth: 1.2)
        )
    }
}

// MARK: - Movable Carpet Mat View (Seamless Fluid Dragging)
struct MovableCarpetMatView: View {
    let theme: RoomTheme
    let coveredCount: Int
    let screenSize: CGSize
    
    @ObservedObject var floorState = FloorInteractionState.shared
    @ObservedObject var storage = StorageManager.shared
    
    var body: some View {
        let w = screenSize.width
        let h = screenSize.height
        
        let isLifted = floorState.isCarpetLifted
        let isDragging = floorState.isCarpetDragging
        
        ZStack {
            // Carpet visual body with 3D floor perspective
            CarpetMatBodyView(theme: theme, itemCount: coveredCount, isLifted: isLifted)
                // 3D curl / lift effect when peeking
                .rotation3DEffect(
                    .degrees(isLifted ? -26 : 0),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .top
                )
                .scaleEffect(y: isLifted ? 0.74 : 1.0, anchor: .top)
                .offset(y: isLifted ? -16 : 0)
                // Floor perspective
                .rotation3DEffect(
                    .degrees(50),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center,
                    perspective: 0.55
                )
                .shadow(
                    color: Color.black.opacity(isDragging ? 0.55 : (isLifted ? 0.45 : 0.35)),
                    radius: isDragging ? 18 : (isLifted ? 12 : 7),
                    x: 0,
                    y: isDragging ? 14 : (isLifted ? 10 : 5)
                )
        }
        .frame(width: 634, height: 130)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 2, coordinateSpace: .global)
                .onChanged { value in
                    floorState.isCarpetDragging = true
                    
                    let baseCarpetX = storage.carpetPositionNorm.x * w
                    let baseCarpetY = storage.carpetPositionNorm.y * h
                    let proposedX = baseCarpetX + value.translation.width
                    let proposedY = baseCarpetY + value.translation.height
                    
                    // Clamped strictly to floor bounds (safe from Dock and furniture)
                    let clampedX = min(w * 0.82, max(w * 0.18, proposedX))
                    let clampedY = min(h * 0.86, max(h * 0.70, proposedY))
                    
                    floorState.carpetDragOffset = CGSize(
                        width: clampedX - baseCarpetX,
                        height: clampedY - baseCarpetY
                    )
                }
                .onEnded { value in
                    let dist = hypot(value.translation.width, value.translation.height)
                    floorState.isCarpetDragging = false
                    
                    if dist < 6 {
                        if !floorState.selectedFileNames.isEmpty {
                            floorState.clearSelection()
                        } else {
                            // Click / tap action: toggle peek / lift
                            withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                                floorState.isCarpetLifted.toggle()
                            }
                        }
                        floorState.carpetDragOffset = .zero
                    } else {
                        // Drag completed: save new position
                        let baseCarpetX = storage.carpetPositionNorm.x * w
                        let baseCarpetY = storage.carpetPositionNorm.y * h
                        let finalX = baseCarpetX + floorState.carpetDragOffset.width
                        let finalY = baseCarpetY + floorState.carpetDragOffset.height
                        
                        let normX = Double(finalX / w)
                        let normY = Double(finalY / h)
                        
                        storage.setCarpetPosition(normX: normX, normY: normY)
                        floorState.carpetDragOffset = .zero
                    }
                }
        )
        .contextMenu {
            Button(isLifted ? "Tutup Karpet (Sembunyikan File)" : "Buka / Intip Karpet (Perlihatkan File)") {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                    floorState.isCarpetLifted.toggle()
                }
            }
            
            Button("Pilih File untuk Disembunyikan...") {
                storage.pickCarpetItem()
            }
            
            Button("Kembalikan Karpet ke Posisi Tengah") {
                withAnimation(.spring(response: 0.40, dampingFraction: 0.75)) {
                    storage.setCarpetPosition(normX: 0.498, normY: 0.82)
                }
            }
            
            Button("Rapikan File di Bawah Karpet") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    storage.tidyCarpetItemPositions()
                }
            }
            
            Button("Sebarkan Semua File ke Lantai Rumput") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    storage.scatterAllItemsToLawn()
                }
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
        .help("Karpet Arabik: Geser ke mana saja di lantai untuk menutupi file. Klik 1x untuk membuka / mengintip.")
    }
}

// Helper to determine targeted photo frame slot (0..5) from screen coordinates
func slotIndexForGallery(point: CGPoint, galleryRect: CGRect) -> Int {
    let relX = point.x - galleryRect.minX
    let relY = point.y - galleryRect.minY
    let col = relX > (galleryRect.width * 0.5) ? 1 : 0
    let row = Int(min(2, max(0, relY / max(1, galleryRect.height / 3.0))))
    return min(5, max(0, (row * 2) + col))
}

// MARK: - Floor Item View (Files & Folders on Desktop)
struct FloorItemView: View {
    let itemURL: URL
    let isCovered: Bool
    let screenSize: CGSize
    let iconImage: NSImage
    
    @ObservedObject var floorState = FloorInteractionState.shared
    @ObservedObject var storage = StorageManager.shared
    
    init(itemURL: URL, isCovered: Bool, screenSize: CGSize) {
        self.itemURL = itemURL
        self.isCovered = isCovered
        self.screenSize = screenSize
        self.iconImage = FileIconCache.shared.icon(for: itemURL)
    }
    
    var body: some View {
        let isDraggingThis = floorState.draggingFloorFileName == itemURL.lastPathComponent
        let isSelected = floorState.selectedFileNames.contains(itemURL.lastPathComponent)
        let isHovered = floorState.hoveredFloorFileName == itemURL.lastPathComponent
        let w = screenSize.width
        let h = screenSize.height
        
        let hash = abs(itemURL.lastPathComponent.hashValue)
        let casualAngle = Double((hash % 21) - 10) // -10° ... +10° natural scatter tilt
        
        VStack(spacing: 3) {
            ZStack(alignment: .topTrailing) {
                // Physical file/folder icon on grass
                Image(nsImage: iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(isDraggingThis ? 0.65 : 0.40), radius: isDraggingThis ? 8 : 4, x: 0, y: isDraggingThis ? 6 : 3)
                    .scaleEffect(isDraggingThis ? 1.15 : (isHovered ? 1.05 : 1.0))
                
                // If covered under carpet but revealed, eye-slash indicator
                if isCovered {
                    Image(systemName: "eye.slash.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.98, green: 0.88, blue: 0.50))
                        .background(Circle().fill(Color.black.opacity(0.85)))
                        .offset(x: -24, y: -4)
                }
                
                // Multi-select checkmark indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(NSColor.controlAccentColor))
                        .background(Circle().fill(Color.white))
                        .offset(x: -26, y: -4)
                }
                
                // Quick restore button on hover
                if isHovered && !isSelected {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            storage.restoreCarpetItemToDesktop(itemURL: itemURL)
                        }
                    }) {
                        Image(systemName: "arrow.up.forward.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                            .background(Circle().fill(Color.black.opacity(0.85)))
                    }
                    .buttonStyle(.plain)
                    .offset(x: 6, y: -6)
                    .help("Kembalikan file ini ke Desktop")
                }
            }
            
            // Filename pill
            Text(itemURL.lastPathComponent)
                .font(.system(size: 9.5, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: 86)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(NSColor.selectedControlColor) : Color.black.opacity(0.72))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.white.opacity(0.75) : (isCovered ? Color.yellow.opacity(0.4) : Color.white.opacity(0.18)), lineWidth: isSelected ? 1.2 : 0.8)
                )
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
        }
        .rotationEffect(.degrees((isDraggingThis || isSelected) ? 0 : casualAngle))
        .contentShape(Rectangle())
        .onHover { hovering in
            floorState.hoveredFloorFileName = hovering ? itemURL.lastPathComponent : nil
        }
        .gesture(
            DragGesture(minimumDistance: 2, coordinateSpace: .global)
                .onChanged { value in
                    floorState.draggingFloorFileName = itemURL.lastPathComponent
                    floorState.floorFileDragTranslation = value.translation
                    
                    let basePos = storage.positionForFloorItem(filename: itemURL.lastPathComponent, index: 0, total: 1)
                    let curPt = CGPoint(x: (basePos.x * w) + value.translation.width, y: (basePos.y * h) + value.translation.height)
                    
                    let bookshelfRect = CGRect(x: (w * 0.1678) - (w * 0.2444 * 0.5) - 30, y: (h * 0.3705) - (h * 0.2860 * 0.5) - 30, width: (w * 0.2444) + 60, height: (h * 0.2860) + 60)
                    let galleryRect = CGRect(x: (w * 0.83125) - (w * 0.220 * 0.5) - 30, y: (h * 0.320) - (h * 0.440 * 0.5) - 30, width: (w * 0.220) + 60, height: (h * 0.440) + 60)
                    let trashPt = CGPoint(x: w * 0.710, y: h * 0.738)
                    
                    AppState.shared.isBookshelfTargeted = bookshelfRect.contains(curPt) || bookshelfRect.contains(value.location)
                    AppState.shared.isTrashTargeted = hypot(curPt.x - trashPt.x, curPt.y - trashPt.y) < 85 ||
                                                      hypot(value.location.x - trashPt.x, value.location.y - trashPt.y) < 85
                    
                    let isOverGallery = (galleryRect.contains(curPt) || galleryRect.contains(value.location))
                    if isOverGallery && StorageManager.isImageFile(itemURL) {
                        let checkPt = galleryRect.contains(curPt) ? curPt : value.location
                        let slot = slotIndexForGallery(point: checkPt, galleryRect: galleryRect)
                        AppState.shared.targetedPhotoSlot = slot
                    } else {
                        AppState.shared.targetedPhotoSlot = nil
                    }
                }
                .onEnded { value in
                    AppState.shared.isBookshelfTargeted = false
                    AppState.shared.isTrashTargeted = false
                    AppState.shared.targetedPhotoSlot = nil
                    
                    let dist = hypot(value.translation.width, value.translation.height)
                    if dist < 5 {
                        floorState.toggleSelection(for: itemURL.lastPathComponent)
                    } else {
                        let basePos = storage.positionForFloorItem(filename: itemURL.lastPathComponent, index: 0, total: 1)
                        let releasePoint = CGPoint(x: (basePos.x * w) + value.translation.width, y: (basePos.y * h) + value.translation.height)
                        
                        let isGroup = isSelected && floorState.selectedFileNames.count > 1
                        let groupFiles = isGroup ? Array(floorState.selectedFileNames) : [itemURL.lastPathComponent]
                        
                        // 1. Check Bookshelf Drop (Moves single or all selected files into shelf)
                        let bookshelfRect = CGRect(x: (w * 0.1678) - (w * 0.2444 * 0.5) - 30, y: (h * 0.3705) - (h * 0.2860 * 0.5) - 30, width: (w * 0.2444) + 60, height: (h * 0.2860) + 60)
                        if bookshelfRect.contains(releasePoint) || bookshelfRect.contains(value.location) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                storage.moveFloorItemsToBookshelf(filenames: groupFiles)
                                floorState.clearSelection()
                            }
                            floorState.draggingFloorFileName = nil
                            floorState.floorFileDragTranslation = .zero
                            return
                        }
                        
                        // 2. Check Photo Frame Slot Drop (Only if image file)
                        let galleryRect = CGRect(x: (w * 0.83125) - (w * 0.220 * 0.5) - 30, y: (h * 0.320) - (h * 0.440 * 0.5) - 30, width: (w * 0.220) + 60, height: (h * 0.440) + 60)
                        let isGalleryTargeted = galleryRect.contains(releasePoint) || galleryRect.contains(value.location)
                        if isGalleryTargeted && StorageManager.isImageFile(itemURL) {
                            let checkPt = galleryRect.contains(releasePoint) ? releasePoint : value.location
                            let targetSlot = slotIndexForGallery(point: checkPt, galleryRect: galleryRect)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                storage.assignPhoto(sourceURL: itemURL, slotIndex: targetSlot)
                                storage.removeFloorItem(itemURL: itemURL)
                                floorState.selectedFileNames.remove(itemURL.lastPathComponent)
                            }
                            floorState.draggingFloorFileName = nil
                            floorState.floorFileDragTranslation = .zero
                            return
                        }
                        
                        // 3. Check Trash Drop
                        let trashPoint = CGPoint(x: w * 0.710, y: h * 0.738)
                        let isDroppedOnTrash = hypot(releasePoint.x - trashPoint.x, releasePoint.y - trashPoint.y) < 85 ||
                                               hypot(value.location.x - trashPoint.x, value.location.y - trashPoint.y) < 85
                        if isDroppedOnTrash {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                for name in groupFiles {
                                    storage.removeFloorItem(itemURL: storage.carpetDirectory.appendingPathComponent(name))
                                }
                                floorState.clearSelection()
                            }
                            floorState.draggingFloorFileName = nil
                            floorState.floorFileDragTranslation = .zero
                            return
                        }
                        
                        // 4. Free desktop repositioning (Anywhere on desktop: desk, wall, carpet, floor)
                        if isGroup {
                            for name in floorState.selectedFileNames {
                                let orig = storage.positionForFloorItem(filename: name, index: 0, total: 1)
                                let nX = min(w * 0.96, max(w * 0.04, (orig.x * w) + value.translation.width))
                                let nY = min(h * 0.92, max(h * 0.06, (orig.y * h) + value.translation.height))
                                storage.setFloorPosition(for: name, normX: Double(nX / w), normY: Double(nY / h))
                            }
                        } else {
                            let clampedX = min(w * 0.96, max(w * 0.04, releasePoint.x))
                            let clampedY = min(h * 0.92, max(h * 0.06, releasePoint.y))
                            storage.setFloorPosition(for: itemURL.lastPathComponent, normX: Double(clampedX / w), normY: Double(clampedY / h))
                        }
                        floorState.draggingFloorFileName = nil
                        floorState.floorFileDragTranslation = .zero
                    }
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                NSWorkspace.shared.open(itemURL)
            }
        )
        .help("\(itemURL.lastPathComponent): Geser ke mana saja di desktop, ke rak buku, slot foto, atau tong sampah. Klik 2x untuk membuka.")
        .contextMenu {
            if isSelected && floorState.selectedFileNames.count > 1 {
                Button("Masukkan \(floorState.selectedFileNames.count) File ke Rak Buku") {
                    withAnimation(.spring()) {
                        storage.moveFloorItemsToBookshelf(filenames: Array(floorState.selectedFileNames))
                        floorState.clearSelection()
                    }
                }
                Button("Buang \(floorState.selectedFileNames.count) File ke Tempat Sampah", role: .destructive) {
                    withAnimation(.spring()) {
                        for name in floorState.selectedFileNames {
                            storage.removeFloorItem(itemURL: storage.carpetDirectory.appendingPathComponent(name))
                        }
                        floorState.clearSelection()
                    }
                }
                Button("Lepas Blok Pilihan") {
                    floorState.clearSelection()
                }
                Divider()
            }
            
            Button(isSelected ? "Lepas Pilihan (Unselect)" : "Pilih File Ini (Blok)") {
                floorState.toggleSelection(for: itemURL.lastPathComponent)
            }
            Button("Buka \(itemURL.lastPathComponent)") {
                NSWorkspace.shared.open(itemURL)
            }
            if StorageManager.isImageFile(itemURL) {
                Button("Pasang ke Bingkai Foto") {
                    withAnimation(.spring()) {
                        storage.assignFirstAvailablePhoto(from: itemURL)
                        storage.removeFloorItem(itemURL: itemURL)
                        floorState.selectedFileNames.remove(itemURL.lastPathComponent)
                    }
                }
            }
            Button("Masukkan ke Rak Buku") {
                withAnimation(.spring()) {
                    storage.moveFloorItemsToBookshelf(filenames: [itemURL.lastPathComponent])
                }
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
                    storage.removeFloorItem(itemURL: itemURL)
                }
            }
        }
    }
}

// MARK: - Floor Drop Delegate
struct FloorDropDelegate: DropDelegate {
    let screenSize: CGSize
    let storage: StorageManager
    @ObservedObject var floorState = FloorInteractionState.shared
    
    init(screenSize: CGSize, storage: StorageManager) {
        self.screenSize = screenSize
        self.storage = storage
    }
    
    func dropEntered(info: DropInfo) {
        floorState.isFloorTargeted = true
    }
    func dropExited(info: DropInfo) {
        floorState.isFloorTargeted = false
        AppState.shared.isTrashTargeted = false
        AppState.shared.isBookshelfTargeted = false
        AppState.shared.targetedPhotoSlot = nil
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let loc = info.location
        let w = screenSize.width
        let h = screenSize.height
        let trashPoint = CGPoint(x: w * 0.710, y: h * 0.738)
        let bookshelfRect = CGRect(x: (w * 0.1678) - (w * 0.2444 * 0.5) - 30, y: (h * 0.3705) - (h * 0.2860 * 0.5) - 30, width: (w * 0.2444) + 60, height: (h * 0.2860) + 60)
        let galleryRect = CGRect(x: (w * 0.83125) - (w * 0.220 * 0.5) - 30, y: (h * 0.320) - (h * 0.440 * 0.5) - 30, width: (w * 0.220) + 60, height: (h * 0.440) + 60)
        
        let isOverTrash = hypot(loc.x - trashPoint.x, loc.y - trashPoint.y) < 85
        if AppState.shared.isTrashTargeted != isOverTrash {
            AppState.shared.isTrashTargeted = isOverTrash
        }
        
        let isOverBookshelf = bookshelfRect.contains(loc)
        if AppState.shared.isBookshelfTargeted != isOverBookshelf {
            AppState.shared.isBookshelfTargeted = isOverBookshelf
        }
        
        if galleryRect.contains(loc) {
            let slot = slotIndexForGallery(point: loc, galleryRect: galleryRect)
            if AppState.shared.targetedPhotoSlot != slot {
                AppState.shared.targetedPhotoSlot = slot
            }
        } else if AppState.shared.targetedPhotoSlot != nil {
            AppState.shared.targetedPhotoSlot = nil
        }
        
        return DropProposal(operation: .copy)
    }
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.fileURL, .folder, .directory, .item])
    }
    func performDrop(info: DropInfo) -> Bool {
        floorState.isFloorTargeted = false
        AppState.shared.isTrashTargeted = false
        AppState.shared.isBookshelfTargeted = false
        AppState.shared.targetedPhotoSlot = nil
        let loc = info.location
        let w = screenSize.width
        let h = screenSize.height
        
        let providers = info.itemProviders(for: [.fileURL, .folder, .directory, .item])
        guard !providers.isEmpty else { return false }
        
        // 1. Direct Drop into Trash Can
        let trashPoint = CGPoint(x: w * 0.710, y: h * 0.738)
        if hypot(loc.x - trashPoint.x, loc.y - trashPoint.y) < 85 {
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    _ = storage.moveToTrash(url: url)
                }
            }
            return true
        }
        
        // 2. Direct Drop into Bookshelf
        let bookshelfRect = CGRect(x: (w * 0.1678) - (w * 0.2444 * 0.5) - 30, y: (h * 0.3705) - (h * 0.2860 * 0.5) - 30, width: (w * 0.2444) + 60, height: (h * 0.2860) + 60)
        if bookshelfRect.contains(loc) {
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        storage.addBookshelfItem(from: url)
                    }
                }
            }
            return true
        }
        
        // 3. Direct Drop into Photo Gallery Slot
        let galleryRect = CGRect(x: (w * 0.83125) - (w * 0.220 * 0.5) - 30, y: (h * 0.320) - (h * 0.440 * 0.5) - 30, width: (w * 0.220) + 60, height: (h * 0.440) + 60)
        if galleryRect.contains(loc) {
            let slot = slotIndexForGallery(point: loc, galleryRect: galleryRect)
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    if StorageManager.isImageFile(url) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            storage.assignPhoto(sourceURL: url, slotIndex: slot)
                        }
                    } else {
                        let normX = min(0.96, max(0.04, loc.x / w))
                        let normY = min(0.92, max(0.06, loc.y / h))
                        storage.addFloorItem(from: url, at: CGPoint(x: normX, y: normY))
                    }
                }
            }
            return true
        }
        
        // 4. Normal Desktop Drop anywhere!
        let normX = min(0.96, max(0.04, loc.x / w))
        let normY = min(0.92, max(0.06, loc.y / h))
        for provider in providers {
            StorageManager.extractFileURL(from: provider) { url in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    storage.addFloorItem(from: url, at: CGPoint(x: normX, y: normY))
                }
            }
        }
        return true
    }
}

// MARK: - Carpet / Rug Mat Body (Authentic Rectangular Arabic / Persian Oriental Rug)
struct CarpetMatBodyView: View {
    let theme: RoomTheme
    let itemCount: Int
    let isLifted: Bool
    @ObservedObject var floorState = FloorInteractionState.shared
    
    var body: some View {
        ZStack {
            // Rectangular Arabic Carpet Body with Fringes & Ornate Arabesque Pattern
            ArabicRugView()
            
            // Physical bumps on top of carpet when items are hidden inside (only when flat)
            if itemCount > 0 && !isLifted {
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
            
            // Hidden items count indicator or peek indicator
            VStack {
                if floorState.isCarpetTargeted {
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
                }
            }
        }
        .scaleEffect(floorState.isCarpetDragging ? 0.985 : 1.0)
    }
}

// MARK: - Dynamic Realistic Cloth Wrinkle & Wave Folds Overlay
struct CarpetClothFoldsView: View {
    let width: CGFloat
    let height: CGFloat
    @ObservedObject var floorState = FloorInteractionState.shared
    
    var body: some View {
        let offset = floorState.carpetDragOffset.width
        let isMoving = floorState.isCarpetDragging
        let foldOpacity = floorState.isCarpetDragging ? 0.75 : 0.14
        let dragDir: CGFloat = offset >= 0 ? 1.0 : -1.0
        
        ZStack {
            // Realistic undulating wave wrinkles across the velvet fabric body
            HStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { i in
                    let foldPhase = CGFloat(i)
                    // Wave ripple traveling displacement based on drag offset
                    let waveShift = isMoving ? sin((offset * 0.038) + foldPhase * 1.3) * 8.0 : 0
                    
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
                    .rotationEffect(.degrees(Double((i % 2 == 0 ? 1 : -1) * 2) * (isMoving ? 1.0 : 0.3)))
                    
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
                        Color.black.opacity(0.32 * foldOpacity),
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
    }
}

// MARK: - Authentic Rectangular Arabic / Oriental Persian Rug View (Enlarged with Cloth Dynamics)
struct ArabicRugView: View {
    @ObservedObject var floorState = FloorInteractionState.shared
    
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
                if floorState.isCarpetTargeted {
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
            .drawingGroup()
            
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
    @ObservedObject var floorState = FloorInteractionState.shared
    
    var body: some View {
        let dragRatio = max(-1.0, min(1.0, floorState.carpetDragOffset.width / 240.0))
        let flutterAngle = Double(dragRatio) * (isLeading ? -5.0 : 5.0) * (floorState.isCarpetDragging ? 1.0 : 0.0)
        
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
