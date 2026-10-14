import SwiftUI
import AppKit

public enum RoomTheme: String, CaseIterable, Identifiable, Codable {
    case library = "library"
    case kos = "kos"
    case garden = "garden"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .library: return "Library"
        case .kos: return "Kos Room"
        case .garden: return "Garden"
        }
    }
    
    public var description: String {
        switch self {
        case .library:
            return "A classic reading room. Files become books, folders become archive boxes."
        case .kos:
            return "An Indonesian boarding-house room. Folders are noodle cartons, files hide under the mattress."
        case .garden:
            return "A pixel-art garden. Folders are flower pots that grow as they fill up."
        }
    }
    
    public var backgroundImageName: String {
        switch self {
        case .library: return "background"
        case .kos: return "kos-background"
        case .garden: return "garden-background"
        }
    }
    
    public var matImageName: String {
        switch self {
        case .library: return "rug"
        case .kos: return "kos-mat"
        case .garden: return "garden-mat"
        }
    }
    
    public var lumpImageName: String {
        switch self {
        case .library: return "kos-lump" // fallback lump
        case .kos: return "kos-lump"
        case .garden: return "garden-lump"
        }
    }
    
    public var pileImageName: String {
        switch self {
        case .library: return "kos-pile" // fallback pile
        case .kos: return "kos-pile"
        case .garden: return "garden-pile"
        }
    }
    
    public var radioOffImageName: String {
        switch self {
        case .library: return "kos-radio"
        case .kos: return "kos-radio"
        case .garden: return "garden-radio"
        }
    }
    
    public var radioOnImageName: String {
        switch self {
        case .library: return "kos-radio-on"
        case .kos: return "kos-radio-on"
        case .garden: return "garden-radio-on"
        }
    }
}

public final class AssetLoader {
    private static var cache: [String: NSImage] = [:]
    
    public static func image(named name: String) -> NSImage? {
        if let cached = cache[name] {
            return cached
        }
        
        let cleanName = name.hasSuffix(".png") ? String(name.dropLast(4)) : name
        
        // 1. Check Bundle.module if available
        #if SWIFT_PACKAGE
        if let img = Bundle.module.image(forResource: cleanName) {
            cache[name] = img
            return img
        }
        if let path = Bundle.module.path(forResource: cleanName, ofType: "png"),
           let img = NSImage(contentsOfFile: path) {
            cache[name] = img
            return img
        }
        #endif
        
        // 2. Check Bundle.main
        if let img = NSImage(named: cleanName) {
            cache[name] = img
            return img
        }
        if let path = Bundle.main.path(forResource: cleanName, ofType: "png"),
           let img = NSImage(contentsOfFile: path) {
            cache[name] = img
            return img
        }
        
        // 3. Check inside Resources subfolder / DesktopOrganizer_DesktopOrganizer.bundle
        let main = Bundle.main.bundleURL
        let checks = [
            main.appendingPathComponent("Contents/Resources/\(cleanName).png"),
            main.appendingPathComponent("Contents/Resources/DesktopOrganizer_DesktopOrganizer.bundle/Contents/Resources/\(cleanName).png"),
            main.deletingLastPathComponent().appendingPathComponent("DesktopOrganizer_DesktopOrganizer.bundle/Contents/Resources/\(cleanName).png"),
            URL(fileURLWithPath: "Sources/DesktopOrganizer/Resources/\(cleanName).png")
        ]
        
        for url in checks {
            if let img = NSImage(contentsOf: url) {
                cache[name] = img
                return img
            }
        }
        
        return nil
    }
}
