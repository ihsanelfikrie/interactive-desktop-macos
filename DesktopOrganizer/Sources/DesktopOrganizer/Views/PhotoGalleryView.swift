import SwiftUI
import UniformTypeIdentifiers

public struct PhotoGalleryView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Row 1
            HStack(spacing: 12) {
                PhotoFrameItemView(slotIndex: 0, width: 105, height: 105, frameColor: .black)
                PhotoFrameItemView(slotIndex: 1, width: 135, height: 105, frameColor: Color(red: 0.45, green: 0.30, blue: 0.18))
            }
            
            // Row 2
            HStack(spacing: 12) {
                PhotoFrameItemView(slotIndex: 2, width: 125, height: 95, frameColor: Color(red: 0.30, green: 0.20, blue: 0.15))
                PhotoFrameItemView(slotIndex: 3, width: 115, height: 95, frameColor: .black)
            }
            
            // Row 3
            HStack(spacing: 12) {
                PhotoFrameItemView(slotIndex: 4, width: 140, height: 85, frameColor: Color(red: 0.65, green: 0.52, blue: 0.25))
                PhotoFrameItemView(slotIndex: 5, width: 100, height: 85, frameColor: Color(red: 0.35, green: 0.22, blue: 0.15))
            }
        }
        .padding(8)
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
            // Outer Frame
            RoundedRectangle(cornerRadius: 4)
                .fill(frameColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isTargeted ? Color.yellow : Color.white.opacity(0.15), lineWidth: isTargeted ? 3 : 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 4, x: 2, y: 3)
            
            // White Matting / Margin
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white)
                .padding(6)
            
            // Photo Content (Rendered from cached image in memory)
            if let image = cachedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width - 18, height: height - 18)
                    .clipped()
                    .onTapGesture {
                        if let url = photoURL {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .help("Klik untuk melihat foto")
            } else {
                // Empty state drop target
                VStack(spacing: 4) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(isTargeted ? .yellow : .gray.opacity(0.6))
                    Text("Drop Foto")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(isTargeted ? .yellow : .gray.opacity(0.7))
                }
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
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .background(Circle().fill(Color.white))
                        }
                        .buttonStyle(.plain)
                        .padding(4)
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
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            storage.assignPhoto(sourceURL: url, slotIndex: slotIndex)
                        }
                    }
                }
            }
            return true
        }
    }
}
