import SwiftUI
import AppKit

// Custom interactive NSWindow that can become key and main to receive all mouse & keyboard events
final class InteractiveDesktopWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

public final class DesktopWindowManager: ObservableObject {
    public static let shared = DesktopWindowManager()
    
    public var window: NSWindow?
    @Published public var isDesktopPinned: Bool = false
    
    private init() {
        setupScreenChangeObserver()
    }
    
    public func setupWindow() {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        
        let screenRect = screen.frame
        let window = InteractiveDesktopWindow(
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
        window.acceptsMouseMovedEvents = true
        window.isMovableByWindowBackground = false
        
        // Ensure it joins all spaces and behaves nicely with Mission Control
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        
        // Host the SwiftUI view
        let rootView = DesktopRootView()
        let hostingView = NSHostingView(rootView: rootView)
        window.contentView = hostingView
        
        self.window = window
        
        // Setup occlusion observer for zero-CPU background throttling
        setupOcclusionObserver(for: window)
        setupAppActiveObserver()
        
        // Normal window level by default so all clicks, textfields, and drag-drops work seamlessly
        window.level = .normal
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func setupOcclusionObserver(for window: NSWindow) {
        AppState.shared.isWindowVisible = window.occlusionState.contains(.visible)
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification,
            object: window,
            queue: .main
        ) { [weak window] _ in
            guard let window = window else { return }
            let isVisible = window.occlusionState.contains(.visible)
            if AppState.shared.isWindowVisible != isVisible {
                AppState.shared.isWindowVisible = isVisible
                if !isVisible {
                    AssetLoader.purgeMemory()
                    FileIconCache.shared.purge()
                }
            }
        }
    }
    
    private func setupAppActiveObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            AppState.shared.isAppActive = true
        }
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            AppState.shared.isAppActive = false
            // Purge non-essential caches to free RAM for user heavy applications
            AssetLoader.purgeMemory()
            FileIconCache.shared.purge()
        }
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
            // Background wallpaper mode
            window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        } else {
            // Normal interactive mode
            window.level = .normal
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    public func toggleWindowLevel() {
        isDesktopPinned.toggle()
        applyWindowLevel()
    }
    
    public func bringToFront() {
        isDesktopPinned = false
        applyWindowLevel()
    }
}
