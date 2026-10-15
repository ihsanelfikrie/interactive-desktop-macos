import SwiftUI

public enum NoteColor: String, CaseIterable, Codable {
    case lime
    case pink
    case yellow
    case mint
    case lavender
    case peach
    case blue
    case white
    case dark
    case surface
    
    public var displayName: String {
        switch self {
        case .lime:     return "Lime"
        case .pink:     return "Pink"
        case .yellow:   return "Kuning"
        case .mint:     return "Mint"
        case .lavender: return "Lavender"
        case .peach:    return "Peach"
        case .blue:     return "Biru"
        case .white:    return "Putih"
        case .dark:     return "Gelap"
        case .surface:  return "Abu"
        }
    }
    
    public var background: Color {
        switch self {
        case .lime:     return SANSColors.lime
        case .pink:     return SANSColors.pink
        case .yellow:   return Color(red: 255/255.0, green: 242/255.0, blue: 115/255.0)
        case .mint:     return Color(red: 173/255.0, green: 245/255.0, blue: 212/255.0)
        case .lavender: return Color(red: 220/255.0, green: 206/255.0, blue: 254/255.0)
        case .peach:    return Color(red: 255/255.0, green: 210/255.0, blue: 185/255.0)
        case .blue:     return SANSColors.primaryBlue
        case .white:    return Color.white
        case .dark:     return Color(red: 32/255.0, green: 35/255.0, blue: 45/255.0)
        case .surface:  return SANSColors.surface
        }
    }
    
    public var headerColor: Color {
        switch self {
        case .lime:     return Color(red: 210/255.0, green: 235/255.0, blue: 80/255.0)
        case .pink:     return Color(red: 225/255.0, green: 5/255.0, blue: 200/255.0)
        case .yellow:   return Color(red: 245/255.0, green: 225/255.0, blue: 85/255.0)
        case .mint:     return Color(red: 145/255.0, green: 230/255.0, blue: 195/255.0)
        case .lavender: return Color(red: 200/255.0, green: 185/255.0, blue: 245/255.0)
        case .peach:    return Color(red: 245/255.0, green: 195/255.0, blue: 170/255.0)
        case .blue:     return Color(red: 14/255.0, green: 9/255.0, blue: 175/255.0)
        case .white:    return SANSColors.border
        case .dark:     return Color(red: 22/255.0, green: 24/255.0, blue: 32/255.0)
        case .surface:  return Color(red: 235/255.0, green: 235/255.0, blue: 235/255.0)
        }
    }
    
    public var textColor: Color {
        switch self {
        case .pink, .blue, .dark:
            return SANSColors.cleanWhite
        default:
            return SANSColors.dark
        }
    }
    
    public var secondaryTextColor: Color {
        switch self {
        case .pink, .blue, .dark:
            return Color.white.opacity(0.65)
        default:
            return Color.black.opacity(0.55)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw.lowercased() {
        case "pink", "purple":  self = .pink
        case "yellow":          self = .yellow
        case "mint", "green":   self = .mint
        case "lavender":        self = .lavender
        case "peach", "orange": self = .peach
        case "blue":            self = .blue
        case "white":           self = .white
        case "dark", "black":   self = .dark
        case "surface", "gray": self = .surface
        default:                self = .lime
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

public enum PinStyle: String, CaseIterable, Codable {
    case pushpin   // Pin bundar 3D klasik
    case washiTape // Strip selotip transparan
    case star      // Pin bintang emas
    case heart     // Pin hati pink
    case clip      // Klip kertas metalik
    
    public var displayName: String {
        switch self {
        case .washiTape: return "Plester"
        case .pushpin:   return "Pin"
        case .star:      return "Bintang"
        case .heart:     return "Hati"
        case .clip:      return "Klip"
        }
    }
}

public enum PaperPattern: String, CaseIterable, Codable {
    case plain // Kertas polos bersih
    case lined // Garis buku tulis
    case dots  // Pola titik dot-grid
    
    public var displayName: String {
        switch self {
        case .plain: return "Polos"
        case .lined: return "Garis"
        case .dots:  return "Titik"
        }
    }
}

public enum NoteMode: String, CaseIterable, Codable {
    case checklist // Daftar to-do list dengan centang
    case freeform  // Catatan bebas / paragraf
    
    public var displayName: String {
        switch self {
        case .checklist: return "To-Do"
        case .freeform:  return "Teks Bebas"
        }
    }
}

public struct TaskItem: Identifiable, Codable, Equatable {
    public var id: UUID = UUID()
    public var text: String
    public var isCompleted: Bool = false
    
    public init(id: UUID = UUID(), text: String, isCompleted: Bool = false) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
    }
}

public struct StickyNote: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var tasks: [TaskItem]
    public var freeformText: String
    public var mode: NoteMode
    public var color: NoteColor
    public var pinStyle: PinStyle
    public var pattern: PaperPattern
    public var x: CGFloat
    public var y: CGFloat
    public var rotation: Double
    
    public init(
        id: UUID = UUID(),
        title: String = "Catatan",
        tasks: [TaskItem] = [],
        freeformText: String = "",
        mode: NoteMode = .freeform,
        color: NoteColor = .yellow,
        pinStyle: PinStyle = .washiTape,
        pattern: PaperPattern = .plain,
        x: CGFloat = 40,
        y: CGFloat = 40,
        rotation: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.tasks = tasks
        self.freeformText = freeformText
        self.mode = mode
        self.color = color
        self.pinStyle = pinStyle
        self.pattern = pattern
        self.x = x
        self.y = y
        self.rotation = rotation
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, tasks, freeformText, mode, color, pinStyle, pattern, x, y, rotation
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try c.decodeIfPresent(String.self, forKey: .title) ?? "Catatan"
        self.tasks = try c.decodeIfPresent([TaskItem].self, forKey: .tasks) ?? []
        self.freeformText = try c.decodeIfPresent(String.self, forKey: .freeformText) ?? ""
        self.mode = try c.decodeIfPresent(NoteMode.self, forKey: .mode) ?? .freeform
        self.color = try c.decodeIfPresent(NoteColor.self, forKey: .color) ?? .yellow
        self.pinStyle = try c.decodeIfPresent(PinStyle.self, forKey: .pinStyle) ?? .washiTape
        self.pattern = try c.decodeIfPresent(PaperPattern.self, forKey: .pattern) ?? .plain
        self.x = try c.decodeIfPresent(CGFloat.self, forKey: .x) ?? 40
        self.y = try c.decodeIfPresent(CGFloat.self, forKey: .y) ?? 40
        self.rotation = try c.decodeIfPresent(Double.self, forKey: .rotation) ?? 0.0
    }
}
