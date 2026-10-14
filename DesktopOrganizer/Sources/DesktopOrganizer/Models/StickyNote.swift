import SwiftUI

public enum NoteColor: String, CaseIterable, Codable {
    case yellow
    case pink
    case green
    case blue
    case purple
    
    public var background: Color {
        switch self {
        case .yellow: return Color(red: 1.0, green: 0.95, blue: 0.65)
        case .pink:   return Color(red: 1.0, green: 0.78, blue: 0.85)
        case .green:  return Color(red: 0.78, green: 0.95, blue: 0.80)
        case .blue:   return Color(red: 0.75, green: 0.90, blue: 1.0)
        case .purple: return Color(red: 0.90, green: 0.82, blue: 0.98)
        }
    }
    
    public var headerColor: Color {
        switch self {
        case .yellow: return Color(red: 0.95, green: 0.88, blue: 0.50)
        case .pink:   return Color(red: 0.95, green: 0.70, blue: 0.78)
        case .green:  return Color(red: 0.70, green: 0.88, blue: 0.72)
        case .blue:   return Color(red: 0.68, green: 0.82, blue: 0.95)
        case .purple: return Color(red: 0.82, green: 0.72, blue: 0.92)
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
        color: NoteColor = .yellow,
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
