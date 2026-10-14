import SwiftUI
import UniformTypeIdentifiers
import AppKit

public struct PhotoGalleryView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 14) {
            // Row 1
            HStack(spacing: 14) {
                PhotoFrameItemView(
                    slotIndex: 0,
                    width: 130,
                    height: 98,
                    frameColor: Color(red: 0.68, green: 0.50, blue: 0.32), // Warm Honey Oak
                    innerBevel: Color(red: 0.82, green: 0.65, blue: 0.44)
                )
                PhotoFrameItemView(
                    slotIndex: 1,
                    width: 98,
                    height: 98,
                    frameColor: Color(red: 0.22, green: 0.16, blue: 0.12), // Dark Espresso Walnut
                    innerBevel: Color(red: 0.38, green: 0.28, blue: 0.20)
                )
            }
            // Row 2
            HStack(spacing: 14) {
                PhotoFrameItemView(
                    slotIndex: 2,
                    width: 98,
                    height: 98,
                    frameColor: Color(red: 0.16, green: 0.14, blue: 0.13), // Deep Ebony Charcoal
                    innerBevel: Color(red: 0.32, green: 0.30, blue: 0.28)
                )
                PhotoFrameItemView(
                    slotIndex: 3,
                    width: 130,
                    height: 98,
                    frameColor: Color(red: 0.46, green: 0.28, blue: 0.16), // Warm Mahogany
                    innerBevel: Color(red: 0.62, green: 0.40, blue: 0.24)
                )
            }
            // Row 3
            HStack(spacing: 14) {
                PhotoFrameItemView(
                    slotIndex: 4,
                    width: 130,
                    height: 94,
                    frameColor: Color(red: 0.58, green: 0.40, blue: 0.24), // Classic Teak
                    innerBevel: Color(red: 0.74, green: 0.54, blue: 0.34)
                )
                PhotoFrameItemView(
                    slotIndex: 5,
                    width: 98,
                    height: 94,
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
        ZStack {
            // 1. Outer Wooden Molding Frame
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
            
            // 2. Off-white Museum Passe-partout / Matting
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.98, green: 0.96, blue: 0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
                )
                .padding(7)
            
            // 3. Photo or Empty State inside Matting
            if let image = cachedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(20, width - 24), height: max(20, height - 24))
                    .clipped()
                    .cornerRadius(1.5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = photoURL {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .help("Klik untuk melihat foto di Preview")
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
            
            // Hover controls
            if isHovering && photoURL != nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                storage.removePhoto(slotIndex: slotIndex)
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(SANSColors.pink)
                                .background(Circle().fill(Color.white))
                        }
                        .buttonStyle(.plain)
                        .padding(5)
                        .help("Hapus foto dari bingkai")
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
        .onDrop(of: [.fileURL], isTargeted: Binding(
            get: { appState.targetedPhotoSlot == slotIndex },
            set: { targeted in
                appState.targetedPhotoSlot = targeted ? slotIndex : nil
            }
        )) { providers in
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    withAnimation(.spring()) {
                        storage.assignPhoto(sourceURL: url, slotIndex: slotIndex)
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
                Button("Hapus Foto dari Bingkai") {
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
}
