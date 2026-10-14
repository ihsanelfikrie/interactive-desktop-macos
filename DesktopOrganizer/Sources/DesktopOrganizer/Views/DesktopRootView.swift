import SwiftUI
import AppKit

public struct DesktopRootView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack(alignment: .bottom) {
                // 1. Theme Background (Wall & Floor)
                ThemeBackgroundView(theme: appState.currentTheme, isNightMode: appState.isNightMode)
                    .frame(width: w, height: h)
                
                // 2. Main Furniture & Wall Elements Layer
                HStack(alignment: .bottom, spacing: 0) {
                    // LEFT: Bookshelf & Floor Plant
                    VStack(alignment: .leading, spacing: 8) {
                        Spacer()
                        BookshelfView(theme: appState.currentTheme)
                            .padding(.leading, 32)
                        
                        // Potted houseplant on the floor
                        HousePlantView()
                            .padding(.leading, 40)
                            .padding(.bottom, 24)
                    }
                    
                    Spacer()
                    
                    // CENTER: Corkboard (Memo Board) & Desk
                    VStack(spacing: 16) {
                        Spacer()
                        
                        // Corkboard (Sticky Notes)
                        CorkboardView()
                            .padding(.bottom, -10)
                        
                        // Desk with Lamp, Radio, Clock, Calendar, Mail
                        DeskView(
                            theme: appState.currentTheme,
                            isNightMode: Binding(
                                get: { appState.isNightMode },
                                set: { appState.isNightMode = $0 }
                            ),
                            showSpotifyPopup: Binding(
                                get: { appState.showSpotifyPopup },
                                set: { appState.showSpotifyPopup = $0 }
                            )
                        )
                        .padding(.bottom, 38)
                    }
                    
                    Spacer()
                    
                    // RIGHT: Photo Gallery
                    VStack {
                        Spacer()
                        PhotoGalleryView()
                            .padding(.trailing, 36)
                            .padding(.bottom, 120)
                    }
                }
                .frame(width: w, height: h)
                
                // 3. Floor Layer: Magic Carpet & Trash Can
                HStack(alignment: .bottom, spacing: 30) {
                    Spacer()
                    
                    // Magic Carpet in front of desk
                    MagicCarpetView(theme: appState.currentTheme)
                        .offset(x: -20, y: -16)
                    
                    // Trash Can next to desk
                    TrashCanView()
                        .offset(x: 20, y: -42)
                    
                    Spacer()
                }
                .frame(width: w)
                
                // 4. Spotify Mini Player Popup
                if appState.showSpotifyPopup {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            SpotifyMiniPlayerView(isPresented: Binding(
                                get: { appState.showSpotifyPopup },
                                set: { appState.showSpotifyPopup = $0 }
                            ))
                            .offset(x: 100, y: -260)
                            Spacer()
                        }
                    }
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
                
                // 5. Cozy Night Mode Ambient Dark Overlay
                if appState.isNightMode {
                    Color.black.opacity(0.68)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
                
                // 6. Top Control Pill Bar
                VStack {
                    HStack(spacing: 8) {
                        // Theme Switcher Button
                        ControlButton(title: "Tema Ruangan", icon: "paintpalette.fill") {
                            appState.showThemePicker = true
                        }
                        
                        // Lamp / Night Mode Toggle
                        ControlButton(title: appState.isNightMode ? "Nyalakan Lampu" : "Mode Malam", icon: appState.isNightMode ? "sun.max.fill" : "moon.stars.fill") {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                appState.isNightMode.toggle()
                            }
                        }
                        
                        // Toggle Native Mac Desktop Icons
                        ControlButton(
                            title: storage.areDesktopIconsHidden ? "Tampilkan Ikon Mac" : "Sembunyikan Ikon Mac",
                            icon: storage.areDesktopIconsHidden ? "eye.fill" : "eye.slash.fill"
                        ) {
                            storage.toggleNativeDesktopIcons()
                        }
                        
                        // Open Organizer Folder in Finder
                        ControlButton(title: "Folder Penyimpanan", icon: "folder.fill") {
                            storage.openBaseFolder()
                        }
                        
                        // Help / Guide
                        ControlButton(title: "Panduan", icon: "questionmark.circle.fill") {
                            appState.showHelpModal = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(NSColor.windowBackgroundColor).opacity(0.92))
                            .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
                    )
                    .padding(.top, 14)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { appState.showThemePicker },
            set: { appState.showThemePicker = $0 }
        )) {
            ThemePickerView(
                currentTheme: Binding(
                    get: { appState.currentTheme },
                    set: { appState.currentTheme = $0 }
                ),
                isPresented: Binding(
                    get: { appState.showThemePicker },
                    set: { appState.showThemePicker = $0 }
                )
            )
        }
        .sheet(isPresented: Binding(
            get: { appState.showHelpModal },
            set: { appState.showHelpModal = $0 }
        )) {
            HelpGuideModalView(isPresented: Binding(
                get: { appState.showHelpModal },
                set: { appState.showHelpModal = $0 }
            ))
        }
    }
}

// MARK: - Control Button in Top Bar
struct ControlButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Potted Floor Houseplant
struct HousePlantView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Big leafy monstera leaves
            ZStack {
                LeafShape()
                    .fill(Color(red: 0.18, green: 0.52, blue: 0.28))
                    .frame(width: 32, height: 48)
                    .rotationEffect(.degrees(-35))
                    .offset(x: -16, y: -8)
                
                LeafShape()
                    .fill(Color(red: 0.22, green: 0.60, blue: 0.32))
                    .frame(width: 34, height: 52)
                    .rotationEffect(.degrees(30))
                    .offset(x: 16, y: -10)
                
                LeafShape()
                    .fill(Color(red: 0.15, green: 0.45, blue: 0.22))
                    .frame(width: 30, height: 46)
                    .offset(y: -14)
            }
            
            // Terracotta pot
            Path { path in
                path.move(to: CGPoint(x: 4, y: 0))
                path.addLine(to: CGPoint(x: 8, y: 34))
                path.addLine(to: CGPoint(x: 32, y: 34))
                path.addLine(to: CGPoint(x: 36, y: 0))
                path.closeSubpath()
            }
            .fill(Color(red: 0.82, green: 0.42, blue: 0.25))
            .frame(width: 40, height: 34)
            .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
        }
        .frame(width: 70, height: 90)
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX - 4, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX + 4, y: rect.midY))
        return path
    }
}

// MARK: - Help Guide Modal
struct HelpGuideModalView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Panduan Fitur Desktop Organizer")
                    .font(.title2.bold())
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GuideRow(icon: "photo.stack.fill", color: .purple, title: "Bingkai Foto di Dinding Kanan", desc: "Tarik & letakkan (drag & drop) gambar dari Finder ke salah satu bingkai foto untuk memasangnya.")
                    GuideRow(icon: "books.vertical.fill", color: .brown, title: "Rak Buku File & Folder Organizer", desc: "Tarik file/folder ke rak buku sebelah kiri. Klik rak buku untuk melihatnya dalam bentuk deretan buku bersampul judul!")
                    GuideRow(icon: "oval.inset.filled", color: .red, title: "Magic Carpet (Sembunyikan File)", desc: "Tarik file berantakan ke karpet oval di lantai untuk menyembunyikannya. Klik karpet untuk mengangkat dan membukanya.")
                    GuideRow(icon: "note.text", color: .orange, title: "Memo Board / Papan Sticky Notes", desc: "Catat to-do list harian di tengah. Tekan tombol '+' untuk menambah catatan baru, geser-geser note, dan beri centang tugas.")
                    GuideRow(icon: "calendar", color: .red, title: "Kalender & Jam Dinding", desc: "Menampilkan tanggal dan jam sistem secara realtime. Klik kalender untuk membuka aplikasi Kalender macOS.")
                    GuideRow(icon: "lightbulb.fill", color: .yellow, title: "Lampu Meja (Mode Malam)", desc: "Klik lampu meja belajar untuk mematikan/menyalakan lampu dan meredupkan suasana ruangan.")
                    GuideRow(icon: "radio.fill", color: .green, title: "Radio Vintage & Spotify", desc: "Klik radio di meja untuk membuka mini player Spotify, melihat lagu yang sedang diputar, dan mengontrol musik.")
                    GuideRow(icon: "trash.fill", color: .gray, title: "Tempat Sampah", desc: "Tarik file yang ingin kamu buang langsung ke tempat sampah di samping meja.")
                }
                .padding(.vertical, 8)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Tutup") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 580, height: 480)
    }
}

struct GuideRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}
