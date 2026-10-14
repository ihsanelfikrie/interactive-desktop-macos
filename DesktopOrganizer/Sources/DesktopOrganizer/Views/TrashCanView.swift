import SwiftUI
import UniformTypeIdentifiers

public struct TrashCanView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        Button(action: {
            // Open macOS Trash in Finder
            if let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first {
                NSWorkspace.shared.open(trashURL)
            }
        }) {
            ZStack(alignment: .top) {
                // Bin Rim
                Ellipse()
                    .stroke(appState.isTrashTargeted ? Color.red : Color.gray, lineWidth: appState.isTrashTargeted ? 3 : 2)
                    .background(Ellipse().fill(Color.black.opacity(0.6)))
                    .frame(width: 44, height: 16)
                
                // Bin Body (tapered wire mesh basket)
                Path { path in
                    path.move(to: CGPoint(x: 2, y: 8))
                    path.addLine(to: CGPoint(x: 8, y: 56))
                    path.addLine(to: CGPoint(x: 36, y: 56))
                    path.addLine(to: CGPoint(x: 42, y: 8))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: appState.isTrashTargeted ? [Color.red.opacity(0.8), Color.red.opacity(0.4)] : [Color(white: 0.55), Color(white: 0.35)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // Wire mesh grid lines
                    VStack(spacing: 5) {
                        ForEach(0..<6, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.35))
                                .frame(height: 1)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 6)
                )
                
                // Icon
                VStack {
                    Spacer()
                    Image(systemName: appState.isTrashTargeted ? "trash.fill" : "trash")
                        .font(.system(size: 16))
                        .foregroundColor(appState.isTrashTargeted ? .yellow : .white.opacity(0.9))
                        .padding(.bottom, 12)
                }
            }
            .frame(width: 44, height: 58)
            .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
        .onDrop(of: [.fileURL], isTargeted: Binding(
            get: { appState.isTrashTargeted },
            set: { appState.isTrashTargeted = $0 }
        )) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            _ = storage.moveToTrash(url: url)
                        }
                    }
                }
            }
            return true
        }
        .help("Tempat Sampah: Tarik file ke sini untuk membuangnya ke Trash")
    }
}
