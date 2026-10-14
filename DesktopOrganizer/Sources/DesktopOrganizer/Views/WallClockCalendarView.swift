import SwiftUI
import AppKit

public struct WallClockCalendarView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Live Analog Wall Clock
            AnalogWallClockView(currentDate: appState.currentDate)
            
            // Live Wall Calendar (Click to open Calendar.app)
            WallCalendarView(currentDate: appState.currentDate)
        }
    }
}

public struct AnalogWallClockView: View {
    let currentDate: Date
    
    public init(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    public var body: some View {
        let calendar = Calendar.current
        let hour = CGFloat(calendar.component(.hour, from: currentDate) % 12)
        let minute = CGFloat(calendar.component(.minute, from: currentDate))
        let second = CGFloat(calendar.component(.second, from: currentDate))
        
        Button(action: {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.clock") {
                NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
            }
        }) {
            ZStack {
                // Invisible round hit area
                Circle()
                    .fill(Color.clear)
                    .contentShape(Circle())
                
                // Hour hand (Short & broad, Charcoal)
                ClockHand(
                    length: 25,
                    width: 3.8,
                    color: Color(red: 0.15, green: 0.15, blue: 0.15),
                    angle: Double((hour + minute / 60.0 + second / 3600.0) * 30.0),
                    tail: 4
                )
                
                // Minute hand (Long & slender, Charcoal)
                ClockHand(
                    length: 37,
                    width: 2.6,
                    color: Color(red: 0.15, green: 0.15, blue: 0.15),
                    angle: Double((minute + second / 60.0) * 6.0),
                    tail: 6
                )
                
                // Second hand (Slender red needle with counter-balance tail)
                ClockHand(
                    length: 44,
                    width: 1.3,
                    color: Color(red: 0.88, green: 0.18, blue: 0.20),
                    angle: Double(second * 6.0),
                    tail: 9
                )
                
                // Center pin
                Circle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .frame(width: 6, height: 6)
                
                Circle()
                    .fill(Color(red: 0.88, green: 0.18, blue: 0.20))
                    .frame(width: 2.5, height: 2.5)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Buka Jam Sistem (Clock)") {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.clock") {
                    NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                }
            }
        }
        .help("Jam Dinding: \(timeFormatter.string(from: currentDate))")
    }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .medium
        return f
    }
}

// MARK: - Mathematically exact Clock Hand with counter-balance tail
struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color
    let angle: Double
    let tail: CGFloat
    
    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length + tail)
            .offset(y: -(length - tail) / 2)
            .rotationEffect(.degrees(angle))
            .shadow(color: .black.opacity(0.18), radius: 1, x: 0.5, y: 1)
    }
}

public struct WallCalendarView: View {
    let currentDate: Date
    
    public init(currentDate: Date) {
        self.currentDate = currentDate
    }
    
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
    
    public var body: some View {
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
                    .frame(width: 62, height: 68)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                
                VStack(spacing: 0) {
                    // Red calendar top header
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.88, green: 0.22, blue: 0.25))
                            .frame(height: 20)
                        
                        Text(monthString)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    
                    Spacer()
                    
                    // Day number
                    Text(dayString)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Spacer()
                }
                .frame(width: 62, height: 68)
            }
        }
        .buttonStyle(.plain)
        .help("Kalender: Klik untuk membuka aplikasi Calendar macOS")
    }
}
