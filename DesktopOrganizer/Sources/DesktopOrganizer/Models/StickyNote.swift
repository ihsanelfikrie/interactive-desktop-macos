import SwiftUI

public enum NoteColor: String, CaseIterable, Codable {
    case lime
    case pink
    case white
    case blue
    case surface
    
    public var background: Color {
        switch self {
        case .lime:    return SANSColors.lime
        case .pink:    return SANSColors.pink
        case .white:   return SANSColors.cleanWhite
        case .blue:    return SANSColors.primaryBlue
        case .surface: return SANSColors.surface
        }
    }
    
    public var headerColor: Color {
        switch self {
        case .lime:    return Color(red: 210/255.0, green: 235/255.0, blue: 80/255.0)
        case .pink:    return Color(red: 225/255.0, green: 5/255.0, blue: 200/255.0)
        case .white:   return SANSColors.border
        case .blue:    return Color(red: 14/255.0, green: 9/255.0, blue: 175/255.0)
        case .surface: return Color(red: 235/255.0, green: 235/255.0, blue: 235/255.0)
        }
    }
    
    public var textColor: Color {
        switch self {
        case .lime, .white, .surface:
            return SANSColors.dark
        case .pink, .blue:
            return SANSColors.cleanWhite
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw.lowercased() {
        case "pink", "purple":
            self = .pink
        case "blue":
            self = .blue
        case "white":
            self = .white
        case "surface", "gray":
            self = .surface
        default:
            self = .lime
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
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
    public var id: UUID = UUID()
    public var title: String
    public var tasks: [TaskItem]
    public var color: NoteColor
    public var x: CGFloat
    public var y: CGFloat
    public var rotation: Double
    
    public init(
        id: UUID = UUID(),
        title: String = "Catatan",
        tasks: [TaskItem] = [],
        color: NoteColor = .lime,
        x: CGFloat = 40,
        y: CGFloat = 40,
        rotation: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.tasks = tasks
        self.color = color
        self.x = x
        self.y = y
        self.rotation = rotation
    }
}
