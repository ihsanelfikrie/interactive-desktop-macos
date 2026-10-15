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
                
                // Bottom Toolbar: Wind Gust & Toggle (Left) + Add Memo (Right)
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        // Breeze Wind Gust Trigger Button
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                appState.lastManualWindGust = Date().timeIntervalSinceReferenceDate
                            }
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "wind")
                                    .font(.system(size: 9, weight: .bold))
                                Text("Tiup 💨")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            .foregroundColor(SANSColors.dark)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.92))
                                    .overlay(Capsule().stroke(SANSColors.dark.opacity(0.15), lineWidth: 1))
                                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help("Tiup angin untuk mengibarkan semua memo!")
                        
                        // Breeze Ambient Toggle Button
                        Button(action: {
                            withAnimation(.spring()) {
                                appState.windBreezeEnabled.toggle()
                            }
                        }) {
                            Image(systemName: appState.windBreezeEnabled ? "fan.fill" : "fan.slash")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(appState.windBreezeEnabled ? SANSColors.primaryBlue : Color.gray)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.92))
                                        .overlay(Circle().stroke(SANSColors.dark.opacity(0.15), lineWidth: 1))
                                        .shadow(color: .black.opacity(0.12), radius: 1, y: 0.5)
                                )
                        }
                        .buttonStyle(.plain)
                        .help(appState.windBreezeEnabled ? "Animasi Angin Aktif (Klik untuk Matikan)" : "Animasi Angin Mati (Klik untuk Aktifkan)")
                        
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

// MARK: - Pin & Fastener Vector Graphics
struct PinIconView: View {
    let style: PinStyle
    let noteColor: NoteColor
    
    var body: some View {
        switch style {
        case .pushpin:
            // 3D Pushpin with metallic highlight and rim
            Circle()
                .fill(pinColor)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 0.8))
                .shadow(color: .black.opacity(0.35), radius: 1, x: 0.5, y: 0.8)
            
        case .washiTape:
            // Decorative semi-transparent masking tape strip
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.white.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 1.5)
                        .stroke(Color.white.opacity(0.95), lineWidth: 0.5)
                )
                .frame(width: 34, height: 9)
                .rotationEffect(.degrees(-1.5))
                .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
            
        case .star:
            // Cute gold star pin
            Image(systemName: "star.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color(red: 255/255.0, green: 215/255.0, blue: 0/255.0))
                .shadow(color: .black.opacity(0.3), radius: 1, y: 0.5)
            
        case .heart:
            // Cute pink heart pin
            Image(systemName: "heart.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(SANSColors.pink)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 0.5)
            
        case .clip:
            // Metallic paperclip
            Image(systemName: "paperclip")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(noteColor.textColor.opacity(0.75))
                .rotationEffect(.degrees(-25))
                .shadow(color: .black.opacity(0.2), radius: 0.5, y: 0.5)
        }
    }
    
    private var pinColor: Color {
        switch noteColor {
        case .pink:
            return SANSColors.lime
        case .lime:
            return SANSColors.pink
        case .blue:
            return Color(red: 255/255.0, green: 220/255.0, blue: 60/255.0)
        case .dark:
            return SANSColors.lime
        default:
            return SANSColors.pink
        }
    }
}

// MARK: - Sticky Note Card View (Aesthetic, Multi-Color, Patterned)
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
            // Header Bar
            HStack(spacing: 4) {
                // Pin / Fastener (Tap to toggle customizer)
                Button(action: toggleCustomizer) {
                    if note.pinStyle != .washiTape {
                        PinIconView(style: note.pinStyle, noteColor: note.color)
                    } else {
                        // Subtle dot indicator in header when washi tape is on top
                        Circle()
                            .fill(note.color.textColor.opacity(0.3))
                            .frame(width: 5, height: 5)
                    }
                }
                .buttonStyle(.plain)
                .help("Klik untuk kustomisasi warna, pin & format")
                
                // Editable Title
                TextField("Judul Memo", text: $note.title)
                    .font(.system(size: 9.5, weight: .bold))
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
                .help("Kustomisasi warna, pin, pola & mode")
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(note.color.textColor.opacity(0.35))
                }
                .buttonStyle(.plain)
                .help("Hapus Memo")
            }
            .padding(.horizontal, 6)
            .padding(.top, 5)
            .padding(.bottom, 4)
            
            Divider()
                .background(note.color.textColor.opacity(0.12))
                .padding(.horizontal, 4)
            
            // Expanded Customization Panel
            if isCustomizerOpen {
                customizationToolbar
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
                Divider()
                    .background(note.color.textColor.opacity(0.12))
                    .padding(.horizontal, 4)
            }
            
            // Note Body: Checklist Mode vs Freeform Text Mode
            if note.mode == .checklist {
                checklistBody
            } else {
                freeformBody
            }
        }
        .frame(width: 148)
        .background(
            ZStack(alignment: .bottomTrailing) {
                // Paper Base Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(note.color.background)
                
                // Paper Pattern Texture Overlay (GeometryReader avoids stretching)
                paperPatternOverlay
                
                // Subtle Paper Border
                RoundedRectangle(cornerRadius: 4)
                    .stroke(note.color.textColor.opacity(0.12), lineWidth: 0.8)
                
                // Cute Paper Dog-Ear Fold at bottom-right corner
                dogEarCorner
            }
        )
        // Washi tape anchored across the top edge if selected
        .overlay(alignment: .top) {
            if note.pinStyle == .washiTape {
                PinIconView(style: .washiTape, noteColor: note.color)
                    .offset(y: -4.5)
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
            
            // Row 2: Pin / Fastener Style Picker
            HStack(spacing: 4) {
                Text("Pin:")
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
            
            // Row 3: Pattern & Mode & Tilt Presets & Done
            HStack(spacing: 3) {
                // Mode Toggle (To-Do vs Teks)
                Button(action: {
                    note.mode = (note.mode == .checklist) ? .freeform : .checklist
                    onSave()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: note.mode == .checklist ? "checklist" : "text.alignleft")
                            .font(.system(size: 6.5))
                        Text(note.mode == .checklist ? "To-Do" : "Teks")
                            .font(.system(size: 6.5, weight: .bold))
                    }
                    .foregroundColor(note.color.textColor)
                    .padding(.horizontal, 3.5)
                    .padding(.vertical, 1.5)
                    .background(
                        Capsule()
                            .fill(note.color.textColor.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .help("Ubah antara Checklist dan Catatan Teks")
                
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
    
    // MARK: - Checklist Body
    private var checklistBody: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(0..<note.tasks.count, id: \.self) { idx in
                HStack(spacing: 4) {
                    Button(action: {
                        note.tasks[idx].isCompleted.toggle()
                        onSave()
                    }) {
                        Image(systemName: note.tasks[idx].isCompleted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 8.5))
                            .foregroundColor(
                                note.tasks[idx].isCompleted ?
                                    (note.color == .lime ? Color(red: 0.1, green: 0.55, blue: 0.2) : SANSColors.lime) :
                                    note.color.textColor.opacity(0.6)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(note.tasks[idx].isCompleted ? "Tandai Belum Selesai" : "Tandai Selesai")
                    
                    TextField("Tugas...", text: $note.tasks[idx].text)
                        .font(.system(size: 8.5))
                        .foregroundColor(note.tasks[idx].isCompleted ? note.color.textColor.opacity(0.38) : note.color.textColor)
                        .strikethrough(note.tasks[idx].isCompleted)
                        .textFieldStyle(.plain)
                        .onChange(of: note.tasks[idx].text) { _ in onSave() }
                    
                    if note.tasks.count > 1 {
                        Button(action: {
                            note.tasks.remove(at: idx)
                            onSave()
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 7.5))
                                .foregroundColor(note.color.textColor.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                        .help("Hapus Baris")
                    }
                }
            }
            
            // Add Task Row Button
            Button(action: {
                note.tasks.append(TaskItem(text: "Tugas baru", isCompleted: false))
                onSave()
            }) {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.system(size: 6.5))
                    Text("Tambah baris")
                        .font(.system(size: 6.5, weight: .semibold))
                }
                .foregroundColor(note.color.textColor.opacity(0.55))
                .padding(.top, 1)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
        .padding(.top, 3)
        .padding(.bottom, 6)
    }
    
    // MARK: - Freeform Text Body
    private var freeformBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            TextField("Ketik catatan bebas di sini...", text: $note.freeformText, axis: .vertical)
                .font(.system(size: 8.5))
                .foregroundColor(note.color.textColor)
                .textFieldStyle(.plain)
                .lineLimit(3...8)
                .onChange(of: note.freeformText) { _ in onSave() }
        }
        .padding(.horizontal, 6)
        .padding(.top, 3)
        .padding(.bottom, 6)
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
    
    var body: some View {
        StickyNoteCardView(note: $note, onDelete: onDelete, onSave: onSave)
            .shadow(color: Color.black.opacity(0.12), radius: 2.5, x: 0.8, y: 2.0)
            .offset(x: note.x + currentOffset.width, y: note.y + currentOffset.height)
            .rotationEffect(.degrees(note.rotation))
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        appState.draggingNoteId = note.id
                        appState.noteDragTranslation = value.translation
                    }
                    .onEnded { value in
                        note.x = max(6, min(note.x + value.translation.width, max(6, boardW - 154)))
                        note.y = max(6, min(note.y + value.translation.height, max(6, boardH - 90)))
                        appState.draggingNoteId = nil
                        appState.noteDragTranslation = .zero
                        onSave()
                    }
            )
    }
}


