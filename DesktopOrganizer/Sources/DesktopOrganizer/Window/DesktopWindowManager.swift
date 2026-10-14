import SwiftUI
import AppKit

public final class DesktopWindowManager: ObservableObject {
    public static let shared = DesktopWindowManager()
    
    public var window: NSWindow?
    @Published public var isDesktopPinned: Bool = true
    
    private init() {
        setupScreenChangeObserver()
    }
    
    public func setupWindow() {
        guard let screen = NSScreen.main else { return }
        
        let screenRect = screen.frame
        let window = NSWindow(
            contentRect: screenRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.isReleasedWhenClosed = false
        window.isOpaque = true
        window.hasShadow = false
        window.backgroundColor = .black
        window.ignoresMouseEvents = false
        
        // Multi-space & stationary behavior
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        
        // Host the SwiftUI view
        let rootView = DesktopRootView()
        let hostingView = NSHostingView(rootView: rootView)
        window.contentView = hostingView
        
        self.window = window
        applyWindowLevel()
        window.makeKeyAndOrderFront(nil)
    }
    
    private func setupScreenChangeObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, let screen = NSScreen.main, let window = self.window else { return }
            window.setFrame(screen.frame, display: true)
        }
    }
    
    public func applyWindowLevel() {
        guard let window = window else { return }
        if isDesktopPinned {
            // Sits at the desktop layer right above wallpaper, behind normal windows
            window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        } else {
            // Normal floating window mode
            window.level = .normal
        }
    }
    
    public func toggleWindowLevel() {
        isDesktopPinned.toggle()
        applyWindowLevel()
        window?.makeKeyAndOrderFront(nil)
    }
    
    public func bringToFront() {
        window?.level = .normal
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
