import SwiftUI
import UniformTypeIdentifiers
import AppKit

public struct PhotoGalleryView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Row 1
            HStack(spacing: 14) {
                PhotoFrameItemView(
                    slotIndex: 0,
                    width: 170,
                    height: 128,
                    frameColor: Color(red: 0.68, green: 0.50, blue: 0.32), // Warm Honey Oak
                    innerBevel: Color(red: 0.82, green: 0.65, blue: 0.44)
                )
                // Slot 1: Vertical Oval Frame
                PhotoFrameItemView(
                    slotIndex: 1,
                    width: 120,
                    height: 138,
                    frameColor: Color(red: 0.22, green: 0.16, blue: 0.12), // Dark Espresso Walnut
                    innerBevel: Color(red: 0.38, green: 0.28, blue: 0.20),
                    isOval: true
                )
            }
            // Row 2
            HStack(spacing: 14) {
                // Slot 2: Vertical Oval Frame
                PhotoFrameItemView(
                    slotIndex: 2,
                    width: 120,
                    height: 138,
                    frameColor: Color(red: 0.16, green: 0.14, blue: 0.13), // Deep Ebony Charcoal
                    innerBevel: Color(red: 0.32, green: 0.30, blue: 0.28),
                    isOval: true
                )
                PhotoFrameItemView(
                    slotIndex: 3,
                    width: 170,
                    height: 128,
                    frameColor: Color(red: 0.46, green: 0.28, blue: 0.16), // Warm Mahogany
                    innerBevel: Color(red: 0.62, green: 0.40, blue: 0.24)
                )
            }
            // Row 3
            HStack(spacing: 14) {
                PhotoFrameItemView(
                    slotIndex: 4,
                    width: 170,
                    height: 124,
                    frameColor: Color(red: 0.58, green: 0.40, blue: 0.24), // Classic Teak
                    innerBevel: Color(red: 0.74, green: 0.54, blue: 0.34)
                )
                PhotoFrameItemView(
                    slotIndex: 5,
                    width: 120,
                    height: 124,
                    frameColor: Color(red: 0.24, green: 0.18, blue: 0.14), // Rich Walnut
                    innerBevel: Color(red: 0.40, green: 0.30, blue: 0.22)
                )
            }
        }
        .padding(6)
    }
}

struct PhotoFrameItemView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    let slotIndex: Int
    let width: CGFloat
    let height: CGFloat
    let frameColor: Color
    let innerBevel: Color
    var isOval: Bool = false
    
    var dragOffset: CGSize {
        if appState.draggingPhotoSlot == slotIndex {
            return appState.photoDragTranslation
        }
        return .zero
    }
    
    var isTargeted: Bool {
        appState.targetedPhotoSlot == slotIndex
    }
    
    var isHovering: Bool {
        appState.hoveredPhotoSlot == slotIndex
    }
    
    var photoURL: URL? {
        storage.photoSlots[slotIndex]
    }
    
    var cachedImage: NSImage? {
        storage.cachedPhotos[slotIndex]
    }
    
    var body: some View {
        let transform = storage.transform(for: slotIndex)
        let totalOffsetX = transform.offsetX + dragOffset.width
        let totalOffsetY = transform.offsetY + dragOffset.height
        let contentW = max(20, width - (isOval ? 26 : 24))
        let contentH = max(20, height - (isOval ? 26 : 24))
        
        ZStack {
            // 1. Outer Wooden Molding Frame (Oval or Rounded Rect)
            if isOval {
                Ellipse()
                    .fill(frameColor)
                    .overlay(
                        Ellipse()
                            .stroke(innerBevel, lineWidth: 1.5)
                            .padding(2)
                    )
                    .overlay(
                        Group {
                            if isTargeted {
                                Ellipse()
                                    .stroke(SANSColors.lime, lineWidth: 3)
                                    .shadow(color: SANSColors.lime, radius: 6)
                            }
                        }
                    )
                    .shadow(color: .black.opacity(0.38), radius: 5, x: 1, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(frameColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(innerBevel, lineWidth: 1.2)
                            .padding(1.5)
                    )
                    .overlay(
                        Group {
                            if isTargeted {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(SANSColors.lime, lineWidth: 3)
                                    .shadow(color: SANSColors.lime, radius: 6)
                            }
                        }
                    )
                    .shadow(color: .black.opacity(0.38), radius: 5, x: 1, y: 3)
            }
            
            // 2. Off-white Museum Passe-partout / Matting
            if isOval {
                Ellipse()
                    .fill(Color(red: 0.98, green: 0.96, blue: 0.92))
                    .overlay(
                        Ellipse()
                            .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
                    )
                    .padding(8)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.98, green: 0.96, blue: 0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
                    )
                    .padding(7)
            }
            
            // 3. Photo with Customizable Pan, Zoom & Rotation
            if let image = cachedImage {
                if isOval {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: contentW, height: contentH)
                        .scaleEffect(transform.scale)
                        .rotationEffect(.degrees(transform.rotation))
                        .offset(x: totalOffsetX, y: totalOffsetY)
                        .frame(width: contentW, height: contentH)
                        .clipShape(Ellipse())
                        .contentShape(Ellipse())
                        .gesture(
                            DragGesture(minimumDistance: 4)
                                .onChanged { value in
                                    appState.draggingPhotoSlot = slotIndex
                                    appState.photoDragTranslation = value.translation
                                }
                                .onEnded { value in
                                    if abs(value.translation.width) < 3 && abs(value.translation.height) < 3 {
                                        AppState.shared.toggleQuickView(.photo(slot: slotIndex))
                                    } else {
                                        var newTransform = transform
                                        newTransform.offsetX += value.translation.width
                                        newTransform.offsetY += value.translation.height
                                        storage.updateTransform(for: slotIndex, transform: newTransform)
                                    }
                                    appState.draggingPhotoSlot = nil
                                    appState.photoDragTranslation = .zero
                                }
                        )
                        .onTapGesture(count: 2) {
                            if let url = photoURL {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .onTapGesture {
                            AppState.shared.toggleQuickView(.photo(slot: slotIndex))
                        }
                        .help("Bingkai Foto: Geser untuk menyesuaikan posisi, klik untuk zoom/rotate, klik 2x untuk buka di Preview")
                } else {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: contentW, height: contentH)
                        .scaleEffect(transform.scale)
                        .rotationEffect(.degrees(transform.rotation))
                        .offset(x: totalOffsetX, y: totalOffsetY)
                        .frame(width: contentW, height: contentH)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 4)
                                .onChanged { value in
                                    appState.draggingPhotoSlot = slotIndex
                                    appState.photoDragTranslation = value.translation
                                }
                                .onEnded { value in
                                    if abs(value.translation.width) < 3 && abs(value.translation.height) < 3 {
                                        AppState.shared.toggleQuickView(.photo(slot: slotIndex))
                                    } else {
                                        var newTransform = transform
                                        newTransform.offsetX += value.translation.width
                                        newTransform.offsetY += value.translation.height
                                        storage.updateTransform(for: slotIndex, transform: newTransform)
                                    }
                                    appState.draggingPhotoSlot = nil
                                    appState.photoDragTranslation = .zero
                                }
                        )
                        .onTapGesture(count: 2) {
                            if let url = photoURL {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .onTapGesture {
                            AppState.shared.toggleQuickView(.photo(slot: slotIndex))
                        }
                        .help("Bingkai Foto: Geser untuk menyesuaikan posisi, klik untuk zoom/rotate, klik 2x untuk buka di Preview")
                }
            } else {
                Button(action: {
                    storage.pickPhoto(forSlot: slotIndex)
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: "photo")
                            .font(.system(size: 14))
                            .foregroundColor(isTargeted ? SANSColors.primaryBlue : Color.gray.opacity(0.6))
                        Text("Tarik Foto 🖼️")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(isTargeted ? SANSColors.primaryBlue : Color.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .help("Tarik foto ke sini untuk dipajang atau klik untuk memilih file")
            }
            
            // 4. Natural Museum Glass Reflection Effect (Efek Kaca)
            glassEffectOverlay(isOval: isOval)
            
            // Hover controls
            if isHovering && photoURL != nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                storage.ejectPhotoToFloor(slotIndex: slotIndex)
                            }
                        }) {
                            Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(SANSColors.lime)
                                .background(Circle().fill(Color.black.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                        .padding(5)
                        .help("Keluarkan foto ke lantai rumput")
                    }
                    Spacer()
                }
            }
        }
        .frame(width: width, height: height)
        .onHover { hovering in
            if hovering {
                appState.hoveredPhotoSlot = slotIndex
            } else if appState.hoveredPhotoSlot == slotIndex {
                appState.hoveredPhotoSlot = nil
            }
        }
        .onDrop(of: [.fileURL, .image], isTargeted: Binding(
            get: { appState.targetedPhotoSlot == slotIndex },
            set: { targeted in
                appState.targetedPhotoSlot = targeted ? slotIndex : nil
            }
        )) { providers in
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    if StorageManager.isImageFile(url) {
                        withAnimation(.spring()) {
                            storage.assignPhoto(sourceURL: url, slotIndex: slotIndex)
                        }
                    }
                }
            }
            return true
        }
        .contextMenu {
            if let url = photoURL {
                Button("Buka Foto di Preview") {
                    NSWorkspace.shared.open(url)
                }
                Button("Ganti Foto...") {
                    storage.pickPhoto(forSlot: slotIndex)
                }
                Divider()
                Button("Keluarkan ke Lantai Rumput") {
                    withAnimation(.spring()) {
                        storage.ejectPhotoToFloor(slotIndex: slotIndex)
                    }
                }
                Button("Hapus Foto dari Bingkai", role: .destructive) {
                    withAnimation(.spring()) {
                        storage.removePhoto(slotIndex: slotIndex)
                    }
                }
            } else {
                Button("Pilih Foto untuk Bingkai Ini...") {
                    storage.pickPhoto(forSlot: slotIndex)
                }
            }
            Divider()
            Button("Buka Folder Album di Finder") {
                storage.openInFinder(url: storage.photosDirectory)
            }
        }
    }
    
    // Natural Museum Glass Reflection Effect (Efek Kaca)
    @ViewBuilder
    private func glassEffectOverlay(isOval: Bool) -> some View {
        let paddingVal: CGFloat = isOval ? 9 : 8
        if isOval {
            ZStack {
                // 1. Translucent ambient light sheen
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.04),
                        Color.clear,
                        Color.white.opacity(0.09)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 2. Diagonal Museum Light Sheen
                GeometryReader { g in
                    Path { path in
                        let w = g.size.width
                        let h = g.size.height
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: w * 0.72, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: h * 0.72))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.24), Color.white.opacity(0.01)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                // 3. Crisp Inner Glass Rim & Refraction Highlight
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.55), Color.clear, Color.black.opacity(0.20)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            }
            .clipShape(Ellipse())
            .padding(paddingVal)
            .clipShape(Ellipse())
            .allowsHitTesting(false)
        } else {
            ZStack {
                // 1. Translucent ambient light sheen
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.04),
                        Color.clear,
                        Color.white.opacity(0.09)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 2. Diagonal Museum Light Sheen
                GeometryReader { g in
                    Path { path in
                        let w = g.size.width
                        let h = g.size.height
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: w * 0.72, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: h * 0.72))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.24), Color.white.opacity(0.01)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                // 3. Crisp Inner Glass Rim & Refraction Highlight
                RoundedRectangle(cornerRadius: 2)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.55), Color.clear, Color.black.opacity(0.20)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .padding(paddingVal)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .allowsHitTesting(false)
        }
    }
}
