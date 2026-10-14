import SwiftUI

public struct CorkboardView: View {
    @ObservedObject var storage = StorageManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Wooden outer frame
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.42, green: 0.26, blue: 0.15))
                .shadow(color: .black.opacity(0.35), radius: 6, x: 2, y: 4)
            
            // Corkboard surface
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.77, green: 0.60, blue: 0.42))
                .overlay(
                    // Subtle cork texture dots
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.04))
                            .frame(width: 4, height: 4)
                            .offset(x: -80, y: -40)
                        Circle()
                            .fill(Color.black.opacity(0.04))
                            .frame(width: 6, height: 6)
                            .offset(x: 100, y: 30)
                        Circle()
                            .fill(Color.black.opacity(0.04))
                            .frame(width: 5, height: 5)
                            .offset(x: 40, y: -70)
                    }
                )
                .padding(10)
            
            // Pushpins at four corners of the frame
            ZStack {
                Circle().fill(Color(red: 0.85, green: 0.70, blue: 0.20)).frame(width: 10, height: 10).offset(x: 16, y: 16)
                Circle().fill(Color(red: 0.85, green: 0.70, blue: 0.20)).frame(width: 10, height: 10).offset(x: 414, y: 16)
                Circle().fill(Color(red: 0.85, green: 0.70, blue: 0.20)).frame(width: 10, height: 10).offset(x: 16, y: 254)
                Circle().fill(Color(red: 0.85, green: 0.70, blue: 0.20)).frame(width: 10, height: 10).offset(x: 414, y: 254)
            }
            
            // Sticky Notes Container
            ZStack(alignment: .topLeading) {
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
                                // clamp within board boundaries
                                note.x = max(15, min(note.x, 260))
                                note.y = max(15, min(note.y, 110))
                            }
                            .onEnded { _ in
                                storage.saveStickyNotes()
                            }
                    )
                }
            }
            .frame(width: 440, height: 280)
            
            // Add Note '+' button on bottom right corner of corkboard
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            storage.addStickyNote()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.98, green: 0.80, blue: 0.25))
                                .frame(width: 34, height: 34)
                                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.10))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(18)
                    .help("Tambah Catatan Baru")
                }
            }
        }
        .frame(width: 440, height: 280)
    }
}

// MARK: - Individual Sticky Note Card
struct StickyNoteCardView: View {
    @ObservedObject var appState = AppState.shared
    @Binding var note: StickyNote
    var onDelete: () -> Void
    var onSave: () -> Void
    
    var isAddingTask: Bool {
        appState.addingTaskForNoteId == note.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Pin icon & Header bar
            HStack {
                // Red thumbtack
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                
                TextField("Judul Catatan", text: $note.title)
                    .font(.system(size: 12, weight: .bold))
                    .textFieldStyle(.plain)
                    .onChange(of: note.title) { _ in onSave() }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 2)
            
            Divider()
                .background(Color.black.opacity(0.1))
                .padding(.horizontal, 6)
            
            // Tasks list
            VStack(alignment: .leading, spacing: 4) {
                ForEach($note.tasks) { $task in
                    HStack(spacing: 6) {
                        Button(action: {
                            task.isCompleted.toggle()
                            onSave()
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 12))
                                .foregroundColor(task.isCompleted ? .green : .black.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        
                        TextField("Tugas", text: $task.text)
                            .font(.system(size: 11))
                            .textFieldStyle(.plain)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                            .onChange(of: task.text) { _ in onSave() }
                        
                        Button(action: {
                            note.tasks.removeAll(where: { $0.id == task.id })
                            onSave()
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 10))
                                .foregroundColor(.red.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                if isAddingTask {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.dashed")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        TextField("Ketik to-do baru...", text: Binding(
                            get: { appState.newTaskText },
                            set: { appState.newTaskText = $0 }
                        ))
                        .font(.system(size: 11))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            let trimmed = appState.newTaskText.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                note.tasks.append(TaskItem(text: trimmed))
                                appState.newTaskText = ""
                                appState.addingTaskForNoteId = nil
                                onSave()
                            }
                        }
                    }
                }
                
                Button(action: {
                    appState.newTaskText = ""
                    appState.addingTaskForNoteId = note.id
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 9))
                        Text("Tambah to-do")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.blue.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 175)
        .background(note.color.background)
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 3)
    }
}
