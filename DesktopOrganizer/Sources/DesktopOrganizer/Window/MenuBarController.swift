import AppKit

public final class MenuBarController {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    
    private init() {}
    
    public func setupMenuBar() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "house.fill", accessibilityDescription: "Custom Desktop Mac")
            button.toolTip = "Custom Desktop Mac"
        }
        
        let menu = NSMenu()
        
        // 1. Toggle Room
        let toggleRoomItem = NSMenuItem(title: "Tampilkan / Sembunyikan Ruangan", action: #selector(toggleRoomAction), keyEquivalent: "t")
        toggleRoomItem.target = self
        menu.addItem(toggleRoomItem)
        
        // 2. Change Theme
        let themeItem = NSMenuItem(title: "Ganti Tema...", action: #selector(changeThemeAction), keyEquivalent: "m")
        themeItem.target = self
        menu.addItem(themeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 3. Open Bookshelf Folder
        let shelfItem = NSMenuItem(title: "Buka Folder Rak", action: #selector(openShelfFolderAction), keyEquivalent: "b")
        shelfItem.target = self
        menu.addItem(shelfItem)
        
        // 4. Open Photos Folder
        let photosItem = NSMenuItem(title: "Buka Folder Foto", action: #selector(openPhotosFolderAction), keyEquivalent: "p")
        photosItem.target = self
        menu.addItem(photosItem)
        
        // 5. Restore All from rug to Origin
        let restoreItem = NSMenuItem(title: "Kembalikan Semua ke Tempat Asal", action: #selector(restoreAllAction), keyEquivalent: "r")
        restoreItem.target = self
        menu.addItem(restoreItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 6. Move Covered Desktop Icons
        let moveIconsItem = NSMenuItem(title: "Geser Ikon yang Tertutup", action: #selector(moveCoveredIconsAction), keyEquivalent: "g")
        moveIconsItem.target = self
        menu.addItem(moveIconsItem)
        
        // 7. Toggle Native Desktop Icons
        let toggleIconsItem = NSMenuItem(title: "Sembunyikan / Munculkan Ikon Desktop Asli", action: #selector(toggleIconsAction), keyEquivalent: "h")
        toggleIconsItem.target = self
        menu.addItem(toggleIconsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 8. About
        let aboutItem = NSMenuItem(title: "Tentang Custom Desktop Mac", action: #selector(aboutAction), keyEquivalent: "a")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        // 9. Quit
        let quitItem = NSMenuItem(title: "Keluar", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        self.statusItem = statusItem
    }
    
    @objc private func toggleRoomAction() {
        guard let window = DesktopWindowManager.shared.window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc private func changeThemeAction() {
        AppState.shared.showThemePicker = true
        DesktopWindowManager.shared.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func openShelfFolderAction() {
        StorageManager.shared.openInFinder(url: StorageManager.shared.bookshelfDirectory)
    }
    
    @objc private func openPhotosFolderAction() {
        StorageManager.shared.openInFinder(url: StorageManager.shared.photosDirectory)
    }
    
    @objc private func restoreAllAction() {
        let alert = NSAlert()
        alert.messageText = "Kembalikan semua item ke tempat asalnya?"
        alert.informativeText = "File yang tempat asalnya tidak diketahui akan dikembalikan ke Desktop."
        alert.addButton(withTitle: "Kembalikan")
        alert.addButton(withTitle: "Batal")
        if alert.runModal() == .alertFirstButtonReturn {
            StorageManager.shared.restoreEverything()
        }
    }
    
    @objc private func moveCoveredIconsAction() {
        StorageManager.shared.moveCoveredIcons()
    }
    
    @objc private func toggleIconsAction() {
        StorageManager.shared.toggleNativeDesktopIcons()
    }
    
    @objc private func aboutAction() {
        let alert = NSAlert()
        alert.messageText = "Custom Desktop Mac"
        alert.informativeText = "Custom Desktop Mac 1.0\nCopyright © 2026 Ihsan Elfikrie & SANS Studio. All rights reserved.\nInteractive desktop organizer for macOS."
        alert.runModal()
    }
    
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
