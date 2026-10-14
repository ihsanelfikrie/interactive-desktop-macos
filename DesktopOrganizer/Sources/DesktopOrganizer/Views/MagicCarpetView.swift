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
                        
                        if !storage.carpetItems.isEmpty {
                            Button(action: {
                                storage.restoreAllCarpetItems()
                            }) {
                                Text("Kembalikan Semua ke Desktop")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.bordered)
                        }
                        
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
                                    ZStack(alignment: .topTrailing) {
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
                                        
                                        // Quick restore button to return file back to Desktop
                                        Button(action: {
                                            storage.restoreCarpetItemToDesktop(itemURL: item)
                                        }) {
                                            Image(systemName: "arrow.up.forward.app.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(.yellow)
                                                .background(Circle().fill(Color.black))
                                        }
                                        .buttonStyle(.plain)
                                        .offset(x: 4, y: -4)
                                        .help("Kembalikan file ini ke Desktop")
                                    }
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
            
            // The Rug / Mat / Dirt Patch Body
            ZStack {
                if let matImg = AssetLoader.image(named: theme.matImageName) {
                    Image(nsImage: matImg)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 380, height: 95)
                        .shadow(color: .black.opacity(0.35), radius: 5, y: 4)
                } else {
                    proceduralMat
                }
                
                // Visible lump or pile if items are hidden underneath!
                if storage.carpetItems.count == 1 {
                    if let lumpImg = AssetLoader.image(named: theme.lumpImageName) {
                        Image(nsImage: lumpImg)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 44, height: 26)
                            .offset(x: 20, y: -8)
                            .transition(.scale)
                    }
                } else if storage.carpetItems.count > 1 {
                    if let pileImg = AssetLoader.image(named: theme.pileImageName) {
                        Image(nsImage: pileImg)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 65, height: 45)
                            .offset(x: 25, y: -12)
                            .transition(.scale)
                    }
                }
                
                // Drop or count indicator
                VStack(spacing: 2) {
                    if appState.isCarpetTargeted {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Sembunyikan ke Bawah Karpet")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Capsule().fill(Color.black.opacity(0.65)))
                    } else if storage.carpetItems.count > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 10))
                            Text("\(storage.carpetItems.count) file tersembunyi")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.black.opacity(0.55)))
                    }
                }
            }
            .contentShape(Rectangle())
            .scaleEffect(appState.isCarpetLifted ? 0.95 : 1.0)
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
            .help("geser untuk membukanya, klik untuk mengintip. Ke atas file di desktop untuk menyembunyikannya.")
        }
    }
    
    private var proceduralMat: some View {
        ZStack {
            Ellipse()
                .fill(carpetColor)
                .frame(width: 360, height: 80)
                .overlay(
                    Ellipse()
                        .stroke(appState.isCarpetTargeted ? Color.yellow : borderRimColor, lineWidth: appState.isCarpetTargeted ? 4 : 2.5)
                        .frame(width: 346, height: 68)
                )
                .shadow(color: .black.opacity(0.35), radius: 5, y: 4)
            
            HStack {
                TasselGroupView()
                Spacer()
                TasselGroupView()
            }
            .frame(width: 368)
        }
    }
    
    private var carpetColor: Color {
        SANSColors.pink
    }
    
    private var borderRimColor: Color {
        SANSColors.lime
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
