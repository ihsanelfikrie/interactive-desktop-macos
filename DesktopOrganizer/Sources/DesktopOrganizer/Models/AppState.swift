import SwiftUI

public final class AppState: ObservableObject {
    public static let shared = AppState()
    
    @Published public var currentTheme: RoomTheme = .library
    @Published public var isNightMode: Bool = false
    @Published public var showSpotifyPopup: Bool = false
    @Published public var showThemePicker: Bool = false
    @Published public var showHelpModal: Bool = false
    @Published public var showBookshelfDrawer: Bool = false
    @Published public var isCarpetLifted: Bool = false
    
    // Custom Layout Edit Mode
    @Published public var isEditLayoutMode: Bool = false
    
    // Drop & Hover states
    @Published public var isBookshelfTargeted: Bool = false
    @Published public var isCarpetTargeted: Bool = false
    @Published public var isTrashTargeted: Bool = false
    @Published public var targetedPhotoSlot: Int? = nil
    @Published public var hoveredPhotoSlot: Int? = nil
    
    // Sticky Notes state
    @Published public var addingTaskForNoteId: UUID? = nil
    @Published public var newTaskText: String = ""
    
    // Live date/time for Clock & Calendar
    @Published public var currentDate: Date = Date()
    
    private var timer: Timer?
    
    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
}
