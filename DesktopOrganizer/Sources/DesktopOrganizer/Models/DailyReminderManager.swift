import Foundation
import SwiftUI
import AppKit

public struct UrgentFrameTask: Identifiable, Equatable {
    public var id: String { nama + reminder + deadline }
    public let nama: String
    public let reminder: String
    public let tglFoto: String
    public let deadline: String
    public let tipe: String
    public let brief: String
    
    public init(nama: String, reminder: String, tglFoto: String, deadline: String, tipe: String, brief: String) {
        self.nama = nama
        self.reminder = reminder
        self.tglFoto = tglFoto
        self.deadline = deadline
        self.tipe = tipe
        self.brief = brief
    }
}

public struct DailyFocusData: Equatable {
    public var day: String = ""
    public var date: String = ""
    public var schedules: [String] = []
    public var masterTasks: [String] = []
    public var urgentFrames: [UrgentFrameTask] = []
    public var rawText: String = ""
    public var updatedAt: String = ""
    public var isEmpty: Bool = true
    
    public init() {}
}

private struct DailyFocusJSONPayload: Codable {
    let updated_at: String?
    let date: String?
    let day: String?
    let schedules: [String]?
    let master_tasks: [String]?
    let urgent_frames: [[String: String]]?
    let full_text: String?
}

public final class DailyReminderManager: ObservableObject {
    public static let shared = DailyReminderManager()
    
    public let reminderDir: URL
    public let jsonFileURL: URL
    public let txtFileURL: URL
    
    @Published public var data: DailyFocusData = DailyFocusData()
    @Published public var isReloading: Bool = false
    @Published public var lastReloadDate: Date = Date()
    
    private var dirSource: DispatchSourceFileSystemObject?
    private var pollTimer: Timer?
    private var lastModDateJSON: Date?
    private var lastModDateTXT: Date?
    
    private init() {
        let base = URL(fileURLWithPath: "/Users/macbook/assistant-reminder")
        self.reminderDir = base
        self.jsonFileURL = base.appendingPathComponent("daily_focus.json")
        self.txtFileURL = base.appendingPathComponent("daily_focus.txt")
        
        loadData()
        setupDirectoryWatcher()
        setupPollingAndNotifications()
    }
    
    deinit {
        dirSource?.cancel()
        pollTimer?.invalidate()
    }
    
    // MARK: - Core File Reader
    public func loadData() {
        var parsed = DailyFocusData()
        let fm = FileManager.default
        
        // 1. Try JSON file first
        if fm.fileExists(atPath: jsonFileURL.path),
           let rawData = try? Data(contentsOf: jsonFileURL),
           !rawData.isEmpty {
            if let decoded = try? JSONDecoder().decode(DailyFocusJSONPayload.self, from: rawData) {
                parsed.day = decoded.day ?? ""
                parsed.date = decoded.date ?? ""
                parsed.schedules = decoded.schedules ?? []
                parsed.masterTasks = decoded.master_tasks ?? []
                parsed.updatedAt = decoded.updated_at ?? ""
                parsed.rawText = decoded.full_text ?? ""
                
                if let frames = decoded.urgent_frames {
                    parsed.urgentFrames = frames.map { dict in
                        UrgentFrameTask(
                            nama: dict["nama"] ?? "Custom Frame",
                            reminder: dict["reminder"] ?? "",
                            tglFoto: dict["tgl_foto"] ?? "",
                            deadline: dict["deadline"] ?? "",
                            tipe: dict["tipe"] ?? "",
                            brief: dict["brief"] ?? ""
                        )
                    }
                }
                
                let hasSchedules = !parsed.schedules.isEmpty
                let hasTasks = !parsed.masterTasks.isEmpty
                let hasFrames = !parsed.urgentFrames.isEmpty
                let hasText = !parsed.rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                
                parsed.isEmpty = !(hasSchedules || hasTasks || hasFrames || hasText)
            }
        }
        
        // 2. Fallback to TXT file if JSON was empty or not found
        if parsed.isEmpty && fm.fileExists(atPath: txtFileURL.path) {
            if let textContent = try? String(contentsOf: txtFileURL, encoding: .utf8) {
                let trimmed = textContent.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    parsed.rawText = trimmed
                    parsed.isEmpty = false
                    
                    // Simple line parsing if available
                    let lines = trimmed.components(separatedBy: .newlines)
                    if let firstLine = lines.first(where: { $0.contains("Hari:") }) {
                        parsed.day = firstLine.replacingOccurrences(of: "Hari:", with: "").trimmingCharacters(in: .whitespaces)
                    }
                }
            }
        }
        
        // Cache file modification dates
        lastModDateJSON = (try? fm.attributesOfItem(atPath: jsonFileURL.path)[.modificationDate]) as? Date
        lastModDateTXT = (try? fm.attributesOfItem(atPath: txtFileURL.path)[.modificationDate]) as? Date
        
        DispatchQueue.main.async {
            self.data = parsed
            self.lastReloadDate = Date()
            self.isReloading = false
        }
    }
    
    public func reloadManually() {
        isReloading = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadData()
        }
    }
    
    // MARK: - Auto-Refresh Watcher & Timers
    private func setupDirectoryWatcher() {
        let descriptor = open(reminderDir.path, O_EVTONLY)
        guard descriptor >= 0 else { return }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .rename, .delete, .extend],
            queue: DispatchQueue.global(qos: .utility)
        )
        source.setEventHandler { [weak self] in
            // Small debounce to let atomic file writes finish flushing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self?.loadData()
            }
        }
        source.setCancelHandler {
            close(descriptor)
        }
        source.resume()
        self.dirSource = source
    }
    
    private func setupPollingAndNotifications() {
        // Fallback polling every 10 seconds to detect in-place file modifications
        pollTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkForExternalChanges()
        }
        
        // Refresh when the app becomes active
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadData()
        }
    }
    
    private func checkForExternalChanges() {
        let fm = FileManager.default
        let currentJSONMod = (try? fm.attributesOfItem(atPath: jsonFileURL.path)[.modificationDate]) as? Date
        let currentTXTMod = (try? fm.attributesOfItem(atPath: txtFileURL.path)[.modificationDate]) as? Date
        
        if currentJSONMod != lastModDateJSON || currentTXTMod != lastModDateTXT {
            loadData()
        }
    }
}
