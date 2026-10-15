import SwiftUI
import AppKit

public struct DesktopAwardPlaqueView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let svgFileName: String
    let quickViewType: ActiveDesktopQuickView
    
    @ObservedObject var appState = AppState.shared
    
    public init(
        title: String,
        subtitle: String,
        imageName: String,
        svgFileName: String,
        quickViewType: ActiveDesktopQuickView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.svgFileName = svgFileName
        self.quickViewType = quickViewType
    }
    
    private var isHovered: Bool {
        appState.hoveredPlaque == quickViewType
    }
    
    private func getFileURL() -> URL {
        let candidates = [
            "Assets/Logos/\(svgFileName)",
            "Assets/\(svgFileName)",
            svgFileName
        ]
        let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        for rel in candidates {
            let u = currentDir.appendingPathComponent(rel)
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Custom Desktop Mac")
        for rel in candidates {
            let u = homeDir.appendingPathComponent(rel)
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        return currentDir.appendingPathComponent(svgFileName)
    }
    
    private func openSVG() {
        let url = getFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.open(url)
        }
    }
    
    public var body: some View {
        ZStack {
            if let img = AssetLoader.image(named: imageName) {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .brightness(isHovered ? 0.08 : 0.0)
                    .shadow(color: isHovered ? Color.yellow.opacity(0.30) : Color.clear, radius: 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            openSVG()
        }
        .onTapGesture {
            appState.toggleQuickView(quickViewType)
        }
        .onHover { hovering in
            if hovering {
                appState.hoveredPlaque = quickViewType
            } else if appState.hoveredPlaque == quickViewType {
                appState.hoveredPlaque = nil
            }
        }
        .help("\(title): Klik 1x untuk opsi, klik 2x untuk membuka file logo")
    }
}
