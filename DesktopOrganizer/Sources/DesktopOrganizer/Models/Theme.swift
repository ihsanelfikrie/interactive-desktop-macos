import SwiftUI
import AppKit

// MARK: - SANS Design System Palette (100% Flat & High Contrast)
public struct SANSColors {
    /// Primary 60%: Electric Blue (#120CD6) - Background utama khas SANS, bold & profesional
    public static let primaryBlue = Color(red: 18/255.0, green: 12/255.0, blue: 214/255.0)
    
    /// Secondary 30%: Clean White (#FFFFFF) - Container, dropzone, card
    public static let cleanWhite = Color(red: 255/255.0, green: 255/255.0, blue: 255/255.0)
    
    /// Accent 1 (10%): Hijau Stabilo / Lime (#E5FD5F) - Highlight kata kunci, pill badge, sticky note
    public static let lime = Color(red: 229/255.0, green: 253/255.0, blue: 95/255.0)
    
    /// Accent 2 (10%): Pink / Magenta (#F908E0) - Tombol aksi, marker, badge penting
    public static let pink = Color(red: 249/255.0, green: 8/255.0, blue: 224/255.0)
    
    /// Text Primary: Hitam Pekat (#111111) - Teks utama di atas background terang
    public static let dark = Color(red: 17/255.0, green: 17/255.0, blue: 17/255.0)
    
    /// Base Canvas: Dark Indigo (#0D0B18) - Canvas dasar HTML/Body
    public static let darkIndigo = Color(red: 13/255.0, green: 11/255.0, blue: 24/255.0)
    
    /// Neutral Surface: Soft Surface (#F5F5F5) - Area input, backdrop netral
    public static let surface = Color(red: 245/255.0, green: 245/255.0, blue: 245/255.0)
    
    /// Divider / Border: Border Gray (#E5E7EB) - Garis pemisah tipis flat
    public static let border = Color(red: 229/255.0, green: 231/255.0, blue: 235/255.0)
}

public enum RoomTheme: String, CaseIterable, Identifiable, Codable {
    case library = "library"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        return "SANS Creative Studio"
    }
    
    public var description: String {
        return "100% Flat & Kontras Tinggi. Electric Blue (#120CD6), Clean White, Hijau Stabilo, dan Pink."
    }
    
    public var backgroundImageName: String { "background" }
    public var matImageName: String { "rug" }
    public var lumpImageName: String { "rug" }
    public var pileImageName: String { "rug" }
    public var radioOffImageName: String { "radio" }
    public var radioOnImageName: String { "radio" }
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
        
        // 3. Check inside Resources subfolder / Custom Desktop Mac.app
        let main = Bundle.main.bundleURL
        let checks = [
            main.appendingPathComponent("Contents/Resources/\(cleanName).png"),
            main.appendingPathComponent("Contents/Resources/DesktopOrganizer_DesktopOrganizer.bundle/Contents/Resources/\(cleanName).png"),
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
