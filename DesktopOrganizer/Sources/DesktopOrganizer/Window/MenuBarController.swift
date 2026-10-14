import AppKit

public final class MenuBarController {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    
    private init() {}
    
    public func setupMenuBar() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "house.fill", accessibilityDescription: "Desktop Organizer")
            button.toolTip = "Desktop Organizer macOS"
        }
        
        let menu = NSMenu()
        
        let frontItem = NSMenuItem(title: "Bawa ke Depan (Front Mode)", action: #selector(bringToFrontAction), keyEquivalent: "f")
        frontItem.target = self
        menu.addItem(frontItem)
        
        let pinItem = NSMenuItem(title: "Kunci di Desktop (Desktop Layer)", action: #selector(pinToDesktopAction), keyEquivalent: "d")
        pinItem.target = self
        menu.addItem(pinItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let toggleIconsItem = NSMenuItem(title: "Sembunyikan / Munculkan Ikon Desktop Asli", action: #selector(toggleIconsAction), keyEquivalent: "h")
        toggleIconsItem.target = self
        menu.addItem(toggleIconsItem)
        
        let openFolderItem = NSMenuItem(title: "Buka Folder DesktopOrganizer di Finder", action: #selector(openFolderAction), keyEquivalent: "o")
        openFolderItem.target = self
        menu.addItem(openFolderItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Keluar (Quit)", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        self.statusItem = statusItem
    }
    
    @objc private func bringToFrontAction() {
        DesktopWindowManager.shared.isDesktopPinned = false
        DesktopWindowManager.shared.bringToFront()
    }
    
    @objc private func pinToDesktopAction() {
        DesktopWindowManager.shared.isDesktopPinned = true
        DesktopWindowManager.shared.applyWindowLevel()
    }
    
    @objc private func toggleIconsAction() {
        StorageManager.shared.toggleNativeDesktopIcons()
    }
    
    @objc private func openFolderAction() {
        StorageManager.shared.openBaseFolder()
    }
    
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
