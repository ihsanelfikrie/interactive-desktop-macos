import SwiftUI
import AppKit

public struct DesktopRootView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let bookshelfW = w * 0.2444
            let bookshelfH = h * 0.2860
            let bookshelfX = w * 0.1678
            let bookshelfY = h * 0.3705
            
            ZStack(alignment: .topLeading) {
                // 1. Pixel Art Room Background (100% full screen)
                ThemeBackgroundView(theme: appState.currentTheme, isNightMode: !appState.lampOn)
                    .frame(width: w, height: h)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !FloorInteractionState.shared.selectedFileNames.isEmpty {
                            FloorInteractionState.shared.clearSelection()
                        }
                    }
                
                // 2. Interactive Hot Zones (Mapped 1:1 onto the illustrated furniture)
                
                // Wall Shelf (Left Wall: centered in left wall boiserie panel)
                BookshelfView(theme: appState.currentTheme)
                    .frame(width: bookshelfW, height: bookshelfH)
                    .position(x: bookshelfX, y: bookshelfY)
                
                // Live Modern Architectural Wall Clock & Official Presidential Portraits (Mounted above Bookshelf)
                let wallClockSize = min(w * 0.068, h * 0.108)
                let portraitH = wallClockSize * 0.86
                let portraitW = portraitH * 0.72
                let clockY = h * 0.1410
                let clockX = bookshelfX
                let portraitOffset = (wallClockSize * 0.5) + (portraitW * 0.5) + (wallClockSize * 0.14)
                
                // Foto Resmi Presiden RI (H. Prabowo Subianto) - Left of Clock
                PresidentialPortraitView(type: .president)
                    .frame(width: portraitW, height: portraitH)
                    .position(x: clockX - portraitOffset, y: clockY)
                
                // Clock (Center)
                AnalogWallClockView()
                    .frame(width: wallClockSize, height: wallClockSize)
                    .position(x: clockX, y: clockY)
                
                // Foto Resmi Wakil Presiden RI (Gibran Rakabuming Raka) - Right of Clock
                PresidentialPortraitView(type: .vicePresident)
                    .frame(width: portraitW, height: portraitH)
                    .position(x: clockX + portraitOffset, y: clockY)
                
                // Corkboard Notes (Center Wall: Sticky notes & Add Memo inside wooden frame)
                CorkboardView()
                    .frame(width: w * 0.2691, height: h * 0.2935)
                    .position(x: w * 0.4983, y: h * 0.2357)
                
                /*
                // Temporarily hidden: Wall Calendar (saved for later repositioning)
                WallCalendarView()
                    .frame(width: w * 0.056, height: h * 0.104)
                    .position(x: w * 0.7025, y: h * 0.3320)
                */
                
                // Tropical Potted Houseplant (Beside Desk Left Side - Native Vector with Looping Leaf Sway)
                let plantW = w * 0.105
                let plantH = plantW * (310.0 / 140.0)
                PottedPlantView()
                    .frame(width: plantW, height: plantH)
                    .position(x: w * 0.296, y: (h * 0.795) - (plantH / 2))
                
                // Modern Executive Workstation Desk (Clean, Spacious Dual-Pedestal)
                let deskW = w * 0.335
                let deskH = deskW * (276.0 / 555.0)
                let deskX = w * 0.498
                let deskY = h * 0.650
                let tabletopSurfaceY = deskY - (deskH / 2)
                
                WorkstationDeskView()
                    .frame(width: deskW, height: deskH)
                    .position(x: deskX, y: deskY)
                
                // Workstation iMac Monitor (Center of Desk - Click to open Finder)
                let monitorW = w * 0.104
                let monitorH = monitorW * (170.0 / 175.0)
                let monitorScale = monitorW / 175.0
                WorkstationMonitorView()
                    .frame(width: 175, height: 170)
                    .scaleEffect(monitorScale)
                    .frame(width: monitorW, height: monitorH)
                    .position(x: deskX, y: tabletopSurfaceY - (monitorH / 2) + (13.5 * monitorScale))
                
                // Vintage Emerald & Brass Boudoir Lamp (Left Pedestal Top - Raised & Enlarged)
                DeskLampView(isOn: appState.lampOn) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        appState.lampOn.toggle()
                    }
                }
                .position(x: w * 0.350, y: tabletopSurfaceY - 87)
                
                // Left Desk Trophy Plaque (Tegoer Sapa - Crystal Acrylic)
                let plaqueH = min(h * 0.138, 142.0)
                let plaqueW = plaqueH * (460.0 / 580.0)
                DesktopAwardPlaqueView(
                    title: "Plakat Tegoer Sapa",
                    subtitle: "Plakat Penghargaan Resmi Tegoer Sapa",
                    imageName: "plaque_tegoer_sapa",
                    svgFileName: "tegoer sapa logoo.svg",
                    quickViewType: .tegoerPlaque
                )
                .frame(width: plaqueW, height: plaqueH)
                .position(x: w * 0.410, y: tabletopSurfaceY - (plaqueH / 2) + 6)

                
                // Right Desk Trophy Plaque (Sans Studio - Crystal Acrylic)
                DesktopAwardPlaqueView(
                    title: "Plakat Sans Studio",
                    subtitle: "Plakat Penghargaan Resmi Sans Studio",
                    imageName: "plaque_sans",
                    svgFileName: "sans logo.svg",
                    quickViewType: .sansPlaque
                )
                .frame(width: plaqueW, height: plaqueH)
                .position(x: w * 0.588, y: tabletopSurfaceY - (plaqueH / 2) + 6)
                
                // Desk Speaker (Marshall Bluetooth Speaker - Right Pedestal Top)
                VintageRadioView()
                    .position(x: w * 0.648, y: tabletopSurfaceY - 17)
                
                // Photo Gallery (Right Wall: centered perfectly in right wall boiserie panel)
                PhotoGalleryView()
                    .frame(width: w * 0.220, height: h * 0.440)
                    .position(x: w * 0.83125, y: h * 0.320)
                
                // Floor Lawn & Movable Carpet (Drop files anywhere on grass floor, movable hiding carpet)
                MagicCarpetView(theme: appState.currentTheme, screenSize: geo.size)
                    .frame(width: w, height: h)
                    .position(x: w * 0.5, y: h * 0.5)
                    .zIndex(12)
                
                // Fender Stratocaster Guitar on Stand (Standing on lawn beneath photo gallery)
                let guitarH = h * 0.58
                let guitarW = guitarH * 0.3442
                StratocasterGuitarView()
                    .frame(width: guitarW, height: guitarH)
                    .position(x: w * 0.87, y: h * 0.67)
                    .zIndex(15)
                
                // Dreadnought Acoustic Guitar on Stand (Standing on left lawn beneath wall shelf)
                let acousticH = h * 0.58
                let acousticW = acousticH * 0.365
                AcousticGuitarView()
                    .frame(width: acousticW, height: acousticH)
                    .position(x: w * 0.092, y: h * 0.665)
                    .zIndex(15)
                
                // Cartoon Wastebasket (Beside Desk on Floor)
                TrashCanView()
                    .position(x: w * 0.710, y: h * 0.738)
                    .zIndex(18)
                
                // Native Indonesian Swallow Flip-Flops (Sendal Jepit on Left Grass Floor - Click to Open Google Chrome)
                SandalJepitView()
                    .position(x: w * 0.190, y: h * 0.815)
                    .zIndex(10)
                
                // 3. Ambient Night Dimmer when Lamp is Off
                if !appState.lampOn {
                    Color.black.opacity(0.65)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(20)
                }
                

                // 5. Anchored Popovers & Flyouts (Shelf Item Flyout, Spotify Player, Theme Picker)
                if let targetURL = appState.activeShelfPopoverURL {
                    let shelfPlanks: [CGFloat] = [0.488, 0.922]
                    let shelfIdx = min(max(appState.activeShelfIndex, 0), 1)
                    let bookshelfTop = bookshelfY - (bookshelfH / 2)
                    let bookshelfHeight = bookshelfH
                    let plankY = bookshelfTop + (bookshelfHeight * shelfPlanks[shelfIdx])
                    let shelfItemY = plankY - 35
                    let popoverWidth: CGFloat = 279
                    let popoverX = (w * 0.208) + (popoverWidth / 2) + 4
                    let popoverY = min(max(shelfItemY, 140), h - 140)
                    
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(AppState.appleDismissSpring) {
                                    appState.activeShelfPopoverURL = nil
                                }
                            }
                        
                        ShelfFlyoutPopoverView(
                            url: targetURL,
                            shelfIndex: shelfIdx,
                            onClose: {
                                withAnimation(AppState.appleDismissSpring) {
                                    appState.activeShelfPopoverURL = nil
                                }
                            }
                        )
                        .position(x: popoverX, y: popoverY)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.86, anchor: .leading)
                                .combined(with: .offset(x: -14))
                                .combined(with: .opacity),
                            removal: .scale(scale: 0.92, anchor: .leading)
                                .combined(with: .offset(x: -6))
                                .combined(with: .opacity)
                        ))
                    }
                    .zIndex(45)
                }
                
                if appState.showBookshelfDrawer {
                    let popoverWidth: CGFloat = 520
                    let popoverX = min((w * 0.208) + (popoverWidth / 2) + 10, w - (popoverWidth / 2) - 20)
                    let popoverY = min(max(h * 0.380, 220), h - 230)
                    
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(AppState.appleDismissSpring) {
                                    appState.showBookshelfDrawer = false
                                }
                            }
                        
                        BookshelfDrawerView(isPresented: $appState.showBookshelfDrawer)
                            .position(x: popoverX, y: popoverY)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.88, anchor: .leading)
                                    .combined(with: .offset(x: -16))
                                    .combined(with: .opacity),
                                removal: .scale(scale: 0.92, anchor: .leading)
                                    .combined(with: .offset(x: -8))
                                    .combined(with: .opacity)
                            ))
                    }
                    .zIndex(45)
                }
                
                if appState.showSpotifyPopup {
                    let radioX = w * 0.622
                    let popoverX = min(max(radioX, 140), w - 140)
                    let popoverY = tabletopSurfaceY - 128
                    
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(AppState.appleDismissSpring) {
                                    appState.showSpotifyPopup = false
                                }
                            }
                        
                        SpotifyMiniPlayerView(isPresented: $appState.showSpotifyPopup)
                            .position(x: popoverX, y: popoverY)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.86, anchor: .bottom)
                                    .combined(with: .offset(y: 12))
                                    .combined(with: .opacity),
                                removal: .scale(scale: 0.92, anchor: .bottom)
                                    .combined(with: .offset(y: 6))
                                    .combined(with: .opacity)
                            ))
                    }
                    .zIndex(45)
                }
                
                if appState.showThemePicker {
                    ModalBackdrop(isPresented: $appState.showThemePicker) {
                        ThemePickerView(
                            currentTheme: Binding(
                                get: { appState.currentTheme },
                                set: { appState.currentTheme = $0 }
                            ),
                            isPresented: $appState.showThemePicker
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
                    }
                    .zIndex(40)
                }
                
                // 6. Interactive Quick View Popovers (Single-click preview with double-click app opener)
                if let active = appState.activeQuickView {
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(AppState.appleDismissSpring) {
                                    appState.activeQuickView = nil
                                }
                            }
                        
                        Group {
                            switch active {
                            case .clock:
                                ClockQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: min(max(clockX, 140), w - 140), y: min(max(clockY + (wallClockSize / 2) + 85, 140), h - 140))
                                
                            case .calendar:
                                CalendarQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: max((w * 0.7022) - 150, 140), y: min(max(h * 0.3318, 140), h - 140))
                                
                            case .monitor:
                                MonitorQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: deskX, y: max(tabletopSurfaceY - 110, 150))
                                
                            case .mail, .whatsapp:
                                WhatsAppQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: min(max(w * 0.468, 130), w - 130), y: tabletopSurfaceY - 95)
                                
                            case .trash:
                                TrashQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: min(max(w * 0.708, 130), w - 130), y: (h * 0.735) - 115)
                                
                            case .photo(let slot):
                                PhotoFrameQuickView(slotIndex: slot, onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(
                                    x: min(max(w * 0.83125 - 140, 140), w - 140),
                                    y: h * 0.320
                                )
                                
                            case .carpetItem(let itemURL):
                                CarpetItemQuickView(url: itemURL, onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: w * 0.498, y: min(h * 0.730, h - 140))
                                
                            case .guitar:
                                GuitarQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: min(max(w * 0.875 - 135, 140), w - 140), y: min(max(h * 0.640, 150), h - 140))
                                
                            case .acousticGuitar:
                                AcousticGuitarQuickView(onClose: {
                                    withAnimation(AppState.appleDismissSpring) {
                                        appState.activeQuickView = nil
                                    }
                                })
                                .position(x: min(max(w * 0.092 + 135, 140), w - 140), y: min(max(h * 0.640, 150), h - 140))
                                
                            case .tegoerPlaque:
                                AwardPlaqueQuickView(
                                    title: "Plakat Tegoer Sapa",
                                    subtitle: "Plakat Penghargaan Resmi Tegoer Sapa",
                                    imageName: "plaque_tegoer_sapa",
                                    svgFileName: "tegoer sapa logoo.svg",
                                    onClose: {
                                        withAnimation(AppState.appleDismissSpring) {
                                            appState.activeQuickView = nil
                                        }
                                    }
                                )
                                .position(x: min(max(w * 0.410, 140), w - 140), y: tabletopSurfaceY - 120)
                                
                            case .sansPlaque:
                                AwardPlaqueQuickView(
                                    title: "Plakat Sans Studio",
                                    subtitle: "Plakat Penghargaan Resmi Sans Studio",
                                    imageName: "plaque_sans",
                                    svgFileName: "sans logo.svg",
                                    onClose: {
                                        withAnimation(AppState.appleDismissSpring) {
                                            appState.activeQuickView = nil
                                        }
                                    }
                                )
                                .position(x: min(max(w * 0.588, 140), w - 140), y: tabletopSurfaceY - 120)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.86)
                                .combined(with: .offset(y: 10))
                                .combined(with: .opacity),
                            removal: .scale(scale: 0.90)
                                .combined(with: .offset(y: 4))
                                .combined(with: .opacity)
                        ))
                    }
                    .zIndex(50)
                }
            }
        }
    }
}





// MARK: - Reusable In-App Modal Backdrop
struct ModalBackdrop<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.40)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(AppState.appleDismissSpring) {
                        isPresented = false
                    }
                }
            
            content()
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.88)
                        .combined(with: .offset(y: 12))
                        .combined(with: .opacity),
                    removal: .scale(scale: 0.92)
                        .combined(with: .offset(y: 6))
                        .combined(with: .opacity)
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
            .background(Color.white.opacity(0.18))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
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
                Text("Panduan Fitur Custom Desktop Mac")
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
                    GuideRow(icon: "books.vertical.fill", color: .brown, title: "Rak Buku File & Folder", desc: "Seret file/folder dari desktop ke rak buku untuk menyimpannya. Klik dua kali untuk membuka file, atau klik kanan untuk melihat opsi.")
                    GuideRow(icon: "oval.inset.filled", color: .red, title: "Magic Carpet (Sembunyikan File)", desc: "Seret file ke atas karpet untuk menyembunyikannya. Klik karpet untuk mengangkatnya dan melihat/mengembalikan file.")
                    GuideRow(icon: "note.text", color: .orange, title: "Memo Board (Catatan Dinding)", desc: "Klik tombol 'Memo' di pojok papan gabus untuk membuat sticky note baru. Tulis to-do list dan centang saat selesai.")
                    GuideRow(icon: "photo.fill", color: .purple, title: "Bingkai Foto di Meja", desc: "Seret foto ke bingkai di atas meja atau klik untuk memajang foto favorit kamu.")
                    GuideRow(icon: "lightbulb.fill", color: .yellow, title: "Lampu Meja (Mode Malam)", desc: "Klik kap lampu di atas meja untuk mematikan/menyalakan lampu dan meredupkan ruangan.")
                    GuideRow(icon: "radio.fill", color: .green, title: "Radio Spotify", desc: "Klik radio di atas meja untuk memutar/menjeda lagu di Spotify langsung dari desktop.")
                    GuideRow(icon: "trash.fill", color: .gray, title: "Tempat Sampah", desc: "Seret file apa pun ke keranjang sampah di lantai untuk membuangnya langsung ke Trash macOS.")
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
        .frame(width: 580, height: 460)
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
