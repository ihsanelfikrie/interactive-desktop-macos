import SwiftUI

public enum RoomTheme: String, CaseIterable, Identifiable, Codable {
    case library = "library"
    case kosKosan = "kosKosan"
    case taman = "taman"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .library: return "Perpustakaan Klasik (Library)"
        case .kosKosan: return "Kamar Kos-Kosan Estetik"
        case .taman: return "Taman Santai (Outdoor)"
        }
    }
    
    public var iconName: String {
        switch self {
        case .library: return "books.vertical.fill"
        case .kosKosan: return "fan.desk.fill"
        case .taman: return "leaf.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .library:
            return "Suasana ruang belajar klasik dengan dinding bergaris hijau botol, rak kayu jati, dan karpet mewah."
        case .kosKosan:
            return "Khas kamar kos Indonesia dengan dispenser galon, kasur lantai, kipas angin, dan dinding mint ceria."
        case .taman:
            return "Udara segar luar ruangan dengan hamparan rumput hijau, langit biru, dan bangku kayu santai."
        }
    }
    
    // Wall Background Colors
    public var wallColorPrimary: Color {
        switch self {
        case .library: return Color(red: 0.16, green: 0.32, blue: 0.30)
        case .kosKosan: return Color(red: 0.78, green: 0.90, blue: 0.88)
        case .taman: return Color(red: 0.65, green: 0.84, blue: 0.95)
        }
    }
    
    public var wallColorSecondary: Color {
        switch self {
        case .library: return Color(red: 0.12, green: 0.25, blue: 0.23)
        case .kosKosan: return Color(red: 0.72, green: 0.86, blue: 0.84)
        case .taman: return Color(red: 0.55, green: 0.78, blue: 0.92)
        }
    }
    
    // Floor Colors
    public var floorColor: Color {
        switch self {
        case .library: return Color(red: 0.24, green: 0.15, blue: 0.10)
        case .kosKosan: return Color(red: 0.92, green: 0.93, blue: 0.94)
        case .taman: return Color(red: 0.30, green: 0.58, blue: 0.25)
        }
    }
    
    // Furniture / Wood Accent
    public var woodColor: Color {
        switch self {
        case .library: return Color(red: 0.38, green: 0.23, blue: 0.14)
        case .kosKosan: return Color(red: 0.85, green: 0.74, blue: 0.60)
        case .taman: return Color(red: 0.45, green: 0.30, blue: 0.18)
        }
    }
    
    // Rug / Carpet Base Color
    public var carpetColor: Color {
        switch self {
        case .library: return Color(red: 0.52, green: 0.12, blue: 0.18)
        case .kosKosan: return Color(red: 0.18, green: 0.42, blue: 0.68)
        case .taman: return Color(red: 0.88, green: 0.28, blue: 0.28)
        }
    }
}
