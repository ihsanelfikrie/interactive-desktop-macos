import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup Desktop Organizer Window
        DesktopWindowManager.shared.setupWindow()
        
        // Setup Menu Bar Extra Item
        MenuBarController.shared.setupMenuBar()
        
        // Set activation policy so it runs smoothly as an accessory / desktop helper
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
