import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

public final class StorageManager: ObservableObject {
    public static let shared = StorageManager()
    
    public let baseDirectory: URL
    public let photosDirectory: URL
    public let bookshelfDirectory: URL
    public let carpetDirectory: URL
    private let notesFileURL: URL
    private let settingsFileURL: URL
    
    @Published public var bookshelfItems: [URL] = []
    @Published public var carpetItems: [URL] = []
    @Published public var photoSlots: [Int: URL] = [:]
    @Published public var cachedPhotos: [Int: NSImage] = [:]
    @Published public var stickyNotes: [StickyNote] = []
    @Published public var areDesktopIconsHidden: Bool = false
    
    private init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.baseDirectory = home.appendingPathComponent("DesktopOrganizer", isDirectory: true)
        self.photosDirectory = baseDirectory.appendingPathComponent("Photos", isDirectory: true)
        self.bookshelfDirectory = baseDirectory.appendingPathComponent("Bookshelf", isDirectory: true)
        self.carpetDirectory = baseDirectory.appendingPathComponent("MagicCarpet", isDirectory: true)
        self.notesFileURL = baseDirectory.appendingPathComponent("notes.json")
        self.settingsFileURL = baseDirectory.appendingPathComponent("settings.json")
        
        setupDirectories()
        loadAllData()
        checkDesktopIconStatus()
    }
    
    private func setupDirectories() {
        let fileManager = FileManager.default
        let dirs = [baseDirectory, photosDirectory, bookshelfDirectory, carpetDirectory]
        for dir in dirs {
            if !fileManager.fileExists(atPath: dir.path) {
                try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
            }
        }
    }
    
    public func loadAllData() {
        refreshBookshelf()
        refreshCarpet()
        refreshPhotos()
        loadStickyNotes()
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
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
            refreshBookshelf()
        } catch {
            print("Gagal menambah buku ke rak: \(error)")
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
            refreshCarpet()
        } catch {
            // fallback to copy if move fails across volumes
            try? FileManager.default.copyItem(at: sourceURL, to: destURL)
            refreshCarpet()
        }
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
    
    // MARK: - Photos & Image Cache (Low Memory & Zero Redraw I/O)
    public func refreshPhotos() {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return }
        
        var dict: [Int: URL] = [:]
        var imgDict: [Int: NSImage] = [:]
        
        for file in contents {
            let name = file.deletingPathExtension().lastPathComponent
            if name.hasPrefix("frame_"), let idxStr = name.components(separatedBy: "_").last, let idx = Int(idxStr) {
                dict[idx] = file
                if let image = NSImage(contentsOf: file) {
                    imgDict[idx] = image
                }
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
                    color: .yellow,
                    x: 20,
                    y: 20
                ),
                StickyNote(
                    title: "Ide Kreatif 💡",
                    tasks: [
                        TaskItem(text: "Ganti tema ke Kos-kosan", isCompleted: false),
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
        let randomColor = colors.randomElement() ?? .yellow
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
