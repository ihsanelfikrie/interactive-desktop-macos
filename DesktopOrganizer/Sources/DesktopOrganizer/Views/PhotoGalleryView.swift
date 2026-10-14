import SwiftUI
import UniformTypeIdentifiers

public struct PhotoGalleryView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Row 1
            HStack(spacing: 12) {
                PhotoFrameItemView(slotIndex: 0, width: 130, height: 95, frameColor: SANSColors.cleanWhite)
                PhotoFrameItemView(slotIndex: 1, width: 95, height: 95, frameColor: SANSColors.cleanWhite)
            }
            // Row 2
            HStack(spacing: 12) {
                PhotoFrameItemView(slotIndex: 2, width: 95, height: 95, frameColor: SANSColors.cleanWhite)
                PhotoFrameItemView(slotIndex: 3, width: 130, height: 95, frameColor: SANSColors.cleanWhite)
            }
            // Row 3
            HStack(spacing: 12) {
                PhotoFrameItemView(slotIndex: 4, width: 130, height: 90, frameColor: SANSColors.cleanWhite)
                PhotoFrameItemView(slotIndex: 5, width: 95, height: 90, frameColor: SANSColors.cleanWhite)
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
            // Outer Frame (SANS Clean White with subtle border)
            RoundedRectangle(cornerRadius: 4)
                .fill(frameColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isTargeted ? SANSColors.lime : SANSColors.border, lineWidth: isTargeted ? 3 : 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 3, x: 1, y: 2)
            
            // White Matting / Margin
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(white: 0.98))
                .padding(5)
            
            // Photo Content
            if let image = cachedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(20, width - 14), height: max(20, height - 14))
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = photoURL {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .help("Klik untuk melihat foto di Preview")
            } else {
                // Empty state drop & click target
                Button(action: {
                    storage.pickPhoto(forSlot: slotIndex)
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 13))
                            .foregroundColor(isTargeted ? SANSColors.lime : Color.gray.opacity(0.7))
                        Text("Tarik Foto 🖼️")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(isTargeted ? SANSColors.lime : Color.gray.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .help("Tarik foto ke sini untuk dipajang atau klik untuk memilih file")
            }
            
            // Hover controls to remove photo
            if isHovering && photoURL != nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            storage.removePhoto(slotIndex: slotIndex)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(SANSColors.pink)
                                .background(Circle().fill(Color.white))
                        }
                        .buttonStyle(.plain)
                        .padding(4)
                        .help("Hapus foto")
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
                    storage.assignPhoto(sourceURL: url, slotIndex: slotIndex)
                }
            }
            return true
        }
    }
}
