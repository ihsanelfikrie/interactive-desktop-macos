import SwiftUI
import AppKit

// MARK: - Fender Stratocaster Guitar View
public struct StratocasterGuitarView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                appState.toggleQuickView(.guitar)
            }
        }) {
            ZStack {
                // 1. Soft Wall & Floor Contact Shadows
                ZStack {
                    // Contact shadow directly beneath body butt on floor planks
                    Ellipse()
                        .fill(Color.black.opacity(0.48))
                        .frame(width: 140, height: 26)
                        .blur(radius: 8)
                        .offset(x: -28, y: 175)
                    
                    // Secondary diffuse floor reflection/shadow
                    Ellipse()
                        .fill(Color.black.opacity(0.24))
                        .frame(width: 180, height: 36)
                        .blur(radius: 14)
                        .offset(x: -20, y: 180)
                    
                    // Ambient occlusion shadow on wall behind neck & headstock
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.22))
                        .frame(width: 44, height: 260)
                        .blur(radius: 12)
                        .rotationEffect(.degrees(-26))
                        .offset(x: 48, y: -65)
                }
                
                // 2. High-Resolution Fender Stratocaster Asset
                if let nsImg = AssetLoader.image(named: "stratocaster") {
                    Image(nsImage: nsImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(
                            color: Color.black.opacity(appState.isHoveringGuitar ? 0.45 : 0.28),
                            radius: appState.isHoveringGuitar ? 12 : 7,
                            x: 4, y: 5
                        )
                        .scaleEffect(appState.isHoveringGuitar ? 1.03 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: appState.isHoveringGuitar)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            appState.isHoveringGuitar = hovering
        }
        .onTapGesture(count: 2) {
            openMusicOrGarageBand()
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                appState.toggleQuickView(.guitar)
            }
        }
        .help("Fender Stratocaster: Klik 1x untuk info & tes petik senar, klik 2x untuk membuka GarageBand / Musik")
    }
    
    private func openMusicOrGarageBand() {
        if let gbURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.garageband10") {
            NSWorkspace.shared.openApplication(at: gbURL, configuration: NSWorkspace.OpenConfiguration())
        } else if let musicURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
            NSWorkspace.shared.openApplication(at: musicURL, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Music.app"))
        }
    }
}
