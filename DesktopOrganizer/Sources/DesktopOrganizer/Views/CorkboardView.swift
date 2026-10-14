import SwiftUI

public struct CorkboardView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let boardW = geo.size.width
            let boardH = geo.size.height
            
            ZStack(alignment: .topLeading) {
                // Transparent hit area strictly within corkboard wooden frame
                Color.clear
                    .contentShape(Rectangle())
                
                // Sticky Notes Container
                ForEach($storage.stickyNotes) { $note in
                    StickyNoteCardView(note: $note) {
                        storage.removeStickyNote(id: note.id)
                    } onSave: {
                        storage.saveStickyNotes()
                    }
                    .offset(x: note.x, y: note.y)
                    .rotationEffect(.degrees(note.rotation))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                note.x += value.translation.width
                                note.y += value.translation.height
                                // Clamp within the corkboard area so notes never fly off to wall
                                note.x = max(10, min(note.x, boardW - 160))
                                note.y = max(10, min(note.y, boardH - 120))
                            }
                            .onEnded { _ in
                                storage.saveStickyNotes()
                            }
                    )
                }
                
                // Add Note '+' Button (Neatly pinned inside bottom-right of corkboard)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                storage.addStickyNote()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Memo")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(SANSColors.dark)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(SANSColors.lime)
                                    .overlay(Capsule().stroke(SANSColors.dark.opacity(0.15), lineWidth: 1))
                                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help("Tambah Catatan / To-Do List Baru")
                        .padding(10)
                    }
                }
            }
        }
    }
}

// MARK: - Sticky Note Card View (Clean, Pastel, Self-contained)
public struct StickyNoteCardView: View {
    @Binding var note: StickyNote
    var onDelete: () -> Void
    var onSave: () -> Void
    
    public init(note: Binding<StickyNote>, onDelete: @escaping () -> Void, onSave: @escaping () -> Void) {
        self._note = note
        self.onDelete = onDelete
        self.onSave = onSave
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Pushpin & Title Header
            HStack(spacing: 4) {
                // SANS Pushpin
                Circle()
                    .fill(SANSColors.pink)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0.5, y: 0.5)
                
                TextField("Judul Memo", text: $note.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(note.color.textColor)
                    .textFieldStyle(.plain)
                    .onChange(of: note.title) { _ in onSave() }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.black.opacity(0.3))
                }
                .buttonStyle(.plain)
                .help("Hapus Memo")
            }
            .padding(.horizontal, 6)
            .padding(.top, 5)
            
            Divider()
                .background(Color.black.opacity(0.12))
                .padding(.horizontal, 4)
            
            // Task List
            VStack(alignment: .leading, spacing: 3) {
                ForEach(0..<note.tasks.count, id: \.self) { idx in
                    HStack(spacing: 4) {
                        Button(action: {
                            note.tasks[idx].isCompleted.toggle()
                            onSave()
                        }) {
                            Image(systemName: note.tasks[idx].isCompleted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 9))
                                .foregroundColor(note.tasks[idx].isCompleted ? SANSColors.lime : note.color.textColor.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        .help(note.tasks[idx].isCompleted ? "Tandai Belum Selesai" : "Tandai Selesai")
                        
                        TextField("Tugas...", text: $note.tasks[idx].text)
                            .font(.system(size: 9))
                            .foregroundColor(note.tasks[idx].isCompleted ? note.color.textColor.opacity(0.4) : note.color.textColor)
                            .strikethrough(note.tasks[idx].isCompleted)
                            .textFieldStyle(.plain)
                            .onChange(of: note.tasks[idx].text) { _ in onSave() }
                        
                        if note.tasks.count > 1 {
                            Button(action: {
                                note.tasks.remove(at: idx)
                                onSave()
                            }) {
                                Image(systemName: "minus.circle")
                                    .font(.system(size: 8))
                                    .foregroundColor(.black.opacity(0.25))
                            }
                            .buttonStyle(.plain)
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
                            .font(.system(size: 7))
                        Text("Tambah baris")
                            .font(.system(size: 7))
                    }
                    .foregroundColor(.black.opacity(0.45))
                    .padding(.top, 1)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 5)
        }
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(cardColor)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(SANSColors.dark.opacity(0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 2, x: 1, y: 2)
        )
    }
    
    private var cardColor: Color {
        note.color.background
    }
}
