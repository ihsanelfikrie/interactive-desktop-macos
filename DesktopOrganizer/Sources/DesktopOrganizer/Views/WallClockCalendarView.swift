import SwiftUI
import AppKit

public struct WallClockCalendarView: View {
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

// MARK: - Modern Architectural Wall Clock
public struct AnalogWallClockView: View {
    @ObservedObject var appState = AppState.shared
    private let overrideDate: Date?
    
    public init(currentDate: Date? = nil) {
        self.overrideDate = currentDate
    }
    
    public var body: some View {
        let shouldThrottle = !appState.isWindowVisible || !appState.isAppActive || appState.isLowPower
        let updateInterval: TimeInterval = shouldThrottle ? 60.0 : 1.0
        TimelineView(.periodic(from: .now, by: updateInterval)) { timeline in
            let date = overrideDate ?? timeline.date
            let calendar = Calendar.current
            let hour = CGFloat(calendar.component(.hour, from: date) % 12)
            let minute = CGFloat(calendar.component(.minute, from: date))
            let second = CGFloat(calendar.component(.second, from: date))
            
            GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height)
                    let radius = size / 2
                    
                    ZStack {
                        // 1. Natural Ambient Wall Drop Shadow
                        Circle()
                            .fill(Color.black.opacity(0.35))
                            .frame(width: size * 0.96, height: size * 0.96)
                            .offset(x: 2, y: 5)
                            .blur(radius: 5)
                        
                        // 2. Outer Bezel Ring (Sleek Space Grey / Brushed Anodized Metal)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.88, green: 0.90, blue: 0.92),
                                        Color(red: 0.62, green: 0.65, blue: 0.68),
                                        Color(red: 0.38, green: 0.40, blue: 0.44),
                                        Color(red: 0.75, green: 0.77, blue: 0.80)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: size, height: size)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                            )
                        
                        // 3. Inner Dark Stepped Chapter Wall (recessed bezel)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.16, green: 0.18, blue: 0.20),
                                        Color(red: 0.28, green: 0.30, blue: 0.32)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: size * 0.92, height: size * 0.92)
                            .shadow(color: Color.black.opacity(0.30), radius: 2, x: 0, y: 1)
                        
                        // 4. Studio Porcelain White Dial Face with subtle radial depth
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.99, green: 0.99, blue: 1.0),
                                        Color(red: 0.96, green: 0.96, blue: 0.98),
                                        Color(red: 0.92, green: 0.93, blue: 0.95)
                                    ],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: radius * 0.88
                                )
                            )
                            .frame(width: size * 0.88, height: size * 0.88)
                        
                        // 5. Delicate Outer Minute Track (60 micro marks)
                        ForEach(0..<60, id: \.self) { m in
                            if m % 5 != 0 {
                                Circle()
                                    .fill(Color(red: 0.20, green: 0.20, blue: 0.22).opacity(0.35))
                                    .frame(width: 1.2, height: 1.2)
                                    .offset(y: -(radius * 0.74))
                                    .rotationEffect(.degrees(Double(m) * 6.0))
                            }
                        }
                        
                        // 6. Modern Baton Hour Indices (12 hours)
                        ForEach(0..<12, id: \.self) { i in
                            let isCardinal = (i % 3 == 0) // 12, 3, 6, 9
                            Capsule()
                                .fill(Color(red: 0.12, green: 0.12, blue: 0.14))
                                .frame(width: isCardinal ? 3.0 : 1.6, height: isCardinal ? 9.5 : 6.5)
                                .offset(y: -(radius * 0.74) + (isCardinal ? 4.75 : 3.25))
                                .rotationEffect(.degrees(Double(i) * 30.0))
                        }
                        
                        // 7. Subtle Curved Glass Specular Highlight (Lens reflection)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.white.opacity(0.04),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                            .frame(width: size * 0.88, height: size * 0.88)
                            .allowsHitTesting(false)
                        
                        // 8. Clock Hands (Architectural Charcoal & Bauhaus Vermilion Needle)
                        
                        // Hour Hand (Matte dark graphite baton)
                        ModernClockHand(
                            length: radius * 0.48,
                            width: 3.4,
                            color: Color(red: 0.14, green: 0.14, blue: 0.16),
                            angle: Double((hour + minute / 60.0 + second / 3600.0) * 30.0),
                            tail: radius * 0.10
                        )
                        
                        // Minute Hand (Slender dark graphite baton)
                        ModernClockHand(
                            length: radius * 0.72,
                            width: 2.2,
                            color: Color(red: 0.14, green: 0.14, blue: 0.16),
                            angle: Double((minute + second / 60.0) * 6.0),
                            tail: radius * 0.12
                        )
                        
                        // Second Hand (Bauhaus Electric Orange-Red Needle with circular counterweight)
                        if appState.isWindowVisible {
                            ModernClockHand(
                                length: radius * 0.80,
                                width: 1.2,
                                color: Color(red: 0.98, green: 0.26, blue: 0.18),
                                angle: Double(second * 6.0),
                                tail: radius * 0.20,
                                hasCounterRing: true
                            )
                        }
                        
                        // 9. Precision Central Hub (Concentric metallic cap + center red jewel)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.35), Color(white: 0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 7, height: 7)
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.6))
                            .shadow(color: Color.black.opacity(0.3), radius: 1, y: 1)
                        
                        Circle()
                            .fill(Color(red: 0.98, green: 0.26, blue: 0.18))
                            .frame(width: 2.6, height: 2.6)
                    }
                    .frame(width: size, height: size)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .contentShape(Circle())
            .onTapGesture(count: 2) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.clock") {
                    NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                }
            }
            .onTapGesture {
                appState.toggleQuickView(.clock)
            }
            .contextMenu {
                Button("Buka Jam Sistem (Clock)") {
                    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.clock") {
                        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                    }
                }
            }
            .help("Jam Dinding: Klik untuk melihat detail, klik 2x untuk buka aplikasi Jam")
    }
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        return f
    }()
}

// MARK: - Modern Clock Hand with optional Bauhaus Counterweight Ring
struct ModernClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color
    let angle: Double
    let tail: CGFloat
    var hasCounterRing: Bool = false
    
    var body: some View {
        ZStack {
            // Main hand body
            Capsule()
                .fill(color)
                .frame(width: width, height: length)
                .offset(y: -length / 2)
            
            // Counter-balance tail extending behind pivot
            if tail > 0 {
                Capsule()
                    .fill(color)
                    .frame(width: width, height: tail)
                    .offset(y: tail / 2)
                
                if hasCounterRing {
                    Circle()
                        .stroke(color, lineWidth: width * 1.1)
                        .frame(width: 6.0, height: 6.0)
                        .offset(y: tail * 0.65)
                }
            }
        }
        .rotationEffect(.degrees(angle))
        .shadow(color: Color.black.opacity(0.25), radius: 1.5, x: 0.8, y: 1.2)
    }
}

// MARK: - Modern Architectural Wall Calendar (Pairs with Modern Wall Clock)
public struct WallCalendarView: View {
    @ObservedObject var appState = AppState.shared
    private let overrideDate: Date?
    
    public init(currentDate: Date? = nil) {
        self.overrideDate = currentDate
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 60.0)) { timeline in
            let date = overrideDate ?? timeline.date
            
            ZStack(alignment: .top) {
                // 1. Natural ambient drop shadow onto wall
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.black.opacity(0.30))
                    .offset(x: 1, y: 5)
                    .blur(radius: 5)
                
                // 2. Realistic Stacked Under-Paper Layers (Physical pad depth)
                RoundedRectangle(cornerRadius: 6.5)
                    .fill(Color(red: 0.88, green: 0.89, blue: 0.92))
                    .offset(y: 3)
                    .scaleEffect(x: 0.97, y: 1.0, anchor: .bottom)
                
                RoundedRectangle(cornerRadius: 6.5)
                    .fill(Color(red: 0.93, green: 0.94, blue: 0.96))
                    .offset(y: 1.5)
                    .scaleEffect(x: 0.985, y: 1.0, anchor: .bottom)
                
                // 3. Top Active Calendar Sheet
                VStack(spacing: 0) {
                    // Precision Brushed Aluminum Mounting Rail (Matching Wall Clock Bezel)
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color(red: 0.36, green: 0.38, blue: 0.42),
                                Color(red: 0.22, green: 0.24, blue: 0.27),
                                Color(red: 0.16, green: 0.18, blue: 0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Metallic top edge bevel highlight
                        VStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.40))
                                .frame(height: 1)
                            Spacer()
                        }
                        
                        // Twin Precision Brass Mounting Rivets
                        HStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(red: 0.96, green: 0.86, blue: 0.56), Color(red: 0.65, green: 0.50, blue: 0.25)],
                                        center: .center, startRadius: 0.5, endRadius: 2.5
                                    )
                                )
                                .frame(width: 4.5, height: 4.5)
                                .overlay(Circle().stroke(Color.black.opacity(0.35), lineWidth: 0.5))
                                .shadow(color: .black.opacity(0.35), radius: 1, y: 0.5)
                                .padding(.leading, 10)
                            
                            Spacer()
                            
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(red: 0.96, green: 0.86, blue: 0.56), Color(red: 0.65, green: 0.50, blue: 0.25)],
                                        center: .center, startRadius: 0.5, endRadius: 2.5
                                    )
                                )
                                .frame(width: 4.5, height: 4.5)
                                .overlay(Circle().stroke(Color.black.opacity(0.35), lineWidth: 0.5))
                                .shadow(color: .black.opacity(0.35), radius: 1, y: 0.5)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(height: 13)
                    
                    // Micro Perforated Tear Line
                    Rectangle()
                        .fill(Color(white: 0.12))
                        .frame(height: 1)
                    
                    // Month Accent Ribbon (Refined Bauhaus Vermilion Red matching Clock second hand)
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color(red: 0.90, green: 0.25, blue: 0.19),
                                Color(red: 0.78, green: 0.20, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        HStack(spacing: 3) {
                            Text(monthString(for: date))
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(1.2)
                            
                            Text(yearString(for: date))
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.75))
                        }
                    }
                    .frame(height: 20)
                    
                    // Porcelain White Date Pad
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color(red: 0.99, green: 0.99, blue: 1.0),
                                Color(red: 0.96, green: 0.96, blue: 0.98),
                                Color(red: 0.92, green: 0.93, blue: 0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        VStack(spacing: 0) {
                            Spacer(minLength: 1)
                            
                            // Day Number (Architectural typography)
                            Text(dayString(for: date))
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 0.12, green: 0.13, blue: 0.15))
                                .tracking(-0.5)
                            
                            // Accent divider capsule
                            Capsule()
                                .fill(Color(red: 0.88, green: 0.26, blue: 0.20).opacity(0.85))
                                .frame(width: 16, height: 2)
                                .padding(.vertical, 2)
                            
                            // Weekday Name
                            Text(weekdayString(for: date))
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                                .tracking(0.5)
                            
                            Spacer(minLength: 4)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                )
            }
        }
        .contentShape(Rectangle())
        .onHover { appState.isHoveringWallCalendar = $0 }
        .onTapGesture(count: 2) {
            if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
            } else if let url = URL(string: "calshow:") {
                NSWorkspace.shared.open(url)
            }
        }
        .onTapGesture {
            AppState.shared.toggleQuickView(.calendar)
        }
        .contextMenu {
            Button("Buka Kalender macOS (Calendar)") {
                if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                    NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
                } else if let url = URL(string: "calshow:") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .help("Kalender: Klik untuk melihat detail, klik 2x untuk buka aplikasi Kalender")
    }
    
    private func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date).uppercased()
    }
    
    private func yearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
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
