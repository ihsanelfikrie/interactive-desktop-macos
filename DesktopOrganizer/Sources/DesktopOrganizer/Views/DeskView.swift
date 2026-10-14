import SwiftUI
import AppKit

public struct DeskView: View {
    let theme: RoomTheme
    @Binding var isNightMode: Bool
    @Binding var showSpotifyPopup: Bool
    
    public init(theme: RoomTheme, isNightMode: Binding<Bool>, showSpotifyPopup: Binding<Bool>) {
        self.theme = theme
        self._isNightMode = isNightMode
        self._showSpotifyPopup = showSpotifyPopup
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Props Resting Directly on Tabletop
            HStack(alignment: .bottom, spacing: 0) {
                // Desk Lamp (Left side of tabletop)
                DeskLampView(isOn: !isNightMode) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isNightMode.toggle()
                    }
                }
                .padding(.leading, 36)
                
                Spacer()
                
                // Envelope / Letter (Center of tabletop)
                LetterEnvelopeView {
                    openMailApp()
                }
                
                Spacer()
                
                // Vintage Radio (Right side of tabletop)
                VintageRadioView {
                    withAnimation(.spring()) {
                        showSpotifyPopup.toggle()
                    }
                }
                .padding(.trailing, 40)
            }
            .padding(.bottom, -2) // Flush onto tabletop surface
            
            // MARK: - Wooden Tabletop Surface
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(deskColor)
                    .frame(width: 680, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 3)
                
                // Wood grain highlight line
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 2)
                    .padding(.horizontal, 10)
            }
            
            // MARK: - Desk Front Body with Drawers & Kneehole
            HStack(spacing: 0) {
                // Left drawer stack
                VStack(spacing: 5) {
                    DrawerBox(color: drawerColor)
                    DrawerBox(color: drawerColor)
                }
                .frame(width: 140)
                .padding(6)
                
                // Center Kneehole opening (Floor visible underneath)
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                
                // Right drawer stack
                VStack(spacing: 5) {
                    DrawerBox(color: drawerColor)
                    DrawerBox(color: drawerColor)
                }
                .frame(width: 140)
                .padding(6)
            }
            .frame(width: 660, height: 95)
            .background(deskColor.opacity(0.92))
        }
        .frame(width: 680)
    }
    
    private var deskColor: Color {
        Color(red: 0.36, green: 0.22, blue: 0.13)
    }
    
    private var drawerColor: Color {
        deskColor.opacity(0.85)
    }
    
    private func openMailApp() {
        if let mailURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.mail") {
            NSWorkspace.shared.openApplication(at: mailURL, configuration: NSWorkspace.OpenConfiguration())
        } else if let url = URL(string: "mailto:") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Desk Lamp (Interactive On/Off)
struct DeskLampView: View {
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // Light beam cone when turned on
                if isOn {
                    Path { path in
                        path.move(to: CGPoint(x: 24, y: 15))
                        path.addLine(to: CGPoint(x: -28, y: 75))
                        path.addLine(to: CGPoint(x: 76, y: 75))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.5), Color.yellow.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                VStack(spacing: 0) {
                    // Banker's green glass lampshade
                    ZStack {
                        Capsule()
                            .fill(isOn ? Color(red: 0.18, green: 0.70, blue: 0.38) : Color(red: 0.12, green: 0.35, blue: 0.22))
                            .frame(width: 48, height: 18)
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.88, green: 0.76, blue: 0.35), lineWidth: 1.5)
                            )
                        
                        if isOn {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 10, height: 10)
                                .blur(radius: 2)
                        }
                    }
                    
                    // Brass curved stem
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.72, blue: 0.32))
                        .frame(width: 3.5, height: 38)
                    
                    // Brass weighted base
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.75, green: 0.62, blue: 0.25))
                        .frame(width: 34, height: 7)
                }
            }
        }
        .buttonStyle(.plain)
        .help("Lampu Meja: Klik untuk mode malam / siang")
    }
}

// MARK: - Animated Floating Music Notes
struct FloatingNotesView: View {
    var body: some View {
        HStack(spacing: 5) {
            Text("♪")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(SANSColors.lime)
                .offset(y: -10)
            
            Text("♫")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.yellow)
                .offset(y: -17)
            
            Text("♩")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(SANSColors.pink)
                .offset(y: -12)
        }
        .shadow(color: Color.yellow.opacity(0.8), radius: 3)
    }
}

// MARK: - Vintage Radio (Spotify Opener & Player)
public struct VintageRadioView: View {
    @ObservedObject var spotify = SpotifyService.shared
    @ObservedObject var appState = AppState.shared
    let action: () -> Void
    
    public init(action: @escaping () -> Void = {}) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            spotify.playPause()
        }) {
            ZStack(alignment: .topTrailing) {
                let imgName = spotify.isPlaying ? "radio-on" : "radio"
                if let radioImg = AssetLoader.image(named: imgName) {
                    Image(nsImage: radioImg)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 74, height: 44)
                        .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
                } else {
                    proceduralRadio
                }
                
                if spotify.isPlaying {
                    FloatingNotesView()
                        .offset(x: -6, y: -22)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Buka Pemutar Mini") {
                withAnimation(.spring()) {
                    appState.showSpotifyPopup.toggle()
                }
            }
            Button("Buka Aplikasi Spotify") {
                spotify.openSpotify()
            }
            Divider()
            Button(spotify.isPlaying ? "Jeda (Pause)" : "Putar (Play)") {
                spotify.playPause()
            }
            Button("Lagu Berikutnya") {
                spotify.nextTrack()
            }
            Button("Lagu Sebelumnya") {
                spotify.previousTrack()
            }
        }
        .help(spotify.isPlaying ? "Radio: \(spotify.trackTitle) - \(spotify.artistName)" : "Radio Spotify: Klik untuk memutar lagu")
    }
    
    private var proceduralRadio: some View {
        ZStack {
            // Wooden Radio Box
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.52, green: 0.34, blue: 0.22))
                .frame(width: 68, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(red: 0.35, green: 0.22, blue: 0.12), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
            
            // Antenna
            VStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1.5, height: 22)
                    .rotationEffect(.degrees(20))
                    .offset(x: 18, y: -20)
                Spacer()
            }
            
            HStack(spacing: 6) {
                // Speaker Grille lines
                VStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(0.55))
                            .frame(width: 26, height: 2)
                    }
                }
                
                // Dial & Knobs
                VStack(spacing: 5) {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.85, blue: 0.55))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle().stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    
                    HStack(spacing: 3) {
                        Circle().fill(Color.black).frame(width: 5, height: 5)
                        Circle().fill(Color.black).frame(width: 5, height: 5)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Envelope Letter (Mail Opener)
struct LetterEnvelopeView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Envelope Body
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.88))
                    .frame(width: 44, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                
                // Flap fold lines
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 22, y: 14))
                    path.addLine(to: CGPoint(x: 44, y: 0))
                }
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                
                // Red Wax Seal Stamp
                Circle()
                    .fill(Color(red: 0.82, green: 0.20, blue: 0.22))
                    .frame(width: 8, height: 8)
                    .offset(y: 1)
            }
            .rotationEffect(.degrees(-6))
        }
        .buttonStyle(.plain)
        .help("Surat: Klik untuk membuka aplikasi Mail macOS")
    }
}

// MARK: - Desk Drawer Component
struct DrawerBox: View {
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.25), lineWidth: 1)
            )
            .overlay(
                // Gold drawer pull handle
                Capsule()
                    .fill(Color(red: 0.90, green: 0.78, blue: 0.35))
                    .frame(width: 24, height: 5)
                    .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
            )
            .frame(height: 38)
    }
}

// MARK: - Standing Desk Fan (Kos-Kosan)
public struct StandingFanView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            // Fan Cage
            Circle()
                .stroke(Color(red: 0.35, green: 0.60, blue: 0.75), lineWidth: 3)
                .background(Circle().fill(Color.white.opacity(0.85)))
                .frame(width: 58, height: 58)
                .overlay(
                    // Fan blades
                    ZStack {
                        ForEach(0..<3) { i in
                            Capsule()
                                .fill(Color(red: 0.20, green: 0.50, blue: 0.70).opacity(0.7))
                                .frame(width: 10, height: 26)
                                .offset(y: -10)
                                .rotationEffect(.degrees(Double(i) * 120))
                        }
                        Circle().fill(Color.white).frame(width: 10, height: 10)
                    }
                )
            
            // Stand Pole
            Rectangle()
                .fill(Color.gray)
                .frame(width: 4, height: 80)
            
            // Base Stand
            Circle()
                .fill(Color(red: 0.35, green: 0.60, blue: 0.75))
                .frame(width: 40, height: 12)
        }
    }
}

// MARK: - Water Dispenser with Blue Gallon (Kos-Kosan)
public struct WaterDispenserView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            // Upside-down blue gallon bottle
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.20, green: 0.55, blue: 0.88).opacity(0.8))
                    .frame(width: 42, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                // Water level ripple
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 6, height: 35)
                    .offset(x: -12)
            }
            
            // Dispenser base unit
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.92, green: 0.94, blue: 0.96))
                .frame(width: 48, height: 65)
                .overlay(
                    VStack(spacing: 4) {
                        Spacer()
                        // Hot & Cold taps
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.red).frame(width: 8, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.blue).frame(width: 8, height: 12)
                        }
                        Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 26, height: 4)
                        Spacer()
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
        }
    }
}
