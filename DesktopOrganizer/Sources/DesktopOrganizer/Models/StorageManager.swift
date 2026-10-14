import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct StoredPosition: Codable {
    public var x: Double
    public var y: Double
}

public final class StorageManager: ObservableObject {
    public static let shared = StorageManager()
    
    public let baseDirectory: URL
    public let photosDirectory: URL
    public let bookshelfDirectory: URL
    public let carpetDirectory: URL
    private let notesFileURL: URL
    private let settingsFileURL: URL
    private let layoutFileURL: URL
    private var dirSource: DispatchSourceFileSystemObject?
    
    @Published public var bookshelfItems: [URL] = []
    @Published public var carpetItems: [URL] = []
    @Published public var photoSlots: [Int: URL] = [:]
    @Published public var cachedPhotos: [Int: NSImage] = [:]
    @Published public var stickyNotes: [StickyNote] = []
    @Published public var areDesktopIconsHidden: Bool = false
    @Published public var layoutPositions: [String: CGPoint] = [:]
    
    private init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        // Exact official directory: Documents/DesktopRoom
        self.baseDirectory = home.appendingPathComponent("Documents/DesktopRoom", isDirectory: true)
        self.photosDirectory = baseDirectory.appendingPathComponent("Album", isDirectory: true)
        self.bookshelfDirectory = baseDirectory.appendingPathComponent("Rak", isDirectory: true)
        self.carpetDirectory = baseDirectory.appendingPathComponent("Karpet", isDirectory: true)
        self.notesFileURL = baseDirectory.appendingPathComponent("notes.json")
        self.settingsFileURL = baseDirectory.appendingPathComponent("settings.json")
        self.layoutFileURL = baseDirectory.appendingPathComponent("layout.json")
        
        setupDirectories()
        migrateLegacyIfPresent()
        loadAllData()
        checkDesktopIconStatus()
        watchDirectory()
    }
    
    private func setupDirectories() {
        let fileManager = FileManager.default
        let dirs = [baseDirectory, photosDirectory, bookshelfDirectory, carpetDirectory]
        for dir in dirs {
            if !fileManager.fileExists(atPath: dir.path) {
                try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
            }
        }
        
        // Auto-merge legacy 'books', 'photos', and 'rug' folders if present
        let legacyBooks = baseDirectory.appendingPathComponent("books", isDirectory: true)
        let legacyPhotos = baseDirectory.appendingPathComponent("photos", isDirectory: true)
        let legacyRug = baseDirectory.appendingPathComponent("rug", isDirectory: true)
        
        func mergeContents(from src: URL, to dst: URL) {
            guard fileManager.fileExists(atPath: src.path),
                  let items = try? fileManager.contentsOfDirectory(at: src, includingPropertiesForKeys: nil) else { return }
            for item in items {
                let target = safeDestinationURL(in: dst, originalName: item.lastPathComponent)
                try? fileManager.moveItem(at: item, to: target)
            }
        }
        
        mergeContents(from: legacyBooks, to: bookshelfDirectory)
        mergeContents(from: legacyPhotos, to: photosDirectory)
        mergeContents(from: legacyRug, to: carpetDirectory)
    }
    
    // Migrate from old ~/DesktopOrganizer if user previously used it
    private func migrateLegacyIfPresent() {
        let oldDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("DesktopOrganizer", isDirectory: true)
        guard FileManager.default.fileExists(atPath: oldDir.path) else { return }
        
        let fm = FileManager.default
        let oldBooks = oldDir.appendingPathComponent("Bookshelf")
        let oldCarpet = oldDir.appendingPathComponent("MagicCarpet")
        let oldPhotos = oldDir.appendingPathComponent("Photos")
        let oldNotes = oldDir.appendingPathComponent("notes.json")
        
        func moveContents(from src: URL, to dst: URL) {
            guard let items = try? fm.contentsOfDirectory(at: src, includingPropertiesForKeys: nil) else { return }
            for item in items {
                let target = safeDestinationURL(in: dst, originalName: item.lastPathComponent)
                try? fm.moveItem(at: item, to: target)
            }
        }
        
        moveContents(from: oldBooks, to: bookshelfDirectory)
        moveContents(from: oldCarpet, to: carpetDirectory)
        moveContents(from: oldPhotos, to: photosDirectory)
        if !fm.fileExists(atPath: notesFileURL.path) && fm.fileExists(atPath: oldNotes.path) {
            try? fm.copyItem(at: oldNotes, to: notesFileURL)
        }
    }
    
    // Auto-refresh when files change in DesktopRoom
    private func watchDirectory() {
        let descriptor = open(baseDirectory.path, O_EVTONLY)
        guard descriptor >= 0 else { return }
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .rename, .delete],
            queue: .main
        )
        source.setEventHandler { [weak self] in
            self?.loadAllData()
        }
        source.setCancelHandler {
            close(descriptor)
        }
        source.resume()
        self.dirSource = source
    }
    
    public func loadAllData() {
        refreshBookshelf()
        refreshCarpet()
        refreshPhotos()
        loadStickyNotes()
    }
    
    // MARK: - Customizable Layout Management
    public func loadLayout(screenSize: CGSize) {
        if let data = try? Data(contentsOf: layoutFileURL),
           let dict = try? JSONDecoder().decode([String: StoredPosition].self, from: data),
           !dict.isEmpty {
            var result: [String: CGPoint] = [:]
            for (k, v) in dict {
                result[k] = CGPoint(x: v.x, y: v.y)
            }
            self.layoutPositions = result
        } else {
            resetLayout(screenSize: screenSize)
        }
    }
    
    public func saveLayout() {
        var dict: [String: StoredPosition] = [:]
        for (k, v) in layoutPositions {
            dict[k] = StoredPosition(x: Double(v.x), y: Double(v.y))
        }
        if let data = try? JSONEncoder().encode(dict) {
            try? data.write(to: layoutFileURL)
        }
    }
    
    public func resetLayout(screenSize: CGSize) {
        let w = screenSize.width > 0 ? screenSize.width : 1440
        let h = screenSize.height > 0 ? screenSize.height : 900
        
        var pos: [String: CGPoint] = [:]
        pos["bookshelf"] = CGPoint(x: 40, y: max(100, h - 510))
        pos["plant"] = CGPoint(x: 230, y: max(200, h - 180))
        pos["corkboard"] = CGPoint(x: max(260, w * 0.5 - 340), y: 70)
        pos["clockCalendar"] = CGPoint(x: max(320, w * 0.5 + 130), y: 75)
        pos["photoGallery"] = CGPoint(x: max(400, w - 280), y: 80)
        pos["desk"] = CGPoint(x: max(200, w * 0.5 - 340), y: max(150, h - 250))
        pos["carpet"] = CGPoint(x: max(220, w * 0.5 - 180), y: max(150, h - 170))
        pos["trashCan"] = CGPoint(x: max(300, w * 0.5 + 360), y: max(150, h - 165))
        pos["standingFan"] = CGPoint(x: max(150, w * 0.5 - 430), y: max(150, h - 210))
        pos["waterDispenser"] = CGPoint(x: max(300, w * 0.5 + 360), y: max(150, h - 220))
        
        self.layoutPositions = pos
        saveLayout()
    }
    
    // MARK: - Reliable Drag & Drop URL Extractor
    public static func extractFileURL(from provider: NSItemProvider, completion: @escaping (URL) -> Void) {
        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                var targetURL: URL? = nil
                if let url = item as? URL {
                    targetURL = url
                } else if let data = item as? Data {
                    targetURL = URL(dataRepresentation: data, relativeTo: nil)
                } else if let str = item as? String {
                    targetURL = URL(fileURLWithPath: str)
                }
                if let url = targetURL {
                    DispatchQueue.main.async {
                        completion(url)
                    }
                }
            }
        } else {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        completion(url)
                    }
                }
            }
        }
    }
    
    // MARK: - Safe File Destination (Prevents Data Overwriting)
    private func safeDestinationURL(in directory: URL, originalName: String) -> URL {
        let fileManager = FileManager.default
        var destURL = directory.appendingPathComponent(originalName)
        if !fileManager.fileExists(atPath: destURL.path) {
            return destURL
        }
        
        let baseName = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        var counter = 1
        while fileManager.fileExists(atPath: destURL.path) {
            let newName = ext.isEmpty ? "\(baseName) (\(counter))" : "\(baseName) (\(counter)).\(ext)"
            destURL = directory.appendingPathComponent(newName)
            counter += 1
        }
        return destURL
    }
    
    // MARK: - Bookshelf
    public func refreshBookshelf() {
        let fileManager = FileManager.default
        if let contents = try? fileManager.contentsOfDirectory(at: bookshelfDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) {
            DispatchQueue.main.async {
                self.bookshelfItems = contents.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            }
        }
    }
    
    public func addBookshelfItem(from sourceURL: URL) {
        let destURL = safeDestinationURL(in: bookshelfDirectory, originalName: sourceURL.lastPathComponent)
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destURL)
            setOriginAttribute(destURL: destURL, originPath: sourceURL.path)
            refreshBookshelf()
        } catch {
            if (try? FileManager.default.copyItem(at: sourceURL, to: destURL)) != nil {
                setOriginAttribute(destURL: destURL, originPath: sourceURL.path)
                try? FileManager.default.removeItem(at: sourceURL)
                refreshBookshelf()
            }
        }
    }
    
    public func restoreBookshelfItemToDesktop(itemURL: URL) {
        let destinationFolder: URL
        if let originPath = getOriginPath(for: itemURL) {
            let parent = URL(fileURLWithPath: originPath).deletingLastPathComponent()
            if FileManager.default.fileExists(atPath: parent.path) {
                destinationFolder = parent
            } else {
                destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
            }
        } else {
            destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
        }
        
        let destURL = safeDestinationURL(in: destinationFolder, originalName: itemURL.lastPathComponent)
        do {
            try FileManager.default.moveItem(at: itemURL, to: destURL)
            refreshBookshelf()
        } catch {
            print("Gagal mengembalikan buku ke desktop: \(error)")
        }
    }
    
    public func restoreAllBookshelfItems() {
        for item in bookshelfItems {
            restoreBookshelfItemToDesktop(itemURL: item)
        }
    }
    
    public func removeBookshelfItem(itemURL: URL) {
        _ = moveToTrash(url: itemURL)
    }
    
    public func restoreEverything() {
        restoreAllBookshelfItems()
        restoreAllCarpetItems()
        for (slot, url) in photoSlots {
            restoreBookshelfItemToDesktop(itemURL: url)
            removePhoto(slotIndex: slot)
        }
    }
    
    public func pickBookshelfItem() {
        let panel = NSOpenPanel()
        panel.title = "Pilih File atau Folder untuk Rak Buku"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            for url in panel.urls {
                addBookshelfItem(from: url)
            }
        }
    }
    
    // MARK: - Magic Carpet
    public func refreshCarpet() {
        let fileManager = FileManager.default
        if let contents = try? fileManager.contentsOfDirectory(at: carpetDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) {
            DispatchQueue.main.async {
                self.carpetItems = contents.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            }
        }
    }
    
    public func addCarpetItem(from sourceURL: URL) {
        let destURL = safeDestinationURL(in: carpetDirectory, originalName: sourceURL.lastPathComponent)
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destURL)
            setOriginAttribute(destURL: destURL, originPath: sourceURL.path)
            refreshCarpet()
        } catch {
            // fallback to copy if move fails across volumes
            if (try? FileManager.default.copyItem(at: sourceURL, to: destURL)) != nil {
                setOriginAttribute(destURL: destURL, originPath: sourceURL.path)
                try? FileManager.default.removeItem(at: sourceURL)
                refreshCarpet()
            }
        }
    }
    
    private func setOriginAttribute(destURL: URL, originPath: String) {
        destURL.path.withCString { cPath in
            originPath.withCString { cOrigin in
                _ = setxattr(cPath, "id.desktoporganizer.origin", cOrigin, originPath.utf8.count, 0, 0)
            }
        }
    }
    
    public func getOriginPath(for url: URL) -> String? {
        var buffer = [CChar](repeating: 0, count: 1024)
        let size = url.path.withCString { cPath in
            getxattr(cPath, "id.desktoporganizer.origin", &buffer, buffer.count, 0, 0)
        }
        guard size > 0 else { return nil }
        return String(bytes: buffer.prefix(size).map { UInt8($0) }, encoding: .utf8)
    }
    
    public func pickCarpetItem() {
        let panel = NSOpenPanel()
        panel.title = "Pilih File untuk Disembunyikan di Bawah Karpet"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            for url in panel.urls {
                addCarpetItem(from: url)
            }
        }
    }
    
    public func restoreCarpetItemToDesktop(itemURL: URL) {
        let destinationFolder: URL
        if let originPath = getOriginPath(for: itemURL) {
            let parent = URL(fileURLWithPath: originPath).deletingLastPathComponent()
            if FileManager.default.fileExists(atPath: parent.path) {
                destinationFolder = parent
            } else {
                destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
            }
        } else {
            destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
        }
        
        let destURL = safeDestinationURL(in: destinationFolder, originalName: itemURL.lastPathComponent)
        do {
            try FileManager.default.moveItem(at: itemURL, to: destURL)
            refreshCarpet()
        } catch {
            print("DesktopOrganizer: gagal mengembalikan \(itemURL.lastPathComponent): \(error)")
        }
    }
    
    public func restoreAllCarpetItems() {
        for item in carpetItems {
            restoreCarpetItemToDesktop(itemURL: item)
        }
    }
    
    // MARK: - Desktop Icon Mover (AppleScript Repositioning)
    public func moveCoveredIcons() {
        DispatchQueue.global(qos: .userInitiated).async {
            let scriptSource = """
            tell application "Finder"
                try
                    set theNames to name of every item of desktop
                    set thePositions to desktop position of every item of desktop
                on error
                    set out to {}
                    repeat with anItem in (every item of desktop)
                        try
                            set p to desktop position of anItem
                            set end of out to {name of anItem as text, item 1 of p, item 2 of p}
                        end try
                    end repeat
                    return out
                end try
                set out to {}
                repeat with i from 1 to count of theNames
                    try
                        set p to item i of thePositions
                        set end of out to {item i of theNames as text, item 1 of p, item 2 of p}
                    end try
                end repeat
                return out
            end tell
            """
            var error: NSDictionary?
            guard let script = NSAppleScript(source: scriptSource) else { return }
            let desc = script.executeAndReturnError(&error)
            guard error == nil else {
                print("DesktopOrganizer: AppleScript error: \(String(describing: error))")
                return
            }
            
            let count = desc.numberOfItems
            var nextY: Int = 100
            for i in 1...count {
                if let item = desc.atIndex(i), item.numberOfItems >= 3,
                   let name = item.atIndex(1)?.stringValue,
                   let x = item.atIndex(2)?.int32Value,
                   let y = item.atIndex(3)?.int32Value {
                    // If covered by shelf (x < 420) or desk/carpet (y > 450)
                    if x < 420 || (y > 450 && x < 850) {
                        let moveScript = """
                        tell application "Finder"
                            try
                                set desktop position of item "\(name.replacingOccurrences(of: "\"", with: "\\\""))" of desktop to {1250, \(nextY)}
                            end try
                        end tell
                        """
                        if let s = NSAppleScript(source: moveScript) {
                            var err: NSDictionary?
                            s.executeAndReturnError(&err)
                        }
                        nextY += 95
                    }
                }
            }
        }
    }
    
    // MARK: - Photos & Image Cache (Low Memory & Zero Redraw I/O)
    public func refreshPhotos() {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return }
        
        var dict: [Int: URL] = [:]
        var imgDict: [Int: NSImage] = [:]
        var unslotted: [URL] = []
        
        let validExtensions = Set(["jpg", "jpeg", "png", "webp", "heic", "tiff", "gif"])
        
        for file in contents {
            let ext = file.pathExtension.lowercased()
            guard validExtensions.contains(ext) else { continue }
            
            let name = file.deletingPathExtension().lastPathComponent
            if name.hasPrefix("frame_"), let idxStr = name.components(separatedBy: "_").last, let idx = Int(idxStr) {
                dict[idx] = file
                if let image = NSImage(contentsOf: file) {
                    imgDict[idx] = image
                }
            } else {
                unslotted.append(file)
            }
        }
        
        // Fill empty slots (0..6) with unslotted photos
        unslotted.sort(by: { $0.lastPathComponent < $1.lastPathComponent })
        var unslottedIdx = 0
        for slot in 0...6 {
            if dict[slot] == nil && unslottedIdx < unslotted.count {
                let file = unslotted[unslottedIdx]
                dict[slot] = file
                if let image = NSImage(contentsOf: file) {
                    imgDict[slot] = image
                }
                unslottedIdx += 1
            }
        }
        
        DispatchQueue.main.async {
            self.photoSlots = dict
            self.cachedPhotos = imgDict
        }
    }
    
    public func assignPhoto(sourceURL: URL, slotIndex: Int) {
        let ext = sourceURL.pathExtension.isEmpty ? "jpg" : sourceURL.pathExtension
        let destURL = photosDirectory.appendingPathComponent("frame_\(slotIndex).\(ext)")
        do {
            if let existing = photoSlots[slotIndex] {
                try? FileManager.default.removeItem(at: existing)
            }
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
            refreshPhotos()
        } catch {
            print("Gagal menyimpan foto: \(error)")
        }
    }
    
    public func pickPhoto(forSlot slotIndex: Int) {
        let panel = NSOpenPanel()
        panel.title = "Pilih Foto untuk Bingkai #\(slotIndex + 1)"
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK, let url = panel.url {
            assignPhoto(sourceURL: url, slotIndex: slotIndex)
        }
    }
    
    public func removePhoto(slotIndex: Int) {
        if let existing = photoSlots[slotIndex] {
            try? FileManager.default.removeItem(at: existing)
            refreshPhotos()
        }
    }
    
    // MARK: - Sticky Notes
    public func loadStickyNotes() {
        guard let data = try? Data(contentsOf: notesFileURL),
              let notes = try? JSONDecoder().decode([StickyNote].self, from: data) else {
            // Default sample notes if first run
            let defaultNotes = [
                StickyNote(
                    title: "Rencana Hari Ini 📝",
                    tasks: [
                        TaskItem(text: "Rapikan file desktop", isCompleted: true),
                        TaskItem(text: "Bikin to-do list", isCompleted: true),
                        TaskItem(text: "Putar lagu di radio Spotify", isCompleted: false)
                    ],
                    color: .lime,
                    x: 20,
                    y: 20
                ),
                StickyNote(
                    title: "SANS Design ✳",
                    tasks: [
                        TaskItem(text: "Electric Blue & Lime Accent", isCompleted: true),
                        TaskItem(text: "Taruh foto favorit di dinding", isCompleted: false)
                    ],
                    color: .pink,
                    x: 180,
                    y: 40
                )
            ]
            self.stickyNotes = defaultNotes
            saveStickyNotes()
            return
        }
        self.stickyNotes = notes
    }
    
    public func saveStickyNotes() {
        if let data = try? JSONEncoder().encode(stickyNotes) {
            try? data.write(to: notesFileURL)
        }
    }
    
    public func addStickyNote() {
        let colors: [NoteColor] = NoteColor.allCases
        let randomColor = colors.randomElement() ?? .lime
        let newNote = StickyNote(
            title: "Catatan Baru",
            tasks: [TaskItem(text: "Ketik tugas di sini...")],
            color: randomColor,
            x: CGFloat.random(in: 40...200),
            y: CGFloat.random(in: 40...160)
        )
        stickyNotes.append(newNote)
        saveStickyNotes()
    }
    
    public func removeStickyNote(id: UUID) {
        stickyNotes.removeAll(where: { $0.id == id })
        saveStickyNotes()
    }
    
    // MARK: - Trash
    public func moveToTrash(url: URL) -> Bool {
        do {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            NSSound(named: "Trash")?.play()
            refreshBookshelf()
            refreshCarpet()
            return true
        } catch {
            print("Gagal membuang ke sampah: \(error)")
            return false
        }
    }
    
    // MARK: - Finder utilities
    public func openInFinder(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    public func openBaseFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: baseDirectory.path)
    }
    
    // MARK: - Native Desktop Icons Management
    public func checkDesktopIconStatus() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "com.apple.finder", "CreateDesktop"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try? task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            DispatchQueue.main.async {
                self.areDesktopIconsHidden = (output == "false" || output == "0")
            }
        }
    }
    
    public func toggleNativeDesktopIcons() {
        let shouldHide = !areDesktopIconsHidden
        let valString = shouldHide ? "false" : "true"
        
        let writeTask = Process()
        writeTask.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        writeTask.arguments = ["write", "com.apple.finder", "CreateDesktop", valString]
        try? writeTask.run()
        writeTask.waitUntilExit()
        
        let killTask = Process()
        killTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killTask.arguments = ["Finder"]
        try? killTask.run()
        killTask.waitUntilExit()
        
        DispatchQueue.main.async {
            self.areDesktopIconsHidden = shouldHide
        }
    }
}
