import SwiftUI
import UniformTypeIdentifiers
import AppKit

public struct TrashCanView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private let canWidth: CGFloat = 84
    private let canHeight: CGFloat = 114
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Soft contact shadow on grass floor
            Ellipse()
                .fill(Color(red: 0.08, green: 0.22, blue: 0.10).opacity(0.38))
                .frame(width: canWidth * 0.88, height: 16)
                .blur(radius: 5)
                .offset(y: 5)
            
            // 2. High-Resolution Cartoon Wastebasket Asset
            if let nsImg = AssetLoader.image(named: "trash_can") {
                Image(nsImage: nsImg)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: canWidth, height: canHeight)
                    .shadow(
                        color: appState.isTrashTargeted ? Color.red.opacity(0.65) : (appState.isHoveringTrash ? Color.black.opacity(0.28) : Color.black.opacity(0.12)),
                        radius: appState.isTrashTargeted ? 12 : (appState.isHoveringTrash ? 8 : 4),
                        x: 0, y: 3
                    )
                    .scaleEffect(appState.isTrashTargeted ? 1.05 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.75), value: appState.isTrashTargeted)
            }
            
            // 3. Drop Target Indicator (Glowing badge when dragging a file over trash)
            if appState.isTrashTargeted {
                VStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .red, radius: 8)
                        .offset(y: -canHeight - 12)
                    Spacer()
                }
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            appState.isHoveringTrash = hovering
        }
        .onTapGesture(count: 2) {
            if let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first {
                NSWorkspace.shared.open(trashURL)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                appState.toggleQuickView(.trash)
            }
        }
        .help("Tempat Sampah: Klik 1x untuk opsi & kosongkan sampah, klik 2x untuk buka di Finder. Tarik file ke sini untuk membuangnya.")
        .onDrop(of: [.fileURL], isTargeted: Binding(
            get: { appState.isTrashTargeted },
            set: { appState.isTrashTargeted = $0 }
        )) { providers in
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    _ = storage.moveToTrash(url: url)
                }
            }
            return true
        }
    }
}
