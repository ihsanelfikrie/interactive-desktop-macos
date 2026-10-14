import SwiftUI
import UniformTypeIdentifiers

public struct PhotoGalleryView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 18) {
            PhotoFrameItemView(slotIndex: 0, width: 125, height: 145, frameColor: Color(red: 0.28, green: 0.18, blue: 0.10))
            PhotoFrameItemView(slotIndex: 1, width: 125, height: 145, frameColor: Color(red: 0.35, green: 0.25, blue: 0.16))
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
            // Outer Frame
            RoundedRectangle(cornerRadius: 4)
                .fill(frameColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isTargeted ? Color.yellow : Color.white.opacity(0.18), lineWidth: isTargeted ? 3 : 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 4, x: 2, y: 3)
            
            // White Matting / Margin
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white)
                .padding(6)
            
            // Photo Content
            if let image = cachedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width - 18, height: height - 18)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = photoURL {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .help("Klik untuk melihat foto")
            } else {
                // Empty state drop & click target
                Button(action: {
                    storage.pickPhoto(forSlot: slotIndex)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 16))
                            .foregroundColor(isTargeted ? .yellow : .gray.opacity(0.7))
                        Text("Drop / Klik Foto")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(isTargeted ? .yellow : .gray.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .help("Klik untuk memilih foto atau drag foto ke sini")
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
                StorageManager.extractFileURL(from: provider) { url in
                    storage.assignPhoto(sourceURL: url, slotIndex: slotIndex)
                }
            }
            return true
        }
    }
}
