import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set activation policy to regular so macOS gives it full event focus & key window capabilities
        NSApp.setActivationPolicy(.regular)
        
        // Setup Desktop Organizer Window
        DesktopWindowManager.shared.setupWindow()
        
        // Setup Menu Bar Extra Item
        MenuBarController.shared.setupMenuBar()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        DesktopWindowManager.shared.window?.makeKeyAndOrderFront(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
