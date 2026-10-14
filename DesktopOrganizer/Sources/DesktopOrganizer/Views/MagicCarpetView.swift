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
        ZStack {
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
                            storage.openInFinder(url: storage.carpetDirectory)
                        }) {
                            Text("Buka Folder")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brown)
                        
                        Button(action: { appState.isCarpetLifted = false }) {
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
                            .padding(.vertical, 20)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(storage.carpetItems, id: \.self) { item in
                                    Button(action: {
                                        storage.openInFinder(url: item)
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: item.hasDirectoryPath ? "folder.fill" : "doc.fill")
                                                .font(.system(size: 26))
                                                .foregroundColor(item.hasDirectoryPath ? .yellow : .cyan)
                                            Text(item.lastPathComponent)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .frame(width: 70)
                                        }
                                        .padding(6)
                                        .background(Color.white.opacity(0.12))
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
                .frame(width: 480, height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.6), lineWidth: 1.5)
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                .offset(y: -40)
                .transition(.scale.combined(with: .opacity))
            }
            
            // The Oval Carpet Body
            Button(action: {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    appState.isCarpetLifted.toggle()
                }
            }) {
                ZStack {
                    // Carpet base oval
                    Ellipse()
                        .fill(carpetColor)
                        .frame(width: 380, height: 110)
                        .overlay(
                            // Golden / decorative border rim
                            Ellipse()
                                .stroke(appState.isCarpetTargeted ? Color.yellow : borderRimColor, lineWidth: appState.isCarpetTargeted ? 4 : 3)
                                .frame(width: 366, height: 96)
                        )
                        .overlay(
                            // Center ornamental pattern
                            Ellipse()
                                .stroke(borderRimColor.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 260, height: 60)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 6, y: 5)
                    
                    // Fringe tassels on sides
                    HStack {
                        TasselGroupView()
                        Spacer()
                        TasselGroupView()
                    }
                    .frame(width: 390)
                    
                    // Center label / drop cue
                    VStack(spacing: 3) {
                        if appState.isCarpetTargeted {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Sembunyikan ke Bawah Karpet")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.yellow)
                        } else {
                            if storage.carpetItems.count > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 11))
                                    Text("\(storage.carpetItems.count) item di bawah karpet")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.black.opacity(0.35)))
                            } else {
                                Text("Magic Carpet")
                                    .font(.system(size: 11, weight: .medium, design: .serif))
                                    .foregroundColor(.white.opacity(0.55))
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(appState.isCarpetLifted ? 0.88 : 1.0)
            .offset(y: appState.isCarpetLifted ? 30 : 0)
            .onDrop(of: [.fileURL], isTargeted: Binding(
                get: { appState.isCarpetTargeted },
                set: { appState.isCarpetTargeted = $0 }
            )) { providers in
                for provider in providers {
                    _ = provider.loadObject(ofClass: URL.self) { url, _ in
                        if let url = url {
                            DispatchQueue.main.async {
                                storage.addCarpetItem(from: url)
                            }
                        }
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
        VStack(spacing: 4) {
            ForEach(0..<6) { _ in
                Rectangle()
                    .fill(Color(red: 0.92, green: 0.82, blue: 0.60))
                    .frame(width: 8, height: 2)
            }
        }
    }
}
