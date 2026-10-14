import SwiftUI
import UniformTypeIdentifiers

public struct MagicCarpetView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    let theme: RoomTheme
    
    public init(theme: RoomTheme) {
        self.theme = theme
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Secret compartment underneath carpet when lifted
            if appState.isCarpetLifted {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("Ruang Rahasia di Bawah Karpet (\(storage.carpetItems.count) Item)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        
                        Button(action: {
                            storage.pickCarpetItem()
                        }) {
                            Label("Sembunyikan File", systemImage: "plus")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brown)
                        
                        Button(action: {
                            storage.openInFinder(url: storage.carpetDirectory)
                        }) {
                            Text("Buka Folder")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                appState.isCarpetLifted = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    if storage.carpetItems.isEmpty {
                        Text("Belum ada file yang disembunyikan di bawah karpet.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 14)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(storage.carpetItems, id: \.self) { item in
                                    Button(action: {
                                        storage.openInFinder(url: item)
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: item.hasDirectoryPath ? "folder.fill" : "doc.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(item.hasDirectoryPath ? .yellow : .cyan)
                                            Text(item.lastPathComponent)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .frame(width: 70)
                                        }
                                        .padding(6)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                        }
                    }
                }
                .frame(width: 480, height: 110)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.yellow.opacity(0.6), lineWidth: 1.5)
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                .transition(.scale.combined(with: .opacity))
            }
            
            // The Oval Carpet Body
            ZStack {
                // Carpet base oval
                Ellipse()
                    .fill(carpetColor)
                    .frame(width: 360, height: 80)
                    .overlay(
                        // Golden / decorative border rim
                        Ellipse()
                            .stroke(appState.isCarpetTargeted ? Color.yellow : borderRimColor, lineWidth: appState.isCarpetTargeted ? 4 : 2.5)
                            .frame(width: 346, height: 68)
                    )
                    .overlay(
                        // Center ornamental pattern
                        Ellipse()
                            .stroke(borderRimColor.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 240, height: 42)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 5, y: 4)
                
                // Fringe tassels on sides
                HStack {
                    TasselGroupView()
                    Spacer()
                    TasselGroupView()
                }
                .frame(width: 368)
                
                // Center label / drop cue
                VStack(spacing: 2) {
                    if appState.isCarpetTargeted {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Sembunyikan ke Bawah Karpet")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                    } else {
                        if storage.carpetItems.count > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 10))
                                Text("\(storage.carpetItems.count) item di bawah karpet")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundColor(.white.opacity(0.95))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.black.opacity(0.4)))
                        } else {
                            Text("Magic Carpet (Klik untuk Angkat)")
                                .font(.system(size: 10, weight: .medium, design: .serif))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .scaleEffect(appState.isCarpetLifted ? 0.92 : 1.0)
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    appState.isCarpetLifted.toggle()
                }
            }
            .onDrop(of: [.fileURL], isTargeted: Binding(
                get: { appState.isCarpetTargeted },
                set: { appState.isCarpetTargeted = $0 }
            )) { providers in
                for provider in providers {
                    StorageManager.extractFileURL(from: provider) { url in
                        storage.addCarpetItem(from: url)
                    }
                }
                return true
            }
            .help("Magic Carpet: Tarik file ke sini untuk menyembunyikannya, atau klik untuk membuka!")
        }
    }
    
    private var carpetColor: Color {
        switch theme {
        case .library: return Color(red: 0.52, green: 0.12, blue: 0.18)
        case .kosKosan: return Color(red: 0.18, green: 0.42, blue: 0.68)
        case .taman: return Color(red: 0.82, green: 0.25, blue: 0.25)
        }
    }
    
    private var borderRimColor: Color {
        switch theme {
        case .library: return Color(red: 0.88, green: 0.72, blue: 0.32)
        case .kosKosan: return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .taman: return Color(red: 1.0, green: 0.90, blue: 0.70)
        }
    }
}

struct TasselGroupView: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<5) { _ in
                Rectangle()
                    .fill(Color(red: 0.92, green: 0.82, blue: 0.60))
                    .frame(width: 7, height: 2)
            }
        }
    }
}
