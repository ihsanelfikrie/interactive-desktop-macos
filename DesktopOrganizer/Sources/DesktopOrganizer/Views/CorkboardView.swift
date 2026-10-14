import SwiftUI

public struct CorkboardView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Transparent hit area for the wall corkboard zone
            Color.clear
            
            // Pinned Sticky Notes
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
                        }
                        .onEnded { _ in
                            storage.saveStickyNotes()
                        }
                )
            }
            
            // Add Note '+' Button (Floating at bottom-right of corkboard wall)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            storage.addStickyNote()
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Tambah Memo")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.08))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.98, green: 0.82, blue: 0.28))
                                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Tambah Memo / Tugas Baru ke Dinding")
                    .padding(8)
                }
            }
        }
    }
}

// MARK: - Sticky Note Card View
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
        VStack(alignment: .leading, spacing: 4) {
            // Pushpin & Header
            HStack {
                // Little red pushpin
                Circle()
                    .fill(Color(red: 0.85, green: 0.20, blue: 0.20))
                    .frame(width: 8, height: 8)
                    .shadow(color: .black.opacity(0.4), radius: 1.5, x: 1, y: 1)
                
                TextField("Judul Memo", text: $note.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.85))
                    .textFieldStyle(.plain)
                    .onChange(of: note.title) { _ in onSave() }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.black.opacity(0.35))
                }
                .buttonStyle(.plain)
                .help("Hapus Memo")
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)
            
            Divider()
                .background(Color.black.opacity(0.12))
                .padding(.horizontal, 4)
            
            // Task List
            VStack(alignment: .leading, spacing: 3) {
                ForEach(0..<note.tasks.count, id: \.self) { idx in
                    HStack(spacing: 5) {
                        Button(action: {
                            note.tasks[idx].isCompleted.toggle()
                            onSave()
                        }) {
                            Image(systemName: note.tasks[idx].isCompleted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 10))
                                .foregroundColor(note.tasks[idx].isCompleted ? .green : .black.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .help(note.tasks[idx].isCompleted ? "Tandai Belum Selesai" : "Tandai Selesai")
                        
                        TextField("Tugas...", text: $note.tasks[idx].text)
                            .font(.system(size: 10))
                            .foregroundColor(note.tasks[idx].isCompleted ? .black.opacity(0.4) : .black.opacity(0.85))
                            .strikethrough(note.tasks[idx].isCompleted)
                            .textFieldStyle(.plain)
                            .onChange(of: note.tasks[idx].text) { _ in onSave() }
                        
                        if note.tasks.count > 1 {
                            Button(action: {
                                note.tasks.remove(at: idx)
                                onSave()
                            }) {
                                Image(systemName: "minus.circle")
                                    .font(.system(size: 9))
                                    .foregroundColor(.black.opacity(0.25))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Quick add task button
                Button(action: {
                    note.tasks.append(TaskItem(text: "Tugas baru", isCompleted: false))
                    onSave()
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 8))
                        Text("Tambah baris")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(.black.opacity(0.45))
                    .padding(.top, 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(cardColor)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 2, y: 3)
        )
    }
    
    private var cardColor: Color {
        note.color.background
    }
}
