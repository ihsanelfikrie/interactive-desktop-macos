import SwiftUI

public struct CorkboardView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let boardW = geo.size.width
            let boardH = geo.size.height
            
            ZStack(alignment: .topLeading) {
                // Transparent hit area strictly within corkboard wooden frame
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if appState.activeNoteCustomizerId != nil {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                appState.activeNoteCustomizerId = nil
                            }
                        }
                    }
                
                // DEWA 19 Band Sticker (Top-Right of Memo Board)
                Dewa19StickerView()
                    .position(x: boardW - 38, y: 28)
                
                // Top-Center Bismillah Arabic Calligraphy (Sacred Header)
                BismillahCalligraphyHeaderView()
                    .position(x: boardW / 2, y: 22)
                
                // Sticky Notes Container
                ForEach($storage.stickyNotes) { $note in
                    DraggableStickyNote(
                        note: $note,
                        boardW: boardW,
                        boardH: boardH,
                        onDelete: {
                            if appState.activeNoteCustomizerId == note.id {
                                appState.activeNoteCustomizerId = nil
                            }
                            storage.removeStickyNote(id: note.id)
                        },
                        onSave: { storage.saveStickyNotes() }
                    )
                }
                
                // Bottom Toolbar: Add Memo (Right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        // Add Note '+' Button
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                storage.addStickyNote()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Memo")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(SANSColors.dark)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(SANSColors.lime)
                                    .overlay(Capsule().stroke(SANSColors.dark.opacity(0.18), lineWidth: 1))
                                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help("Tambah Catatan / To-Do List Baru")
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
                }
            }
        }
    }
}

// MARK: - Serrated Washi Tape Shape & Fastener Vector Graphics
struct WashiTapeShape: Shape {
    var teethCount: Int = 5
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepY = rect.height / CGFloat(teethCount)
        
        // Start top-left
        path.move(to: CGPoint(x: 2, y: 0))
        // Top edge
        path.addLine(to: CGPoint(x: rect.width - 2, y: 0))
        
        // Right serrated / torn tape edge
        for i in 0..<teethCount {
            let yMid = CGFloat(i) * stepY + stepY * 0.5
            let yEnd = CGFloat(i + 1) * stepY
            path.addLine(to: CGPoint(x: rect.width, y: yMid))
            path.addLine(to: CGPoint(x: rect.width - 2, y: yEnd))
        }
        
        // Bottom edge
        path.addLine(to: CGPoint(x: 2, y: rect.height))
        
        // Left serrated / torn tape edge
        for i in stride(from: teethCount, to: 0, by: -1) {
            let yMid = CGFloat(i) * stepY - stepY * 0.5
            let yEnd = CGFloat(i - 1) * stepY
            path.addLine(to: CGPoint(x: 0, y: yMid))
            path.addLine(to: CGPoint(x: 2, y: yEnd))
        }
        
        path.closeSubpath()
        return path
    }
}

// Realistic Adhesive Tape / Plester
struct WashiTapeView: View {
    var noteColor: NoteColor
    
    var body: some View {
        ZStack {
            // Soft cast shadow on corkboard & paper
            WashiTapeShape()
                .fill(Color.black.opacity(0.18))
                .offset(y: 1.2)
                .blur(radius: 0.8)
            
            // Translucent warm tape strip
            WashiTapeShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.96).opacity(0.85),
                            Color(white: 0.88).opacity(0.70),
                            Color(white: 0.94).opacity(0.80)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Subtle fiber / adhesive sheen line in middle
            Rectangle()
                .fill(Color.white.opacity(0.45))
                .frame(height: 1)
                .padding(.horizontal, 4)
            
            // Subtle border outline for torn edges
            WashiTapeShape()
                .stroke(Color.white.opacity(0.65), lineWidth: 0.6)
        }
        .frame(width: 50, height: 14)
        .rotationEffect(.degrees(-1.5))
    }
}

// 3D Spherical Pushpin
struct PushpinView: View {
    var noteColor: NoteColor
    
    var body: some View {
        ZStack {
            // Pin puncture hole in cork & paper
            Ellipse()
                .fill(Color.black.opacity(0.45))
                .frame(width: 4, height: 2.5)
                .offset(y: 6)
                .blur(radius: 0.4)
            
            // Cast shadow of pin head
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 13, height: 13)
                .offset(x: 0.8, y: 2.2)
                .blur(radius: 1.0)
            
            // Metallic needle base collar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.88), Color(white: 0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 6, height: 6)
                .offset(y: 2)
            
            // 3D Spherical Pin Head
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pinColor.opacity(1.0),
                            pinColor.opacity(0.85),
                            pinColorDark
                        ],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 1,
                        endRadius: 8
                    )
                )
                .frame(width: 13, height: 13)
                .overlay(
                    // Specular Highlight Glare
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 4, height: 3)
                        .offset(x: -2.5, y: -2.5)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.45), lineWidth: 0.6)
                )
        }
        .frame(width: 18, height: 18)
    }
    
    private var pinColor: Color {
        switch noteColor {
        case .lime: return Color(red: 235/255, green: 45/255, blue: 60/255)
        case .yellow: return Color(red: 235/255, green: 45/255, blue: 60/255)
        case .pink: return Color(red: 45/255, green: 130/255, blue: 245/255)
        case .blue: return Color(red: 255/255, green: 215/255, blue: 40/255)
        case .dark: return Color(red: 210/255, green: 240/255, blue: 70/255)
        default: return Color(red: 235/255, green: 45/255, blue: 60/255)
        }
    }
    
    private var pinColorDark: Color {
        switch noteColor {
        case .lime, .yellow: return Color(red: 140/255, green: 15/255, blue: 25/255)
        case .pink: return Color(red: 20/255, green: 65/255, blue: 150/255)
        case .blue: return Color(red: 170/255, green: 120/255, blue: 10/255)
        case .dark: return Color(red: 120/255, green: 150/255, blue: 20/255)
        default: return Color(red: 140/255, green: 15/255, blue: 25/255)
        }
    }
}

struct StarPinView: View {
    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.black.opacity(0.3))
                .offset(y: 1.5)
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 255/255, green: 210/255, blue: 30/255))
                .overlay(
                    Image(systemName: "star")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.6))
                )
        }
        .frame(width: 16, height: 16)
    }
}

struct HeartPinView: View {
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.black.opacity(0.3))
                .offset(y: 1.5)
            Image(systemName: "heart.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(SANSColors.pink)
                .overlay(
                    Image(systemName: "heart")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.5))
                )
        }
        .frame(width: 16, height: 16)
    }
}

struct ClipFastenerView: View {
    var noteColor: NoteColor
    var body: some View {
        ZStack {
            Image(systemName: "paperclip")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color.black.opacity(0.28))
                .offset(y: 1.2)
            Image(systemName: "paperclip")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(white: 0.88))
                .overlay(
                    Image(systemName: "paperclip")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.4))
                )
        }
        .frame(width: 16, height: 18)
    }
}

// Master Top Fastener Component
struct TopFastenerView: View {
    let style: PinStyle
    let noteColor: NoteColor
    
    var body: some View {
        switch style {
        case .washiTape:
            WashiTapeView(noteColor: noteColor)
        case .pushpin:
            PushpinView(noteColor: noteColor)
        case .star:
            StarPinView()
        case .heart:
            HeartPinView()
        case .clip:
            ClipFastenerView(noteColor: noteColor)
        }
    }
}

// MARK: - Sticky Note Card View (Title Directly Followed by Content)
public struct StickyNoteCardView: View {
    @Binding var note: StickyNote
    var onDelete: () -> Void
    var onSave: () -> Void
    
    @ObservedObject var appState = AppState.shared
    
    var isCustomizerOpen: Bool {
        appState.activeNoteCustomizerId == note.id
    }
    
    public init(note: Binding<StickyNote>, onDelete: @escaping () -> Void, onSave: @escaping () -> Void) {
        self._note = note
        self.onDelete = onDelete
        self.onSave = onSave
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Bar: Editable Title & Controls
            HStack(spacing: 4) {
                // Editable Title
                TextField("Judul Memo", text: $note.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(note.color.textColor)
                    .textFieldStyle(.plain)
                    .onChange(of: note.title) { _ in onSave() }
                
                Spacer()
                
                // Palette Customizer Toggle Button
                Button(action: toggleCustomizer) {
                    Image(systemName: isCustomizerOpen ? "paintpalette.fill" : "paintpalette")
                        .font(.system(size: 8.5))
                        .foregroundColor(note.color.textColor.opacity(isCustomizerOpen ? 0.95 : 0.45))
                }
                .buttonStyle(.plain)
                .help("Kustomisasi warna, plester/pin & pola kertas")
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(note.color.textColor.opacity(0.35))
                }
                .buttonStyle(.plain)
                .help("Hapus Memo")
            }
            .padding(.horizontal, 7)
            .padding(.top, 9)
            .padding(.bottom, 3)
            
            Divider()
                .background(note.color.textColor.opacity(0.14))
                .padding(.horizontal, 5)
            
            // Expanded Customization Panel
            if isCustomizerOpen {
                customizationToolbar
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
                Divider()
                    .background(note.color.textColor.opacity(0.14))
                    .padding(.horizontal, 5)
            }
            
            // Note Body: Judul langsung isinya (Multi-line freeform text)
            VStack(alignment: .leading, spacing: 2) {
                TextField("Tulis isi memo di sini...", text: $note.freeformText, axis: .vertical)
                    .font(.system(size: 8.5))
                    .foregroundColor(note.color.textColor.opacity(0.92))
                    .textFieldStyle(.plain)
                    .lineLimit(3...14)
                    .onChange(of: note.freeformText) { _ in onSave() }
            }
            .padding(.horizontal, 7)
            .padding(.top, 4)
            .padding(.bottom, 7)
        }
        .frame(width: 148)
        .background(
            ZStack(alignment: .bottomTrailing) {
                // Paper Base Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(note.color.background)
                
                // Paper Pattern Texture Overlay (Ruled Lines or Dot Grid)
                paperPatternOverlay
                
                // Subtle Paper Border
                RoundedRectangle(cornerRadius: 4)
                    .stroke(note.color.textColor.opacity(0.12), lineWidth: 0.8)
                
                // Cute Paper Dog-Ear Fold at bottom-right corner
                dogEarCorner
            }
        )
        // Fastener (Plester atau Pin) physically holding the memo on the corkboard
        .overlay(alignment: .top) {
            TopFastenerView(style: note.pinStyle, noteColor: note.color)
                .offset(y: -7)
                .onTapGesture {
                    toggleCustomizer()
                }
        }
    }
    
    private func toggleCustomizer() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            if appState.activeNoteCustomizerId == note.id {
                appState.activeNoteCustomizerId = nil
            } else {
                appState.activeNoteCustomizerId = note.id
            }
        }
    }
    
    // MARK: - Customization Panel Drawer
    private var customizationToolbar: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Row 1: Color Palette Swatches
            HStack(spacing: 3.5) {
                ForEach([NoteColor.lime, .pink, .yellow, .mint, .lavender, .peach, .blue, .white, .dark], id: \.self) { c in
                    Button(action: {
                        note.color = c
                        onSave()
                    }) {
                        Circle()
                            .fill(c.background)
                            .frame(width: 10.5, height: 10.5)
                            .overlay(
                                Circle()
                                    .stroke(
                                        note.color == c ? Color.white : Color.black.opacity(0.18),
                                        lineWidth: note.color == c ? 1.5 : 0.6
                                    )
                            )
                            .shadow(color: .black.opacity(note.color == c ? 0.35 : 0.08), radius: 1)
                    }
                    .buttonStyle(.plain)
                    .help("Warna \(c.displayName)")
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, 4)
            
            // Row 2: Pin / Fastener Style Picker (Plester vs Pin)
            HStack(spacing: 4) {
                Text("Tempelan:")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(note.color.textColor.opacity(0.6))
                
                ForEach(PinStyle.allCases, id: \.self) { style in
                    Button(action: {
                        note.pinStyle = style
                        onSave()
                    }) {
                        Text(style.displayName)
                            .font(.system(size: 6.5, weight: note.pinStyle == style ? .bold : .medium))
                            .foregroundColor(note.color.textColor.opacity(note.pinStyle == style ? 1.0 : 0.55))
                            .padding(.horizontal, 2.5)
                            .padding(.vertical, 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(note.color.textColor.opacity(note.pinStyle == style ? 0.12 : 0.0))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            
            // Row 3: Pattern & Tilt Presets & Done
            HStack(spacing: 3) {
                // Pattern Toggle (Polos -> Garis -> Titik)
                Button(action: {
                    switch note.pattern {
                    case .plain: note.pattern = .lined
                    case .lined: note.pattern = .dots
                    case .dots:  note.pattern = .plain
                    }
                    onSave()
                }) {
                    Text(note.pattern.displayName)
                        .font(.system(size: 6.5, weight: .bold))
                        .foregroundColor(note.color.textColor)
                        .padding(.horizontal, 3.5)
                        .padding(.vertical, 1.5)
                        .background(
                            Capsule()
                                .fill(note.color.textColor.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
                .help("Pola Kertas: Polos, Garis, atau Titik")
                
                // Tilt Presets (-4°, 0°, +4°)
                ForEach([-4.0, 0.0, 4.0], id: \.self) { deg in
                    Button(action: {
                        withAnimation(.spring()) {
                            note.rotation = deg
                            onSave()
                        }
                    }) {
                        Text(deg == 0.0 ? "0°" : (deg < 0 ? "-4°" : "+4°"))
                            .font(.system(size: 6, weight: abs(note.rotation - deg) < 0.5 ? .bold : .regular))
                            .foregroundColor(note.color.textColor.opacity(abs(note.rotation - deg) < 0.5 ? 1.0 : 0.45))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Done / Close button
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        appState.activeNoteCustomizerId = nil
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(note.color.textColor.opacity(0.75))
                }
                .buttonStyle(.plain)
                .help("Tutup Kustomisasi")
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 4)
        }
        .background(note.color.textColor.opacity(0.05))
    }
    
    // MARK: - Paper Texture Overlay (Ruled Lines & Dot Grid via GeometryReader)
    @ViewBuilder
    private var paperPatternOverlay: some View {
        GeometryReader { geo in
            let h = geo.size.height
            switch note.pattern {
            case .plain:
                EmptyView()
            case .lined:
                VStack(spacing: 12) {
                    let lineCount = max(2, Int((h - 26) / 12))
                    ForEach(0..<lineCount, id: \.self) { _ in
                        Divider()
                            .background(note.color.textColor.opacity(0.09))
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
            case .dots:
                let rowCount = max(2, Int((h - 26) / 10))
                VStack(spacing: 10) {
                    ForEach(0..<rowCount, id: \.self) { _ in
                        HStack(spacing: 11) {
                            ForEach(0..<10, id: \.self) { _ in
                                Circle()
                                    .fill(note.color.textColor.opacity(0.12))
                                    .frame(width: 1.2, height: 1.2)
                            }
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 6)
            }
        }
        .allowsHitTesting(false)
        .clipped()
    }
    
    // MARK: - Dog-Ear Paper Corner
    private var dogEarCorner: some View {
        Path { path in
            path.move(to: CGPoint(x: 10, y: 10))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: 10, y: 0))
            path.closeSubpath()
        }
        .fill(note.color.textColor.opacity(0.08))
        .frame(width: 10, height: 10)
        .allowsHitTesting(false)
    }
}

// MARK: - Native Arabic Bismillah Calligraphy Header
struct BismillahCalligraphyHeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            // Left ornamental filigree accent
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color(red: 0.65, green: 0.52, blue: 0.35).opacity(0.40)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24, height: 1)
            
            // Sacred Calligraphy Ligature (Geeza Pro / Native macOS Arabic Typography)
            Text("﷽")
                .font(.custom("Geeza Pro", size: 24).weight(.medium))
                .foregroundColor(Color(red: 0.24, green: 0.15, blue: 0.09))
                .shadow(color: Color.black.opacity(0.18), radius: 0.8, x: 0, y: 1.0)
            
            // Right ornamental filigree accent
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.65, green: 0.52, blue: 0.35).opacity(0.40), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24, height: 1)
        }
        .help("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ — Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang")
        .allowsHitTesting(false)
    }
}

// MARK: - Draggable Sticky Note Wrapper
struct DraggableStickyNote: View {
    @Binding var note: StickyNote
    let boardW: CGFloat
    let boardH: CGFloat
    let onDelete: () -> Void
    let onSave: () -> Void
    
    @ObservedObject var appState = AppState.shared
    
    var currentOffset: CGSize {
        appState.draggingNoteId == note.id ? appState.noteDragTranslation : .zero
    }
    
    // Calligraphy Protected Zone Bounds (Top Center of Corkboard)
    private var zoneMinX: CGFloat { (boardW / 2) - 95 }
    private var zoneMaxX: CGFloat { (boardW / 2) + 95 }
    private let zoneBottom: CGFloat = 48
    private let noteW: CGFloat = 148
    
    // Enforce exclusion zone during rendering & live dragging
    private var safeX: CGFloat {
        let rawX = note.x + currentOffset.width
        return max(6, min(rawX, max(6, boardW - 154)))
    }
    
    private var safeY: CGFloat {
        let rawY = note.y + currentOffset.height
        let boundedY = max(6, min(rawY, max(6, boardH - 90)))
        // If note overlaps the calligraphy zone horizontally, prevent it from entering vertically
        if (safeX + noteW > zoneMinX) && (safeX < zoneMaxX) {
            return max(boundedY, zoneBottom)
        }
        return boundedY
    }
    
    var body: some View {
        StickyNoteCardView(note: $note, onDelete: onDelete, onSave: onSave)
            .shadow(color: Color.black.opacity(0.12), radius: 2.5, x: 0.8, y: 2.0)
            .offset(x: safeX, y: safeY)
            .rotationEffect(.degrees(note.rotation))
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        appState.draggingNoteId = note.id
                        appState.noteDragTranslation = value.translation
                    }
                    .onEnded { value in
                        note.x = safeX
                        note.y = safeY
                        appState.draggingNoteId = nil
                        appState.noteDragTranslation = .zero
                        onSave()
                    }
            )
    }
}


