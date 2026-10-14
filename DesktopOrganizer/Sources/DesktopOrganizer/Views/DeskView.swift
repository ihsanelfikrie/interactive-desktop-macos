import SwiftUI
import AppKit

public struct DeskView: View {
    @ObservedObject var appState = AppState.shared
    let theme: RoomTheme
    @Binding var isNightMode: Bool
    @Binding var showSpotifyPopup: Bool
    
    public init(theme: RoomTheme, isNightMode: Binding<Bool>, showSpotifyPopup: Binding<Bool>) {
        self.theme = theme
        self._isNightMode = isNightMode
        self._showSpotifyPopup = showSpotifyPopup
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Wall Decor (Clock & Calendar)
            VStack {
                HStack(spacing: 28) {
                    // Wall Clock
                    AnalogWallClockView(currentDate: appState.currentDate)
                    
                    // Wall Calendar
                    WallCalendarView(currentDate: appState.currentDate)
                }
                .offset(y: -230)
                
                Spacer()
            }
            
            // MARK: - Indonesian Kos-Kosan Special Props (Galon & Kipas)
            if theme == .kosKosan {
                HStack {
                    // Standing Desk Fan
                    StandingFanView()
                        .offset(x: -80, y: -20)
                    
                    Spacer()
                    
                    // Water Dispenser with Blue Gallon
                    WaterDispenserView()
                        .offset(x: 70, y: -20)
                }
                .frame(width: 820)
            }
            
            // MARK: - Desk Furniture Structure
            VStack(spacing: 0) {
                // Table Accessories (resting on the desktop)
                HStack(alignment: .bottom, spacing: 32) {
                    // Banker's Desk Lamp (Clickable -> Dark Mode Easter Egg)
                    DeskLampView(isOn: !isNightMode) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isNightMode.toggle()
                        }
                    }
                    .padding(.leading, 40)
                    
                    Spacer()
                    
                    // Envelope / Letter (Clickable -> Opens Mail App)
                    LetterEnvelopeView {
                        openMailApp()
                    }
                    
                    // Vintage Radio (Clickable -> Opens Spotify Popup)
                    VintageRadioView {
                        withAnimation(.spring()) {
                            showSpotifyPopup.toggle()
                        }
                    }
                    .padding(.trailing, 45)
                }
                .padding(.bottom, -6)
                
                // Desktop Surface Plank
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(deskColor)
                        .frame(height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    
                    // Wood grain highlight line
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 2)
                        .padding(.horizontal, 8)
                }
                
                // Desk Front Body with Drawers
                HStack(spacing: 0) {
                    // Left drawer stack
                    VStack(spacing: 6) {
                        DrawerBox(color: drawerColor)
                        DrawerBox(color: drawerColor)
                    }
                    .frame(width: 140)
                    .padding(8)
                    
                    // Center Kneehole opening
                    Rectangle()
                        .fill(Color.black.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    
                    // Right drawer stack
                    VStack(spacing: 6) {
                        DrawerBox(color: drawerColor)
                        DrawerBox(color: drawerColor)
                    }
                    .frame(width: 140)
                    .padding(8)
                }
                .frame(height: 95)
                .background(deskColor.opacity(0.92))
            }
            .frame(width: 680)
        }
    }
    
    private var deskColor: Color {
        switch theme {
        case .library: return Color(red: 0.36, green: 0.22, blue: 0.13)
        case .kosKosan: return Color(red: 0.82, green: 0.72, blue: 0.58)
        case .taman: return Color(red: 0.42, green: 0.28, blue: 0.16)
        }
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

// MARK: - Analog Wall Clock with live hands
struct AnalogWallClockView: View {
    let currentDate: Date
    
    var body: some View {
        let calendar = Calendar.current
        let hour = CGFloat(calendar.component(.hour, from: currentDate) % 12)
        let minute = CGFloat(calendar.component(.minute, from: currentDate))
        let second = CGFloat(calendar.component(.second, from: currentDate))
        
        ZStack {
            // Outer casing
            Circle()
                .fill(Color(red: 0.25, green: 0.28, blue: 0.32))
                .frame(width: 64, height: 64)
                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
            
            // White clock face
            Circle()
                .fill(Color.white)
                .frame(width: 54, height: 54)
            
            // Hour markers
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 1.5, height: i % 3 == 0 ? 5 : 3)
                    .offset(y: -22)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            
            // Hour hand
            Rectangle()
                .fill(Color.black)
                .frame(width: 2.5, height: 14)
                .offset(y: -7)
                .rotationEffect(.degrees(Double((hour + minute / 60.0) * 30)))
            
            // Minute hand
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .frame(width: 2, height: 20)
                .offset(y: -10)
                .rotationEffect(.degrees(Double((minute + second / 60.0) * 6)))
            
            // Second hand
            Rectangle()
                .fill(Color.red)
                .frame(width: 1, height: 22)
                .offset(y: -11)
                .rotationEffect(.degrees(Double(second * 6)))
            
            // Center pin
            Circle()
                .fill(Color.red)
                .frame(width: 4, height: 4)
        }
        .help("Jam Dinding Sistem")
    }
}

// MARK: - Wall Calendar with live Date
struct WallCalendarView: View {
    let currentDate: Date
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: currentDate).uppercased()
    }
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: currentDate)
    }
    
    var body: some View {
        Button(action: {
            if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
            } else if let url = URL(string: "calshow:") {
                NSWorkspace.shared.open(url)
            }
        }) {
            ZStack {
                // Outer Calendar card
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .frame(width: 68, height: 74)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                
                VStack(spacing: 0) {
                    // Red calendar top header
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.88, green: 0.22, blue: 0.25))
                            .frame(height: 22)
                        
                        Text(monthString)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    
                    Spacer()
                    
                    // Day number
                    Text(dayString)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Spacer()
                }
                .frame(width: 68, height: 74)
            }
        }
        .buttonStyle(.plain)
        .help("Klik untuk membuka Kalender macOS")
    }
}

// MARK: - Desk Lamp (Interactive On/Off)
struct DeskLampView: View {
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // Light beam cone when on
                if isOn {
                    Path { path in
                        path.move(to: CGPoint(x: 24, y: 18))
                        path.addLine(to: CGPoint(x: -25, y: 80))
                        path.addLine(to: CGPoint(x: 75, y: 80))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.45), Color.yellow.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                VStack(spacing: 0) {
                    // Banker's green glass lampshade
                    ZStack {
                        Capsule()
                            .fill(isOn ? Color(red: 0.18, green: 0.65, blue: 0.38) : Color(red: 0.12, green: 0.35, blue: 0.22))
                            .frame(width: 48, height: 18)
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.85, green: 0.72, blue: 0.32), lineWidth: 1.5)
                            )
                        
                        if isOn {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 10, height: 10)
                                .blur(radius: 2)
                        }
                    }
                    
                    // Brass curved stem
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.72, blue: 0.32))
                        .frame(width: 3.5, height: 42)
                    
                    // Brass weighted base
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.75, green: 0.62, blue: 0.25))
                        .frame(width: 34, height: 8)
                }
            }
        }
        .buttonStyle(.plain)
        .help(isOn ? "Klik untuk mematikan lampu (Mode Malam)" : "Klik untuk menyalakan lampu (Mode Terang)")
    }
}

// MARK: - Vintage Radio (Spotify Opener)
struct VintageRadioView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                        .frame(width: 1.5, height: 24)
                        .rotationEffect(.degrees(20))
                        .offset(x: 18, y: -22)
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
        .buttonStyle(.plain)
        .help("Klik untuk membuka Kontrol Spotify")
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
            .rotationEffect(.degrees(-8))
        }
        .buttonStyle(.plain)
        .help("Klik untuk membuka Aplikasi Mail macOS")
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
struct StandingFanView: View {
    var body: some View {
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
struct WaterDispenserView: View {
    var body: some View {
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
