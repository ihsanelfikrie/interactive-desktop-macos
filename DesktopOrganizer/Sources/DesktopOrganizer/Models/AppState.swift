import SwiftUI
import AppKit

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
    @Published public var showRugPeek: Bool = false
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
}

