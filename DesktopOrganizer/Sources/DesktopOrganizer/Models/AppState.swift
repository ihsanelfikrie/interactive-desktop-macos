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
    @Published public var isCarpetLifted: Bool = false
    @Published public var carpetSlideOffset: CGFloat = 0
    @Published public var isCarpetDragging: Bool = false
    
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
    @Published public var isCarpetTargeted: Bool = false
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
    
    // Photo drag state
    @Published public var draggingPhotoSlot: Int? = nil
    @Published public var photoDragTranslation: CGSize = .zero
    
    @Published public var isHoveringDeskMail: Bool = false
    @Published public var isHoveringWallCalendar: Bool = false
    @Published public var isHoveringGuitar: Bool = false
    @Published public var isHoveringTrash: Bool = false
    @Published public var hoveredPlaque: ActiveDesktopQuickView? = nil
    
    // Window Visibility for power conservation
    @Published public var isWindowVisible: Bool = true
    
    // Hardware-accelerated continuous leaf sway phase
    @Published public var plantSwayPhase: Bool = false
    
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


