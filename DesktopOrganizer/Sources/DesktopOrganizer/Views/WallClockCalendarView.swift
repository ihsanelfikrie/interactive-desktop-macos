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
        
        ZStack {
            // Outer casing
            Circle()
                .fill(Color(red: 0.25, green: 0.28, blue: 0.32))
                .frame(width: 58, height: 58)
                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
            
            // White clock face
            Circle()
                .fill(Color.white)
                .frame(width: 48, height: 48)
            
            // Hour markers
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 1.5, height: i % 3 == 0 ? 4 : 2.5)
                    .offset(y: -19)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            
            // Hour hand
            Rectangle()
                .fill(Color.black)
                .frame(width: 2.2, height: 12)
                .offset(y: -6)
                .rotationEffect(.degrees(Double((hour + minute / 60.0) * 30)))
            
            // Minute hand
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .frame(width: 1.8, height: 17)
                .offset(y: -8.5)
                .rotationEffect(.degrees(Double((minute + second / 60.0) * 6)))
            
            // Second hand
            Rectangle()
                .fill(Color.red)
                .frame(width: 1, height: 19)
                .offset(y: -9.5)
                .rotationEffect(.degrees(Double(second * 6)))
            
            // Center pin
            Circle()
                .fill(Color.red)
                .frame(width: 3.5, height: 3.5)
        }
        .help("Jam Dinding Sistem")
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
