import SwiftUI
import AppKit

// MARK: - Native Apple Visual Effect View (Frosted / Liquid Glass)
public struct VisualEffectView: NSViewRepresentable {
    public let material: NSVisualEffectView.Material
    public let blendingMode: NSVisualEffectView.BlendingMode
    public let state: NSVisualEffectView.State

    public init(
        material: NSVisualEffectView.Material = .popover,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
        state: NSVisualEffectView.State = .active
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

// MARK: - Shelf Flyout Popover View (Modern Apple Liquid Glass)
public struct ShelfFlyoutPopoverView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let url: URL
    let shelfIndex: Int
    let onClose: () -> Void
    
    public init(url: URL, shelfIndex: Int = 1, onClose: @escaping () -> Void = {}) {
        self.url = url
        self.shelfIndex = shelfIndex
        self.onClose = onClose
    }
    
    private var isFolder: Bool {
        ShelfItemView.isFolder(url)
    }
    
    private var isApp: Bool {
        url.pathExtension.lowercased() == "app"
    }
    
    private var folderContents: [URL] {
        guard isFolder else { return [] }
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return files.sorted {
            let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            return d1 > d2
        }
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Apple Liquid Glass Triangle Pointer pointing left at the bookshelf item
            LeftArrowPointer()
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.85))
                .background(
                    LeftArrowPointer()
                        .fill(Color.white.opacity(0.4))
                )
                .frame(width: 9, height: 16)
                .overlay(
                    LeftArrowPointer()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.70), Color.white.opacity(0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.12), radius: 3, x: -1, y: 0)
            
            // Apple Liquid Glass Popover Body Card
            VStack(alignment: .leading, spacing: 0) {
                // Header (Apple SF Pro typography & folder badge)
                HStack(spacing: 8) {
                    if isFolder {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.blue)
                    } else if isApp {
                        Image(systemName: "app.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.purple)
                    } else {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.indigo)
                    }
                    
                    Text(url.lastPathComponent)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    if isFolder {
                        Text("\(folderContents.count)")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.primary.opacity(0.08)))
                    }
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.primary.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                    .help("Tutup")
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .background(Color.primary.opacity(0.08))
                
                // Content: file list for directory, or single file inspector for book
                if isFolder {
                    if folderContents.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 22))
                                .foregroundColor(.secondary)
                            Text("Folder ini kosong")
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(alignment: .leading, spacing: 2) {
                                ForEach(folderContents, id: \.self) { fileURL in
                                    ShelfFlyoutRow(fileURL: fileURL, onOpen: {
                                        NSWorkspace.shared.open(fileURL)
                                    })
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                        }
                        .frame(maxHeight: 280)
                    }
                } else {
                    // Single file details view (Apple Inspector Card)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            fileIconView(for: url)
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(url.lastPathComponent)
                                    .font(.system(size: 12.5, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                                   let size = attrs[.size] as? Int64 {
                                    Text("\(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)) • Buku / File")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                NSWorkspace.shared.open(url)
                                onClose()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.forward.app")
                                    Text("Buka")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.blue))
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                storage.openInFinder(url: url)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "folder")
                                    Text("Finder")
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.primary.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            Button(action: {
                                storage.restoreBookshelfItemToDesktop(itemURL: url)
                                onClose()
                            }) {
                                Image(systemName: "arrowshape.turn.up.backward.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .padding(7)
                                    .background(Circle().fill(Color.primary.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                            .help("Kembalikan ke Desktop")
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                    }
                }
            }
            .frame(width: 275)
            .background(
                ZStack {
                    VisualEffectView(material: .popover, blendingMode: .withinWindow)
                    
                    Color(NSColor.windowBackgroundColor).opacity(0.65)
                    
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.20), radius: 24, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - Row inside Shelf Flyout
private struct ShelfFlyoutRow: View {
    let fileURL: URL
    let onOpen: () -> Void
    @ObservedObject var appState = AppState.shared
    @ObservedObject var storage = StorageManager.shared
    
    var isHovered: Bool { appState.hoveredFlyoutURL == fileURL }
    
    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 8) {
                fileIconView(for: fileURL)
                    .frame(width: 18, height: 18)
                
                Text(fileURL.lastPathComponent)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.primary.opacity(0.09) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            appState.hoveredFlyoutURL = hovering ? fileURL : (appState.hoveredFlyoutURL == fileURL ? nil : appState.hoveredFlyoutURL)
        }
        .contextMenu {
            Button("Buka") { NSWorkspace.shared.open(fileURL) }
            Button("Tampilkan di Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            }
            Divider()
            Button("Salin Nama File") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(fileURL.lastPathComponent, forType: .string)
            }
            Button("Buang ke Tempat Sampah", role: .destructive) {
                try? FileManager.default.trashItem(at: fileURL, resultingItemURL: nil)
            }
        }
    }
}

// MARK: - Helper File Icon Generator (Apple SF Symbols with Vibrant Colors)
@ViewBuilder
private func fileIconView(for url: URL) -> some View {
    let ext = url.pathExtension.lowercased()
    
    if ["png", "jpg", "jpeg", "heic", "gif", "webp", "tiff", "svg"].contains(ext) {
        Image(systemName: "photo")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.teal)
    } else if ["mp4", "mov", "mkv", "avi", "m4v"].contains(ext) {
        Image(systemName: "film")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.purple)
    } else if ["mp3", "wav", "m4a", "flac", "aac"].contains(ext) {
        Image(systemName: "music.note")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.pink)
    } else if ["zip", "rar", "tar", "gz", "7z"].contains(ext) {
        Image(systemName: "archivebox.fill")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.orange)
    } else if ["pdf"].contains(ext) {
        Image(systemName: "doc.richtext.fill")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.red)
    } else {
        Image(systemName: "doc.text")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.secondary)
    }
}

// MARK: - Triangle Pointer Left Arrow
private struct LeftArrowPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
