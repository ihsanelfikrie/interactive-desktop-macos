import SwiftUI
import AppKit

// MARK: - Active Quick View Enum for Desktop Elements
public enum ActiveDesktopQuickView: Equatable {
    case clock
    case calendar
    case monitor
    case mail
    case whatsapp
    case trash
    case photo(slot: Int)
    case carpetItem(url: URL)
    case guitar
    case tegoerPlaque
    case sansPlaque
}

// MARK: - Dedicated High-Performance Floor & Carpet Interaction State (120 FPS Dragging)
public final class FloorInteractionState: ObservableObject {
    public static let shared = FloorInteractionState()
    
    @Published public var carpetDragOffset: CGSize = .zero
    @Published public var isCarpetDragging: Bool = false
    @Published public var isCarpetLifted: Bool = false
    @Published public var isFloorTargeted: Bool = false
    @Published public var isCarpetTargeted: Bool = false
    
    @Published public var draggingFloorFileName: String? = nil
    @Published public var floorFileDragTranslation: CGSize = .zero
    @Published public var hoveredFloorFileName: String? = nil
    
    public init() {}
}

public final class AppState: ObservableObject {
    public static let shared = AppState()
    
    @Published public var currentTheme: RoomTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "theme")
        }
    }
    
    @Published public var lampOn: Bool {
        didSet {
            UserDefaults.standard.set(lampOn, forKey: "lampOn")
        }
    }
    
    @Published public var ladderX: CGFloat {
        didSet {
            UserDefaults.standard.set(Double(ladderX), forKey: "ladderX")
        }
    }
    
    @Published public var isLowPower: Bool = false
    @Published public var showSpotifyPopup: Bool = false
    @Published public var showThemePicker: Bool = false
    @Published public var showHelpModal: Bool = false
    @Published public var showBookshelfDrawer: Bool = false
    @Published public var activeShelfPopoverURL: URL? = nil
    @Published public var activeShelfIndex: Int = 1
    @Published public var activeQuickView: ActiveDesktopQuickView? = nil
    @Published public var showRugPeek: Bool = false
    
    // MARK: - Floor & Carpet State (Forwarded to FloorInteractionState for isolated 120 FPS Dragging)
    public var isCarpetLifted: Bool {
        get { FloorInteractionState.shared.isCarpetLifted }
        set { FloorInteractionState.shared.isCarpetLifted = newValue }
    }
    public var carpetSlideOffset: CGFloat {
        get { 0 }
        set { }
    }
    public var isCarpetDragging: Bool {
        get { FloorInteractionState.shared.isCarpetDragging }
        set { FloorInteractionState.shared.isCarpetDragging = newValue }
    }
    public var carpetDragOffset: CGSize {
        get { FloorInteractionState.shared.carpetDragOffset }
        set { FloorInteractionState.shared.carpetDragOffset = newValue }
    }
    public var isFloorTargeted: Bool {
        get { FloorInteractionState.shared.isFloorTargeted }
        set { FloorInteractionState.shared.isFloorTargeted = newValue }
    }
    public var isCarpetTargeted: Bool {
        get { FloorInteractionState.shared.isCarpetTargeted }
        set { FloorInteractionState.shared.isCarpetTargeted = newValue }
    }
    
    public func toggleQuickView(_ view: ActiveDesktopQuickView) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            if activeQuickView == view {
                activeQuickView = nil
            } else {
                activeShelfPopoverURL = nil
                showSpotifyPopup = false
                showBookshelfDrawer = false
                showThemePicker = false
                activeQuickView = view
            }
        }
    }
    
    // Custom Layout Edit Mode
    @Published public var isEditLayoutMode: Bool = false
    
    // Drop & Hover states
    @Published public var isBookshelfTargeted: Bool = false
    @Published public var isTrashTargeted: Bool = false
    @Published public var targetedPhotoSlot: Int? = nil
    @Published public var hoveredPhotoSlot: Int? = nil
    @Published public var hoveredShelfURL: URL? = nil
    @Published public var hoveredFlyoutURL: URL? = nil
    
    // Sticky Notes state
    @Published public var addingTaskForNoteId: UUID? = nil
    @Published public var newTaskText: String = ""
    @Published public var draggingNoteId: UUID? = nil
    @Published public var noteDragTranslation: CGSize = .zero
    @Published public var activeNoteCustomizerId: UUID? = nil
    @Published public var windBreezeEnabled: Bool = true
    @Published public var lastManualWindGust: TimeInterval = 0
    
    // Photo drag state
    @Published public var draggingPhotoSlot: Int? = nil
    @Published public var photoDragTranslation: CGSize = .zero
    
    // Floor item drag state (Forwarded to FloorInteractionState for 120 FPS dragging)
    public var draggingFloorFileName: String? {
        get { FloorInteractionState.shared.draggingFloorFileName }
        set { FloorInteractionState.shared.draggingFloorFileName = newValue }
    }
    public var floorFileDragTranslation: CGSize {
        get { FloorInteractionState.shared.floorFileDragTranslation }
        set { FloorInteractionState.shared.floorFileDragTranslation = newValue }
    }
    public var hoveredFloorFileName: String? {
        get { FloorInteractionState.shared.hoveredFloorFileName }
        set { FloorInteractionState.shared.hoveredFloorFileName = newValue }
    }
    
    @Published public var isHoveringDeskMail: Bool = false
    @Published public var isHoveringWallCalendar: Bool = false
    @Published public var isHoveringGuitar: Bool = false
    @Published public var isHoveringTrash: Bool = false
    @Published public var hoveredPlaque: ActiveDesktopQuickView? = nil
    
    // Window Visibility for power conservation
    @Published public var isWindowVisible: Bool = true
    
    private var powerObserver: AnyObject?
    
    private init() {
        // Load theme
        let savedTheme = UserDefaults.standard.string(forKey: "theme") ?? RoomTheme.library.rawValue
        self.currentTheme = RoomTheme(rawValue: savedTheme) ?? .library
        
        // Load lamp
        if UserDefaults.standard.object(forKey: "lampOn") != nil {
            self.lampOn = UserDefaults.standard.bool(forKey: "lampOn")
        } else {
            self.lampOn = true
        }
        
        // Load ladderX
        let savedLadderX = UserDefaults.standard.double(forKey: "ladderX")
        self.ladderX = savedLadderX > 0 ? CGFloat(savedLadderX) : 40
        
        // Low power monitor
        self.isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        powerObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        
    }
}


