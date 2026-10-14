import SwiftUI
import AppKit

// MARK: - Desktop Quick View Popover Shell (Apple Liquid Glass Card)
struct DesktopQuickViewCard<Content: View>: View {
    let title: String
    let iconName: String
    let iconColor: Color
    var width: CGFloat = 260
    let onClose: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(NSColor.labelColor))
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                }
                .buttonStyle(.plain)
                .help("Tutup (Escape)")
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)
            
            Divider()
                .opacity(0.3)
            
            // Content
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(14)
        }
        .frame(width: width)
        .fixedSize(horizontal: true, vertical: true)
        .background(
            ZStack {
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
                Color(NSColor.windowBackgroundColor).opacity(0.82)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.70), Color.white.opacity(0.20)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.24), radius: 14, y: 8)
    }
}

// MARK: - 1. Clock Quick View
public struct ClockQuickView: View {
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f
    }()
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            DesktopQuickViewCard(
                title: "Jam Dinding",
                iconName: "clock.fill",
                iconColor: Color(red: 0.88, green: 0.35, blue: 0.28),
                onClose: onClose
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    // Digital Time Display
                    Text(Self.timeFormatter.string(from: timeline.date))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(NSColor.labelColor))
                    
                    Text(Self.dateFormatter.string(from: timeline.date))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 10))
                        Text("\(TimeZone.current.identifier) (\(TimeZone.current.abbreviation() ?? "WIB"))")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
                    
                    Divider().opacity(0.2)
                    
                    // Action button
                    Button(action: {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.clock") {
                            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                        }
                        onClose()
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.forward.app.fill")
                            Text("Buka Aplikasi Jam")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                    }
                    .buttonStyle(.plain)
                    
                    Text("💡 Tips: Klik 2x pada jam dinding untuk langsung membuka")
                        .font(.system(size: 9))
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - 2. Calendar Quick View
public struct CalendarQuickView: View {
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    public var body: some View {
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.day, from: now)
        let monthName = now.formatted(.dateTime.month(.wide).year())
        
        DesktopQuickViewCard(
            title: "Kalender",
            iconName: "calendar",
            iconColor: Color(red: 0.85, green: 0.25, blue: 0.22),
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 8) {
                // Header Month
                HStack {
                    Text(monthName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(NSColor.labelColor))
                    Spacer()
                    Text("Hari ini tgl \(currentDay)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                // Mini 7-day strip centered on today
                HStack(spacing: 4) {
                    ForEach(-3...3, id: \.self) { offset in
                        if let date = calendar.date(byAdding: .day, value: offset, to: now) {
                            let dayNum = calendar.component(.day, from: date)
                            let weekday = date.formatted(.dateTime.weekday(.narrow))
                            let isToday = offset == 0
                            
                            VStack(spacing: 2) {
                                Text(weekday)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(isToday ? .red : Color(NSColor.secondaryLabelColor))
                                
                                Text("\(dayNum)")
                                    .font(.system(size: 11, weight: isToday ? .bold : .regular))
                                    .foregroundColor(isToday ? .white : Color(NSColor.labelColor))
                                    .frame(width: 24, height: 24)
                                    .background(
                                        isToday ? Circle().fill(Color.red) : Circle().fill(Color.clear)
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.04)))
                
                Divider().opacity(0.2)
                
                // Action Button
                Button(action: {
                    if let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                        NSWorkspace.shared.openApplication(at: calURL, configuration: NSWorkspace.OpenConfiguration())
                    } else if let url = URL(string: "calshow:") {
                        NSWorkspace.shared.open(url)
                    }
                    onClose()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.forward.app.fill")
                        Text("Buka Apple Calendar")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.red))
                }
                .buttonStyle(.plain)
                
                Text("💡 Tips: Klik 2x pada kalender dinding untuk langsung membuka")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 3. Workstation Monitor / Finder Quick View
public struct MonitorQuickView: View {
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    public var body: some View {
        let userName = NSFullUserName().isEmpty ? NSUserName() : NSFullUserName()
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        
        DesktopQuickViewCard(
            title: "iMac / Finder",
            iconName: "desktopcomputer",
            iconColor: Color.blue,
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 8) {
                // User & Mac Info
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(userName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(NSColor.labelColor))
                        Text(homeURL.path)
                            .font(.system(size: 9))
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                            .lineLimit(1)
                    }
                }
                
                Divider().opacity(0.2)
                
                // Quick Directory Links
                Text("Akses Cepat:")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                
                HStack(spacing: 6) {
                    QuickFolderButton(name: "Dokumen", icon: "doc.fill", color: .blue) {
                        let docURL = homeURL.appendingPathComponent("Documents")
                        NSWorkspace.shared.open(docURL)
                        onClose()
                    }
                    
                    QuickFolderButton(name: "Unduhan", icon: "arrow.down.circle.fill", color: .green) {
                        let dlURL = homeURL.appendingPathComponent("Downloads")
                        NSWorkspace.shared.open(dlURL)
                        onClose()
                    }
                    
                    QuickFolderButton(name: "Desktop", icon: "macwindow", color: .purple) {
                        let dtURL = homeURL.appendingPathComponent("Desktop")
                        NSWorkspace.shared.open(dtURL)
                        onClose()
                    }
                }
                
                Divider().opacity(0.2)
                
                // Primary Action Button
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([homeURL])
                    onClose()
                }) {
                    HStack {
                        Image(systemName: "folder.fill")
                        Text("Buka Finder Utama")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                }
                .buttonStyle(.plain)
                
                Text("💡 Tips: Klik 2x pada layar monitor untuk langsung membuka Finder")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct QuickFolderButton: View {
    let name: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(NSColor.labelColor))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.04)))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 4. WhatsApp Quick View
public struct WhatsAppQuickView: View {
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    private func openWhatsApp() {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "net.whatsapp.WhatsApp") {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
        } else if let url = URL(string: "whatsapp://") {
            NSWorkspace.shared.open(url)
        } else if let webURL = URL(string: "https://web.whatsapp.com") {
            NSWorkspace.shared.open(webURL)
        }
        onClose()
    }
    
    public var body: some View {
        DesktopQuickViewCard(
            title: "WhatsApp",
            iconName: "phone.bubble.fill",
            iconColor: Color(red: 0.15, green: 0.83, blue: 0.40),
            width: 260,
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aplikasi Pesan & Panggilan WhatsApp")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                
                HStack(spacing: 8) {
                    // Open Web
                    Button(action: {
                        if let url = URL(string: "https://web.whatsapp.com") {
                            NSWorkspace.shared.open(url)
                        }
                        onClose()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "safari")
                            Text("WhatsApp Web")
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                    
                    // Open App
                    Button(action: {
                        openWhatsApp()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.forward.app.fill")
                            Text("Buka WhatsApp")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color(red: 0.15, green: 0.78, blue: 0.38)))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("💡 Tips: Klik 2x pada kartu meja untuk langsung membuka WhatsApp")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

public typealias DeskMailQuickView = WhatsAppQuickView

// MARK: - 5. Trash Can Quick View
public struct TrashQuickView: View {
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    private var trashCount: Int {
        guard let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first,
              let contents = try? FileManager.default.contentsOfDirectory(at: trashURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return 0
        }
        return contents.count
    }
    
    public var body: some View {
        let count = trashCount
        let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first
        
        DesktopQuickViewCard(
            title: "Tempat Sampah",
            iconName: "trash.fill",
            iconColor: Color(white: 0.40),
            width: 250,
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: count > 0 ? "trash.fill" : "trash")
                        .font(.system(size: 24))
                        .foregroundColor(count > 0 ? .orange : Color(NSColor.secondaryLabelColor))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(count > 0 ? "\(count) item di tempat sampah" : "Tempat sampah kosong")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(NSColor.labelColor))
                        Text("Seret file ke tong sampah untuk membuang")
                            .font(.system(size: 9))
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                    }
                }
                
                Divider().opacity(0.2)
                
                HStack(spacing: 6) {
                    if count > 0 {
                        Button(action: {
                            // Empty trash AppleScript
                            let script = NSAppleScript(source: "tell application \"Finder\" to empty trash")
                            var error: NSDictionary?
                            script?.executeAndReturnError(&error)
                            onClose()
                        }) {
                            Text("Kosongkan")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button(action: {
                        if let url = trashURL {
                            NSWorkspace.shared.open(url)
                        }
                        onClose()
                    }) {
                        HStack {
                            Image(systemName: "folder.fill")
                            Text("Buka di Finder")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("💡 Tips: Klik 2x pada tempat sampah untuk langsung membuka di Finder")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 6. Photo Frame Quick View
public struct PhotoFrameQuickView: View {
    let slotIndex: Int
    let onClose: () -> Void
    @ObservedObject var storage = StorageManager.shared
    
    public init(slotIndex: Int, onClose: @escaping () -> Void = {}) {
        self.slotIndex = slotIndex
        self.onClose = onClose
    }
    
    var photoURL: URL? {
        storage.photoSlots[slotIndex]
    }
    
    var cachedImage: NSImage? {
        storage.cachedPhotos[slotIndex]
    }
    
    public var body: some View {
        let transform = storage.transform(for: slotIndex)
        
        DesktopQuickViewCard(
            title: "Bingkai Foto #\(slotIndex + 1)",
            iconName: "photo.on.rectangle.angled",
            iconColor: Color.orange,
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if let image = cachedImage {
                    // Live Preview with Transform & Glass Sheen
                    ZStack {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 215, height: 105)
                            .scaleEffect(transform.scale)
                            .rotationEffect(.degrees(transform.rotation))
                            .offset(x: transform.offsetX * 0.45, y: transform.offsetY * 0.45)
                            .frame(width: 215, height: 105)
                            .clipped()
                        
                        // Glass Sheen Overlay
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.white.opacity(0.02), Color.clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .allowsHitTesting(false)
                    }
                    .frame(width: 215, height: 105)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.12), lineWidth: 1))
                    
                    // Transform Controls (Zoom, Rotate, Pan)
                    VStack(spacing: 6) {
                        // 1. Zoom Control
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 10))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                            
                            Slider(
                                value: Binding(
                                    get: { transform.scale },
                                    set: { newScale in
                                        var t = transform
                                        t.scale = newScale
                                        storage.updateTransform(for: slotIndex, transform: t)
                                    }
                                ),
                                in: 0.5...3.0,
                                step: 0.05
                            )
                            
                            Text(String(format: "%.1fx", transform.scale))
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .frame(width: 32, alignment: .trailing)
                        }
                        
                        // 2. Rotate Control
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                            
                            Slider(
                                value: Binding(
                                    get: { transform.rotation },
                                    set: { newRot in
                                        var t = transform
                                        t.rotation = newRot
                                        storage.updateTransform(for: slotIndex, transform: t)
                                    }
                                ),
                                in: -180.0...180.0,
                                step: 5.0
                            )
                            
                            Button(action: {
                                var t = transform
                                t.rotation = Double((Int(t.rotation + 90)) % 360)
                                storage.updateTransform(for: slotIndex, transform: t)
                            }) {
                                Text("+90°")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // 3. Pan Control Buttons & Reset
                        HStack {
                            Text("Geser:")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                            
                            HStack(spacing: 3) {
                                Button("◀") {
                                    var t = transform; t.offsetX -= 8; storage.updateTransform(for: slotIndex, transform: t)
                                }.buttonStyle(.plain).font(.system(size: 9)).padding(.horizontal, 4).padding(.vertical, 2).background(Color.black.opacity(0.06)).cornerRadius(3)
                                Button("▶") {
                                    var t = transform; t.offsetX += 8; storage.updateTransform(for: slotIndex, transform: t)
                                }.buttonStyle(.plain).font(.system(size: 9)).padding(.horizontal, 4).padding(.vertical, 2).background(Color.black.opacity(0.06)).cornerRadius(3)
                                Button("▲") {
                                    var t = transform; t.offsetY -= 8; storage.updateTransform(for: slotIndex, transform: t)
                                }.buttonStyle(.plain).font(.system(size: 9)).padding(.horizontal, 4).padding(.vertical, 2).background(Color.black.opacity(0.06)).cornerRadius(3)
                                Button("▼") {
                                    var t = transform; t.offsetY += 8; storage.updateTransform(for: slotIndex, transform: t)
                                }.buttonStyle(.plain).font(.system(size: 9)).padding(.horizontal, 4).padding(.vertical, 2).background(Color.black.opacity(0.06)).cornerRadius(3)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                storage.resetTransform(for: slotIndex)
                            }) {
                                Text("Reset")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(RoundedRectangle(cornerRadius: 4).fill(Color.orange.opacity(0.12)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.03)))
                    
                    Text("💡 Tips: Foto di bingkai dinding bisa langsung digeser pakai mouse")
                        .font(.system(size: 8.5))
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                    
                    Divider().opacity(0.2)
                    
                    HStack(spacing: 6) {
                        Button(action: {
                            if let url = photoURL {
                                NSWorkspace.shared.open(url)
                            }
                            onClose()
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.forward.app.fill")
                                Text("Preview")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            storage.pickPhoto(forSlot: slotIndex)
                            onClose()
                        }) {
                            Text("Ganti")
                                .font(.system(size: 10, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.06)))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            storage.removePhoto(slotIndex: slotIndex)
                            onClose()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 5)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Text("Bingkai ini belum memiliki foto.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                    
                    Button(action: {
                        storage.pickPhoto(forSlot: slotIndex)
                        onClose()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Pilih Foto...")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - 7. Carpet Item Quick View
public struct CarpetItemQuickView: View {
    let url: URL
    let onClose: () -> Void
    @ObservedObject var storage = StorageManager.shared
    
    public init(url: URL, onClose: @escaping () -> Void = {}) {
        self.url = url
        self.onClose = onClose
    }
    
    private var fileSizeString: String {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
              let size = values.fileSize else {
            return "-"
        }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    private var modDateString: String {
        guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
              let date = values.contentModificationDate else {
            return "-"
        }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
    
    public var body: some View {
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        
        DesktopQuickViewCard(
            title: "File Karpet",
            iconName: "doc.fill",
            iconColor: Color.yellow,
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(url.lastPathComponent)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(NSColor.labelColor))
                            .lineLimit(1)
                        
                        Text("Ukuran: \(fileSizeString) • Diubah: \(modDateString)")
                            .font(.system(size: 9))
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                            .lineLimit(1)
                    }
                }
                
                Divider().opacity(0.2)
                
                HStack(spacing: 6) {
                    Button(action: {
                        NSWorkspace.shared.open(url)
                        onClose()
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.forward.app.fill")
                            Text("Buka File")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        storage.restoreCarpetItemToDesktop(itemURL: url)
                        onClose()
                    }) {
                        Text("Ke Desktop")
                            .font(.system(size: 10, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        storage.openInFinder(url: url)
                        onClose()
                    }) {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("💡 Tips: Klik 2x pada file untuk langsung membukanya")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Fender Stratocaster Quick View Popover
struct GuitarQuickView: View {
    let onClose: () -> Void
    
    var body: some View {
        DesktopQuickViewCard(
            title: "Fender Stratocaster",
            iconName: "guitars.fill",
            iconColor: Color(red: 0.95, green: 0.70, blue: 0.20),
            onClose: onClose
        ) {
            VStack(alignment: .leading, spacing: 10) {
                // Guitar Badge & Specs
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                            .frame(width: 38, height: 38)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        
                        Image(systemName: "music.quarternote.3")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.96, green: 0.84, blue: 0.52))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Stratocaster® Black Gloss")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(NSColor.labelColor))
                        
                        Text("Maple Neck • 3 Single-Coil • Tremolo")
                            .font(.system(size: 9.5))
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                    }
                }
                
                Divider().opacity(0.3)
                
                // Audio / Sound Test Action
                HStack(spacing: 6) {
                    Button(action: {
                        if let sound = NSSound(named: "Funk") {
                            sound.play()
                        } else {
                            NSSound.beep()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Petik Senar (Strum)")
                        }
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(NSColor.labelColor))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        openMusicApp()
                        onClose()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.forward.app.fill")
                            Text("Buka Musik")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.red))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("💡 Tips: Klik 2x pada gitar untuk langsung membuka aplikasi audio / GarageBand")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func openMusicApp() {
        if let gbURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.garageband10") {
            NSWorkspace.shared.openApplication(at: gbURL, configuration: NSWorkspace.OpenConfiguration())
        } else if let musicURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
            NSWorkspace.shared.openApplication(at: musicURL, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Music.app"))
        }
    }
}

// MARK: - 9. Award Plaque Quick View
public struct AwardPlaqueQuickView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let svgFileName: String
    let onClose: () -> Void
    
    public init(title: String, subtitle: String, imageName: String, svgFileName: String, onClose: @escaping () -> Void = {}) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.svgFileName = svgFileName
        self.onClose = onClose
    }
    
    private func getFileURL() -> URL {
        let candidates = [
            "Assets/Logos/\(svgFileName)",
            "Assets/\(svgFileName)",
            svgFileName
        ]
        let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        for rel in candidates {
            let u = currentDir.appendingPathComponent(rel)
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Custom Desktop Mac")
        for rel in candidates {
            let u = homeDir.appendingPathComponent(rel)
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        return currentDir.appendingPathComponent(svgFileName)
    }
    
    private func openVectorFile() {
        let url = getFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.open(url)
        }
        onClose()
    }
    
    private func revealInFinder() {
        let url = getFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
        onClose()
    }
    
    public var body: some View {
        DesktopQuickViewCard(
            title: title,
            iconName: "trophy.fill",
            iconColor: .yellow,
            width: 250,
            onClose: onClose
        ) {
            VStack(spacing: 10) {
                if let img = AssetLoader.image(named: imageName) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 75)
                        .padding(.vertical, 4)
                }
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 8) {
                    Button(action: openVectorFile) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.forward.app.fill")
                            Text("Buka SVG")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: revealInFinder) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                            Text("Finder")
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("💡 Tips: Klik 2x pada plakat untuk langsung membuka file SVG")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .frame(maxWidth: .infinity)
        }
    }
}


