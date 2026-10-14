import SwiftUI
import AppKit

public struct WallClockCalendarView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Live Analog Wall Clock
            AnalogWallClockView()
            
            // Live Wall Calendar (Click to open Calendar.app)
            WallCalendarView()
        }
    }
}

// MARK: - Live Analog Wall Clock
public struct AnalogWallClockView: View {
    private let overrideDate: Date?
    
    public init(currentDate: Date? = nil) {
        self.overrideDate = currentDate
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let date = overrideDate ?? timeline.date
            let calendar = Calendar.current
            let hour = CGFloat(calendar.component(.hour, from: date) % 12)
            let minute = CGFloat(calendar.component(.minute, from: date))
            let second = CGFloat(calendar.component(.second, from: date))
            
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
                    
                    // Hour hand (Short & broad, Dark Charcoal)
                    ClockHand(
                        length: 25,
                        width: 3.8,
                        color: Color(red: 0.15, green: 0.15, blue: 0.15),
                        angle: Double((hour + minute / 60.0 + second / 3600.0) * 30.0),
                        tail: 4
                    )
                    
                    // Minute hand (Long & slender, Dark Charcoal)
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
                        width: 1.4,
                        color: Color(red: 0.88, green: 0.18, blue: 0.20),
                        angle: Double(second * 6.0),
                        tail: 9
                    )
                    
                    // Center pin (Hub)
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
            .help("Jam Dinding: \(timeFormatter.string(from: date))")
        }
    }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .medium
        return f
    }
}

// MARK: - Mathematically exact Clock Hand with centered pivot
struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color
    let angle: Double
    let tail: CGFloat
    
    var body: some View {
        ZStack {
            // Main hand extending outward from center
            Capsule()
                .fill(color)
                .frame(width: width, height: length)
                .offset(y: -length / 2)
            
            // Counter-balance tail extending behind center
            if tail > 0 {
                Capsule()
                    .fill(color)
                    .frame(width: width, height: tail)
                    .offset(y: tail / 2)
            }
        }
        .rotationEffect(.degrees(angle))
        .shadow(color: .black.opacity(0.18), radius: 1, x: 0.5, y: 1)
    }
}

// MARK: - Wall Tear-off Calendar (Desktop Organizer official parity)
public struct WallCalendarView: View {
    private let overrideDate: Date?
    
    public init(currentDate: Date? = nil) {
        self.overrideDate = currentDate
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 60.0)) { timeline in
            let date = overrideDate ?? timeline.date
            
            Button(action: {
                if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                    NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
                } else if let url = URL(string: "calshow:") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                ZStack {
                    // Card background & shape
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .overlay(
                            VStack(spacing: 0) {
                                // Red calendar top header (Month name)
                                ZStack {
                                    Color(red: 0.83, green: 0.26, blue: 0.21)
                                    
                                    Text(monthString(for: date))
                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .tracking(1.0)
                                }
                                .frame(height: 28)
                                
                                // White card body (Day number & Weekday)
                                VStack(spacing: 1) {
                                    Spacer(minLength: 2)
                                    
                                    Text(dayString(for: date))
                                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                                        .foregroundColor(Color(red: 0.18, green: 0.18, blue: 0.18))
                                    
                                    Text(weekdayString(for: date))
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0.48, green: 0.48, blue: 0.52))
                                    
                                    Spacer(minLength: 4)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.24), radius: 4, x: 0, y: 2)
                }
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button("Buka Kalender macOS (Calendar)") {
                    if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                        NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
                    } else if let url = URL(string: "calshow:") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            .help("Kalender: \(weekdayString(for: date)), \(dayString(for: date)) \(monthString(for: date))")
        }
    }
    
    private func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date).uppercased()
    }
    
    private func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func weekdayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE"
        let str = formatter.string(from: date)
        return str.prefix(1).capitalized + str.dropFirst()
    }
}
