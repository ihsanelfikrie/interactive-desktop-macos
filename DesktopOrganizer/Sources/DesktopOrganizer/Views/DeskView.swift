import SwiftUI
import AppKit

public struct DeskView: View {
    let theme: RoomTheme
    @Binding var isNightMode: Bool
    @Binding var showSpotifyPopup: Bool
    
    public init(theme: RoomTheme, isNightMode: Binding<Bool>, showSpotifyPopup: Binding<Bool>) {
        self.theme = theme
        self._isNightMode = isNightMode
        self._showSpotifyPopup = showSpotifyPopup
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Props Resting Directly on Tabletop
            HStack(alignment: .bottom, spacing: 0) {
                // Desk Lamp (Left side of tabletop)
                DeskLampView(isOn: !isNightMode) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isNightMode.toggle()
                    }
                }
                .padding(.leading, 36)
                
                Spacer()
                
                // Envelope / Letter (Center of tabletop)
                LetterEnvelopeView {
                    openMailApp()
                }
                
                Spacer()
                
                // Vintage Radio (Right side of tabletop)
                VintageRadioView {
                    withAnimation(.spring()) {
                        showSpotifyPopup.toggle()
                    }
                }
                .padding(.trailing, 40)
            }
            .padding(.bottom, -2) // Flush onto tabletop surface
            
            // MARK: - White Lacquer Tabletop Surface
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.98, green: 0.97, blue: 0.95), Color(red: 0.90, green: 0.89, blue: 0.86)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 680, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 5, y: 4)
                
                // Sheen highlight on top edge
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.70))
                    .frame(width: 640, height: 2)
                    .offset(y: -7)
            }
            
            // MARK: - Desk Front Body with Drawers & Kneehole
            HStack(spacing: 0) {
                // Left drawer stack
                VStack(spacing: 5) {
                    DrawerBox(color: drawerColor)
                    DrawerBox(color: drawerColor)
                }
                .frame(width: 140)
                .padding(6)
                
                // Center Kneehole opening (Floor visible underneath)
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                
                // Right drawer stack
                VStack(spacing: 5) {
                    DrawerBox(color: drawerColor)
                    DrawerBox(color: drawerColor)
                }
                .frame(width: 140)
                .padding(6)
            }
            .frame(width: 660, height: 95)
            .background(deskColor.opacity(0.92))
        }
        .frame(width: 680)
    }
    
    private var deskColor: Color {
        Color(red: 0.96, green: 0.95, blue: 0.93)
    }
    
    private var drawerColor: Color {
        Color(red: 0.92, green: 0.91, blue: 0.89)
    }
    
    private func openMailApp() {
        if let mailURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.mail") {
            NSWorkspace.shared.openApplication(at: mailURL, configuration: NSWorkspace.OpenConfiguration())
        } else if let url = URL(string: "mailto:") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Modern Executive Workstation Desk & Chair (Native SwiftUI Vector)
public struct WorkstationDeskView: View {
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let scaleX = w / 555.0
            let scaleY = h / 276.0
            
            ZStack(alignment: .bottom) {
                // Ground Contact Floor Shadow under pedestals and chair
                HStack(spacing: 0) {
                    // Left pedestal shadow
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.32))
                        .frame(width: 145 * scaleX, height: 12 * scaleY)
                        .blur(radius: 4)
                    
                    // Center kneehole floor opening
                    Spacer()
                    
                    // Right pedestal shadow
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.32))
                        .frame(width: 145 * scaleX, height: 12 * scaleY)
                        .blur(radius: 4)
                }
                .offset(y: 4 * scaleY)
                
                // MAIN DESK ASSEMBLY
                ZStack(alignment: .top) {
                    // Back Modesty Panel in Kneehole (Recessed back wall)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.84), Color(white: 0.74)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 265 * scaleX, height: 190 * scaleY)
                        .overlay(
                            Rectangle()
                                .fill(LinearGradient(colors: [Color.black.opacity(0.28), Color.clear], startPoint: .top, endPoint: .bottom))
                                .frame(height: 18 * scaleY),
                            alignment: .top
                        )
                        .position(x: 277.5 * scaleX, y: (24 + 95) * scaleY)
                    
                    // DESK TWIN PEDESTALS (Drawers on Left & Right)
                    HStack(spacing: 0) {
                        // Left Pedestal (4 Drawers)
                        PedestalDrawersStack(isLeft: true, scaleX: scaleX, scaleY: scaleY)
                            .frame(width: 145 * scaleX, height: 252 * scaleY)
                        
                        // Kneehole Space (Pass-through to chair)
                        Spacer()
                            .frame(width: 265 * scaleX)
                        
                        // Right Pedestal (4 Drawers)
                        PedestalDrawersStack(isLeft: false, scaleX: scaleX, scaleY: scaleY)
                            .frame(width: 145 * scaleX, height: 252 * scaleY)
                    }
                    .offset(y: 24 * scaleY)
                    
                    // TOP TABLETOP SURFACE
                    DeskTabletopSurface(scaleX: scaleX, scaleY: scaleY)
                        .frame(width: 555 * scaleX, height: 24 * scaleY)
                }
            }
        }
    }
}

// MARK: - Pedestal Drawer Stack (4 Flush Drawers + Brushed Handles)
struct PedestalDrawersStack: View {
    let isLeft: Bool
    let scaleX: CGFloat
    let scaleY: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Cabinet Outer Casing
            ZStack(alignment: .top) {
                // Base Cabinet Wall
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.94, green: 0.94, blue: 0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    )
                
                // Vertical Stack of 4 Flush Drawers
                VStack(spacing: 4 * scaleY) {
                    ModernDrawerRow(height: 48 * scaleY, handleW: 46 * scaleX, scaleX: scaleX, scaleY: scaleY)
                    ModernDrawerRow(height: 52 * scaleY, handleW: 46 * scaleX, scaleX: scaleX, scaleY: scaleY)
                    ModernDrawerRow(height: 56 * scaleY, handleW: 46 * scaleX, scaleX: scaleX, scaleY: scaleY)
                    ModernDrawerRow(height: 60 * scaleY, handleW: 46 * scaleX, scaleX: scaleX, scaleY: scaleY)
                }
                .padding(.top, 4 * scaleY)
                .padding(.horizontal, 4 * scaleX)
            }
            .frame(height: 234 * scaleY)
            
            // Recessed Base Plinth / Kickplate
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.78), Color(white: 0.68)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 138 * scaleX, height: 18 * scaleY)
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.15), lineWidth: 0.8)
                )
        }
    }
}

// MARK: - Single Flush Modern Drawer with Brushed Aluminum Pull
struct ModernDrawerRow: View {
    let height: CGFloat
    let handleW: CGFloat
    let scaleX: CGFloat
    let scaleY: CGFloat
    
    var body: some View {
        ZStack {
            // Drawer Face Plate (Crisp White Lacquer with Soft Bevel)
            RoundedRectangle(cornerRadius: 2.5)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.99),
                            Color(white: 0.95),
                            Color(white: 0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2.5)
                        .stroke(Color.black.opacity(0.10), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 1, y: 1)
            
            // Drawer Gap Shadow
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            // Sleek Brushed Aluminum Pull Handle
            ZStack {
                // Drop shadow
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black.opacity(0.20))
                    .frame(width: handleW, height: 6 * scaleY)
                    .offset(y: 1.5)
                
                // Metal Handle Bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.88),
                                Color(white: 0.72),
                                Color(white: 0.80)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: handleW, height: 5.5 * scaleY)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.white.opacity(0.85), lineWidth: 0.5)
                    )
            }
        }
        .frame(height: height)
    }
}

// MARK: - Tabletop Surface with Receding Depth Plane, Edge Bevel & Sheen
struct DeskTabletopDepthShape: Shape {
    let scaleX: CGFloat
    let scaleY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let insetX = 4.5 * scaleX
        path.move(to: CGPoint(x: rect.minX + insetX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct DeskTabletopSurface: View {
    let scaleX: CGFloat
    let scaleY: CGFloat
    
    var body: some View {
        let topDepth = 24.0 * scaleY
        ZStack(alignment: .bottom) {
            // 1. Perspective Horizontal Tabletop Surface Plane (Receding back to wall)
            ZStack(alignment: .top) {
                // Tabletop Surface Base (High-end Pearl-White Lacquer)
                DeskTabletopDepthShape(scaleX: scaleX, scaleY: scaleY)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.88, green: 0.90, blue: 0.93),
                                Color(red: 0.93, green: 0.95, blue: 0.97),
                                Color(red: 0.98, green: 0.98, blue: 0.99)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Deep Ambient Wall Contact Shadow at the top edge meeting the wall
                DeskTabletopDepthShape(scaleX: scaleX, scaleY: scaleY)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.35),
                                Color.black.opacity(0.12),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 7 * scaleY)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                // Soft Polish Sheen Band across Tabletop Surface
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.45),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 8 * scaleY)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .clipShape(DeskTabletopDepthShape(scaleX: scaleX, scaleY: scaleY))
                
                // Subtle side perspective beveled edge strokes
                DeskTabletopDepthShape(scaleX: scaleX, scaleY: scaleY)
                    .stroke(Color.black.opacity(0.12), lineWidth: 0.8)
            }
            .frame(width: 555 * scaleX, height: topDepth)
            .offset(y: -24 * scaleY)
            
            // 2. Drop shadow cast downward onto pedestals and kneehole
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.28))
                .frame(width: 555 * scaleX, height: 22 * scaleY)
                .blur(radius: 4)
                .offset(y: 3 * scaleY)
            
            // 3. Main Solid Lacquered Front Facing Apron
            RoundedRectangle(cornerRadius: 3.5)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.99),
                            Color(white: 0.96),
                            Color(white: 0.90)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 555 * scaleX, height: 24 * scaleY)
                .overlay(
                    RoundedRectangle(cornerRadius: 3.5)
                        .stroke(Color.black.opacity(0.12), lineWidth: 0.8)
                )
            
            // 4. Polished Chamfer Top Edge Highlight Line (Transition from top surface to front edge)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.95))
                .frame(width: 549 * scaleX, height: 2 * scaleY)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 1.5)
            
            // 5. Dark Under-beveled shadow lip
            Rectangle()
                .fill(Color.black.opacity(0.18))
                .frame(width: 553 * scaleX, height: 2 * scaleY)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(width: 555 * scaleX, height: 24 * scaleY, alignment: .bottom)
    }
}


// MARK: - Workstation Apple Magic Keyboard & Mouse Set
public struct WorkstationPeripheralsView: View {
    let scale: CGFloat
    
    public init(scale: CGFloat = 1.0) {
        self.scale = scale
    }
    
    public var body: some View {
        HStack(spacing: 7 * scale) {
            // Apple Magic Keyboard (Silver Aluminum Unibody with Crisp Keycaps)
            ZStack {
                // Grounding contact drop shadow on white tabletop
                RoundedRectangle(cornerRadius: 2.5 * scale)
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 70 * scale, height: 16 * scale)
                    .blur(radius: 1.2 * scale)
                    .offset(y: 1.2 * scale)
                
                // Keyboard Aluminum Body Wedge
                RoundedRectangle(cornerRadius: 2.0 * scale)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.95),
                                Color(white: 0.85),
                                Color(white: 0.80)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 68 * scale, height: 15 * scale)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2.0 * scale)
                            .stroke(Color.white.opacity(0.85), lineWidth: 0.5 * scale)
                    )
                
                // Keycaps Deck Well
                RoundedRectangle(cornerRadius: 1.2 * scale)
                    .fill(Color(white: 0.87))
                    .frame(width: 64 * scale, height: 12 * scale)
                    .overlay(
                        VStack(spacing: 0.8 * scale) {
                            // Function row
                            HStack(spacing: 0.8 * scale) {
                                ForEach(0..<10, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 0.4 * scale)
                                        .fill(Color.white)
                                        .frame(height: 1.4 * scale)
                                }
                            }
                            // Number row
                            HStack(spacing: 0.8 * scale) {
                                ForEach(0..<10, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 0.4 * scale)
                                        .fill(Color.white)
                                        .frame(height: 1.8 * scale)
                                }
                            }
                            // QWERTY row
                            HStack(spacing: 0.8 * scale) {
                                ForEach(0..<9, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 0.4 * scale)
                                        .fill(Color.white)
                                        .frame(height: 1.8 * scale)
                                }
                            }
                            // Spacebar & bottom modifier keys
                            HStack(spacing: 0.8 * scale) {
                                RoundedRectangle(cornerRadius: 0.4 * scale)
                                    .fill(Color.white)
                                    .frame(width: 6 * scale, height: 1.8 * scale)
                                RoundedRectangle(cornerRadius: 0.4 * scale)
                                    .fill(Color.white)
                                    .frame(width: 20 * scale, height: 1.8 * scale)
                                RoundedRectangle(cornerRadius: 0.4 * scale)
                                    .fill(Color.white)
                                    .frame(width: 6 * scale, height: 1.8 * scale)
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 0.4 * scale)
                                        .fill(Color.white)
                                        .frame(height: 1.8 * scale)
                                }
                            }
                        }
                        .padding(.horizontal, 1.2 * scale)
                    )
            }
            .frame(width: 70 * scale, height: 16 * scale)
            
            // Apple Magic Mouse (Glossy Pure White Acrylic Surface Top)
            ZStack {
                // Drop shadow on tabletop
                Capsule()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 13 * scale, height: 19 * scale)
                    .blur(radius: 1.2 * scale)
                    .offset(y: 1.2 * scale)
                
                // Aluminum Chassis
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.86), Color(white: 0.72)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12.5 * scale, height: 18.5 * scale)
                
                // Glossy Acrylic White Top
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 1.0), Color(white: 0.98), Color(white: 0.92)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 11.5 * scale, height: 17.5 * scale)
                    .overlay(Capsule().stroke(Color.white, lineWidth: 0.4 * scale))
                
                // Subtle Center Touch Divider
                Rectangle()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 0.5 * scale, height: 6 * scale)
                    .offset(y: -3.5 * scale)
            }
            .frame(width: 13 * scale, height: 19 * scale)
        }
    }
}

// MARK: - Workstation iMac Monitor (Interactive Vector Display)
public struct WorkstationMonitorView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private var isScreenOn: Bool {
        appState.isMonitorScreenOn
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Display Enclosure Body (Screen + Metallic Chin)
            VStack(spacing: 0) {
                // Retina Screen Area
                ZStack {
                    // Outer Ultra-thin bezel
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color(white: 0.12))
                        .frame(width: 175, height: 114)
                        .shadow(color: .black.opacity(0.28), radius: 6, y: 3)
                    
                    // Active Screen Workspace Surface (User Custom Wallpaper or Sleeping Black Glass)
                    ZStack {
                        // Deep Onyx Black LCD Panel (Active when off or beneath wallpaper)
                        Color(red: 0.035, green: 0.040, blue: 0.045)
                            .frame(width: 167, height: 104)
                            .cornerRadius(7)
                        
                        if isScreenOn {
                            ZStack {
                                if let nsImg = AssetLoader.image(named: "walpaper") {
                                    Image(nsImage: nsImg)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 167, height: 104)
                                        .clipped()
                                        .brightness(-0.06) // Sedikit redup agar terlihat menyatu natural di ruangan
                                        .contrast(1.03)
                                        .saturation(0.97)
                                        .cornerRadius(7)
                                } else {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.10, green: 0.18, blue: 0.32),
                                                    Color(red: 0.16, green: 0.28, blue: 0.46),
                                                    Color(red: 0.28, green: 0.38, blue: 0.56)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 167, height: 104)
                                }
                                
                                // Ambient screen depth vignette
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                Color.clear,
                                                Color.black.opacity(0.06),
                                                Color.black.opacity(0.18)
                                            ]),
                                            center: .center,
                                            startRadius: 45,
                                            endRadius: 92
                                        )
                                    )
                            }
                            .overlay(
                                // Subtle macOS window buttons in screen
                                VStack(spacing: 4) {
                                    HStack(spacing: 3) {
                                        Circle().fill(Color.red.opacity(0.85)).frame(width: 3.5, height: 3.5)
                                        Circle().fill(Color.yellow.opacity(0.85)).frame(width: 3.5, height: 3.5)
                                        Circle().fill(Color.green.opacity(0.85)).frame(width: 3.5, height: 3.5)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.top, 5)
                                    
                                    Spacer()
                                    
                                    // Mini macOS dock with colorful micro app icons
                                    HStack(spacing: 3) {
                                        ForEach(0..<6, id: \.self) { i in
                                            let iconColors: [Color] = [
                                                Color(red: 0.18, green: 0.55, blue: 0.95), // Finder blue
                                                Color(red: 0.95, green: 0.30, blue: 0.25), // Music red
                                                Color(red: 0.20, green: 0.75, blue: 0.45), // Messages green
                                                Color(red: 0.98, green: 0.65, blue: 0.15), // Notes yellow
                                                Color(red: 0.60, green: 0.35, blue: 0.85), // Podcasts purple
                                                Color(red: 0.30, green: 0.75, blue: 0.85)  // Safari cyan
                                            ]
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(iconColors[i % iconColors.count])
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.22))
                                            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 0.5))
                                    )
                                    .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                                    .padding(.bottom, 4)
                                }
                                .frame(width: 167, height: 104)
                            )
                            .transition(.opacity)
                        }
                    }
                    .frame(width: 167, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    
                    // Pristine Apple Retina Studio Glass Reflection & Bevel Catchlight (Diperkuat natural)
                    ZStack {
                        // 1. Studio Window Light Pane Reflections (Angled diagonal light streaks)
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color.white.opacity(0.30), location: 0.0),
                                            .init(color: Color.white.opacity(0.12), location: 0.45),
                                            .init(color: Color.white.opacity(0.01), location: 0.90)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 32, height: 170)
                                .rotationEffect(.degrees(-32))
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color.white.opacity(0.20), location: 0.0),
                                            .init(color: Color.white.opacity(0.08), location: 0.45),
                                            .init(color: Color.white.opacity(0.01), location: 0.85)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 16, height: 170)
                                .rotationEffect(.degrees(-32))
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color.white.opacity(0.10), location: 0.0),
                                            .init(color: Color.white.opacity(0.02), location: 0.50),
                                            .init(color: Color.clear, location: 0.80)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 40, height: 170)
                                .rotationEffect(.degrees(-32))
                        }
                        .blur(radius: 3.0)
                        .offset(x: -22, y: -10)
                        
                        // 2. Corner Specular Softbox Flare (Overhead light catch)
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.34),
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.04),
                                Color.clear
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 90
                        )
                        
                        // 3. Diagonal Curved Screen Sheen & Glass Fresnel Glare
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.22), location: 0.0),
                                .init(color: Color.white.opacity(0.07), location: 0.30),
                                .init(color: Color.clear, location: 0.62)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // 4. Subtle Anti-Reflective Optical Coating Tint
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.48, green: 0.35, blue: 0.95).opacity(0.07), location: 0.0),
                                .init(color: Color(red: 0.15, green: 0.70, blue: 0.85).opacity(0.04), location: 0.35),
                                .init(color: Color.clear, location: 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // 5. Crisp Inner Glass Perimeter Catchlight
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: Color.white.opacity(0.65), location: 0.0),
                                        .init(color: Color.white.opacity(0.26), location: 0.25),
                                        .init(color: Color.white.opacity(0.05), location: 0.55),
                                        .init(color: Color.clear, location: 0.80)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.85
                            )
                    }
                    .frame(width: 167, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .opacity(isScreenOn ? 1.0 : 1.25)
                    .allowsHitTesting(false)
                }
                
                // Iconic Metallic Aluminum Chin
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.92), Color(white: 0.78)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 175, height: 18)
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                        )
                    
                    // Apple logo silhouette
                    Image(systemName: "applelogo")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.35))
                }
            }
            .shadow(color: .black.opacity(0.18), radius: 4, y: 3)
            
            // 2. Visible Brushed Aluminum Stand Grounded on Desk Surface
            VStack(spacing: 0) {
                // Vertical / Angled Aluminum Neck Stem
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.84), Color(white: 0.68), Color(white: 0.78)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 34, height: 24)
                    .overlay(
                        HStack {
                            Rectangle().fill(Color.white.opacity(0.55)).frame(width: 1)
                            Spacer()
                            Rectangle().fill(Color.black.opacity(0.22)).frame(width: 1)
                        }
                    )
                    .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
                
                // Stand Foot / Aluminum Base Plate in 2.5D Perspective
                ZStack(alignment: .bottom) {
                    // Wide diffuse ambient tabletop shadow
                    Ellipse()
                        .fill(Color.black.opacity(0.32))
                        .frame(width: 84, height: 8)
                        .blur(radius: 2.5)
                        .offset(y: 2.5)
                    
                    // Tight crisp contact occlusion shadow directly under metal foot
                    Capsule()
                        .fill(Color.black.opacity(0.75))
                        .frame(width: 70, height: 3)
                        .offset(y: 1.0)
                    
                    VStack(spacing: 0) {
                        // Top horizontal perspective plane
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(white: 0.95),
                                        Color(white: 0.84),
                                        Color(white: 0.89)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 72, height: 11.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2.5)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.95), Color(white: 0.75)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 0.6
                                    )
                            )
                        
                        // Front chamfer edge
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.76), Color(white: 0.60)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 72, height: 2.5)
                    }
                }
                .frame(width: 84, height: 14)
            }
            .frame(width: 175, height: 38)
        }
        .frame(width: 175, height: 170)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            NSWorkspace.shared.activateFileViewerSelecting([FileManager.default.homeDirectoryForCurrentUser])
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                appState.isMonitorScreenOn.toggle()
            }
        }
        .contextMenu {
            Button(isScreenOn ? "Matikan Layar Komputer" : "Nyalakan Layar Komputer") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.isMonitorScreenOn.toggle()
                }
            }
            Button("Buka Info Sistem & Spesifikasi Mac") {
                AppState.shared.toggleQuickView(.monitor)
            }
            Divider()
            Button("Buka Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([FileManager.default.homeDirectoryForCurrentUser])
            }
        }
        .help(isScreenOn ? "Layar iMac: Klik 1x untuk mematikan layar, klik 2x untuk buka Finder" : "Layar iMac: Klik 1x untuk menyalakan layar")
    }
}

// MARK: - Vintage Emerald & Brass Boudoir Lamp (Native SwiftUI Vector)
public struct DeskLampView: View {
    let isOn: Bool
    let action: () -> Void
    
    public init(isOn: Bool, action: @escaping () -> Void) {
        self.isOn = isOn
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // 1. Physically Authentic Ambient Light Glow (When Lamp is ON)
                if isOn {
                    // A. Soft Warm Radial Aura on the wall centered behind the lampshade
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.94, blue: 0.72).opacity(0.50),
                                    Color(red: 1.0, green: 0.86, blue: 0.50).opacity(0.24),
                                    Color(red: 1.0, green: 0.78, blue: 0.38).opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 15,
                                endRadius: 105
                            )
                        )
                        .frame(width: 210, height: 210)
                        .offset(y: -58)
                    
                    // B. Tabletop Warm Pool of Light (Spreading on the white desk surface around the base)
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.96, blue: 0.78).opacity(0.40),
                                    Color(red: 1.0, green: 0.88, blue: 0.52).opacity(0.18),
                                    Color(red: 1.0, green: 0.80, blue: 0.40).opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 24,
                                endRadius: 80
                            )
                        )
                        .frame(width: 150, height: 26)
                        .offset(y: 3)
                        .blur(radius: 2)
                }
                
                // 2. Base Grounding Shadows under brass plinth (Firmly anchors lamp to tabletop)
                // A. Wide soft ambient contact shadow
                Ellipse()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 62, height: 8)
                    .offset(y: 2.5)
                    .blur(radius: 2)
                
                // B. Crisp deep dark contact occlusion line (Zero gap between plinth and desk)
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 48, height: 3.5)
                    .offset(y: 1.0)
                
                // 3. Vector Boudoir Lamp Body & Shade (Enlarged ~1.36x & Bottom-anchored)
                BoudoirEmeraldLampVector(isOn: isOn)
                    .scaleEffect(1.36, anchor: .bottom)
            }
            .frame(width: 210, height: 175, alignment: .bottom)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Lampu Meja Klasik: Klik untuk menyalakan / mematikan lampu")
    }
}

// MARK: - Vector Boudoir Lamp Components
struct LampShadeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topInset: CGFloat = rect.width * 0.22
        path.move(to: CGPoint(x: rect.minX + topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topInset, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.maxX - (topInset * 0.35), y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topInset, y: rect.minY), control: CGPoint(x: rect.minX + (topInset * 0.35), y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct BoudoirEmeraldLampVector: View {
    let isOn: Bool
    
    private var brassGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.88, blue: 0.60),
                Color(red: 0.82, green: 0.65, blue: 0.35),
                Color(red: 0.68, green: 0.48, blue: 0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var brassVerticalGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.86, blue: 0.58),
                Color(red: 0.72, green: 0.54, blue: 0.26)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Brass Finial Tip (Sits securely on top of shade)
            ZStack {
                Circle()
                    .fill(brassGradient)
                    .frame(width: 6, height: 6)
                Rectangle()
                    .fill(Color(red: 0.82, green: 0.64, blue: 0.32))
                    .frame(width: 3, height: 4)
                    .offset(y: 3)
            }
            .offset(y: 2)
            .zIndex(5)
            
            // 2. Fluted Silk Shade (Pleat lines strictly contained inside)
            ZStack(alignment: .bottom) {
                // Main Shade Body
                LampShadeShape()
                    .fill(
                        isOn ?
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.97, blue: 0.86),
                                Color(red: 1.0, green: 0.89, blue: 0.62),
                                Color(red: 0.98, green: 0.78, blue: 0.42)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [
                                Color(red: 0.94, green: 0.92, blue: 0.86),
                                Color(red: 0.86, green: 0.83, blue: 0.76),
                                Color(red: 0.78, green: 0.74, blue: 0.66)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: isOn ? Color.yellow.opacity(0.35) : Color.black.opacity(0.18), radius: isOn ? 5 : 2, y: 2)
                
                // Pleated Vertical Fluting (Clipped so lines never protrude into empty air)
                HStack(spacing: 5.5) {
                    ForEach(0..<9, id: \.self) { _ in
                        Rectangle()
                            .fill(
                                isOn ?
                                Color(red: 0.90, green: 0.72, blue: 0.36).opacity(0.40) :
                                Color.black.opacity(0.09)
                            )
                            .frame(width: 1, height: 46)
                    }
                }
                .clipShape(LampShadeShape())
                
                // Antique Gold Top Rim Band
                RoundedRectangle(cornerRadius: 1)
                    .fill(brassGradient)
                    .frame(width: 36, height: 2.5)
                    .position(x: 34, y: 1.25)
                
                // Antique Gold Bottom Hem Piping (Clean tailored trim, no floating hoop rings)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(brassGradient)
                    .frame(width: 68, height: 3.5)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, y: 1)
            }
            .frame(width: 68, height: 46)
            
            // 3. Solid Central Brass Neck Column & Socket (Physically connects Shade to Urn!)
            ZStack(alignment: .center) {
                // Continuous vertical solid brass rod connecting shade directly into urn
                Rectangle()
                    .fill(brassVerticalGradient)
                    .frame(width: 6, height: 16)
                
                // Brass socket collar housing
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(brassGradient)
                    .frame(width: 14, height: 6)
                
                // Single realistic brass pull chain hanging from the socket collar
                VStack(spacing: 1.2) {
                    ForEach(0..<6, id: \.self) { _ in
                        Circle()
                            .fill(Color(red: 0.90, green: 0.76, blue: 0.40))
                            .frame(width: 1.8, height: 1.8)
                    }
                    // Teardrop fob
                    Capsule()
                        .fill(brassGradient)
                        .frame(width: 3.2, height: 5.5)
                }
                .offset(x: 10, y: 7)
            }
            .frame(width: 28, height: 16)
            .zIndex(4)
            
            // 4. Ribbed Emerald Ceramic Urn Body
            ZStack(alignment: .top) {
                // Upper brass seating collar cup
                RoundedRectangle(cornerRadius: 1)
                    .fill(brassGradient)
                    .frame(width: 16, height: 3)
                    .zIndex(2)
                
                // Urn Body Shadow
                Ellipse()
                    .fill(Color.black.opacity(0.22))
                    .frame(width: 28, height: 36)
                    .blur(radius: 2)
                    .offset(y: 2)
                
                // Deep Emerald Green Ceramic / Glass Body
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.56, blue: 0.38),
                                Color(red: 0.06, green: 0.38, blue: 0.24),
                                Color(red: 0.02, green: 0.22, blue: 0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 36)
                    .overlay(
                        Ellipse()
                            .stroke(Color(red: 0.04, green: 0.26, blue: 0.16), lineWidth: 1)
                    )
                
                // Glossy Curved Glass Reflection Highlight
                Path { path in
                    path.addArc(center: CGPoint(x: 10, y: 16), radius: 8, startAngle: .degrees(130), endAngle: .degrees(230), clockwise: false)
                }
                .stroke(Color.white.opacity(0.65), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                
                // Subtle Vertical Fluting on Urn
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(0.18))
                            .frame(width: 1, height: 26)
                    }
                }
                .offset(y: 5)
            }
            .frame(width: 32, height: 38)
            
            // 5. Stepped Tiered Brass Pedestal Base
            VStack(spacing: 1) {
                // Upper Brass Ring Collar
                RoundedRectangle(cornerRadius: 1)
                    .fill(brassVerticalGradient)
                    .frame(width: 18, height: 4)
                
                // Middle Stepped Disc
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(brassVerticalGradient)
                    .frame(width: 28, height: 5)
                
                // Heavy Wide Beveled Base Plinth
                RoundedRectangle(cornerRadius: 2)
                    .fill(brassGradient)
                    .frame(width: 38, height: 6)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
            }
        }
        .frame(width: 76, height: 122)
    }
}



// MARK: - Animated Floating Music Notes (Continuous Rise, Sway & Fade Loop)
struct FloatingNotesView: View {
    @ObservedObject var appState = AppState.shared
    
    private struct NoteParticle {
        let symbol: String
        let color: Color
        let size: CGFloat
        let baseX: CGFloat
        let delay: Double
        let swaySpeed: Double
        let floatDistance: CGFloat
    }
    
    private let particles: [NoteParticle] = [
        NoteParticle(symbol: "♪", color: SANSColors.lime, size: 14, baseX: -14, delay: 0.0, swaySpeed: 2.8, floatDistance: 24),
        NoteParticle(symbol: "♫", color: Color(red: 1.0, green: 0.85, blue: 0.25), size: 17, baseX: -2, delay: 0.55, swaySpeed: 2.2, floatDistance: 30),
        NoteParticle(symbol: "♩", color: SANSColors.pink, size: 12, baseX: 10, delay: 1.10, swaySpeed: 3.2, floatDistance: 22),
        NoteParticle(symbol: "♬", color: Color(red: 0.40, green: 0.88, blue: 1.0), size: 15, baseX: 4, delay: 1.65, swaySpeed: 2.5, floatDistance: 28)
    ]
    
    @ViewBuilder
    var body: some View {
        let isActive = appState.isWindowVisible && appState.isAppActive && !appState.isLowPower
        if !isActive {
            EmptyView()
        } else {
            TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let loopDuration: Double = 2.2
                
                ZStack {
                    ForEach(0..<particles.count, id: \.self) { idx in
                        let p = particles[idx]
                        // Loop progress 0.0 -> 1.0 for each note with delay offset
                        let rawProgress = (time + p.delay).truncatingRemainder(dividingBy: loopDuration) / loopDuration
                        let progress = min(max(rawProgress, 0.0), 1.0)
                        
                        // Smooth fade-in (first 20%) and fade-out (last 30%)
                        let opacity: Double = {
                            if progress < 0.20 {
                                return progress / 0.20
                            } else if progress > 0.70 {
                                return max(0.0, (1.0 - progress) / 0.30)
                            } else {
                                return 1.0
                            }
                        }()
                        
                        // Scale: pop in slightly, float up, dissolve
                        let scale: CGFloat = {
                            if progress < 0.20 {
                                return 0.6 + CGFloat(progress / 0.20) * 0.4
                            } else {
                                return 1.0 + CGFloat(sin(progress * .pi)) * 0.15
                            }
                        }()
                        
                        // Vertical rise & horizontal graceful sway
                        let offsetY = -4 - (progress * p.floatDistance)
                        let offsetX = p.baseX + CGFloat(sin((time * p.swaySpeed) + Double(idx))) * 4.5
                        let rotation = sin((time * 2.0) + Double(idx)) * 12.0
                        
                        Text(p.symbol)
                            .font(.system(size: p.size, weight: .bold))
                            .foregroundColor(p.color)
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(rotation))
                            .offset(x: offsetX, y: offsetY)
                            .opacity(opacity)
                            .shadow(color: p.color.opacity(0.80), radius: 3, x: 0, y: 1)
                    }
                }
                .frame(width: 48, height: 42)
            }
        }
    }
}

// MARK: - Vintage Radio (Spotify Opener & Player)
public struct VintageRadioView: View {
    @ObservedObject var spotify = SpotifyService.shared
    @ObservedObject var appState = AppState.shared
    let action: () -> Void
    
    public init(action: @escaping () -> Void = {}) {
        self.action = action
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            proceduralRadio
            
            if spotify.isPlaying {
                FloatingNotesView()
                    .offset(x: -6, y: -22)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            spotify.openSpotify()
        }
        .onTapGesture {
            if appState.showSpotifyPopup {
                withAnimation(AppState.appleDismissSpring) {
                    appState.showSpotifyPopup = false
                }
            } else {
                withAnimation(AppState.appleSpring) {
                    appState.activeQuickView = nil
                    appState.activeShelfPopoverURL = nil
                    appState.showSpotifyPopup = true
                }
            }
        }
        .help("Speaker Spotify: Klik untuk membuka pemutar mini, klik 2x untuk membuka aplikasi Spotify")
        .contextMenu {
            Button("Buka Pemutar Mini") {
                withAnimation(.spring()) {
                    appState.showSpotifyPopup.toggle()
                }
            }
            Button("Buka Aplikasi Spotify") {
                spotify.openSpotify()
            }
            Divider()
            Button(spotify.isPlaying ? "Jeda (Pause)" : "Putar (Play)") {
                spotify.playPause()
            }
            Button("Lagu Berikutnya") {
                spotify.nextTrack()
            }
            Button("Lagu Sebelumnya") {
                spotify.previousTrack()
            }
        }
        .help(spotify.isPlaying ? "Radio: \(spotify.trackTitle) - \(spotify.artistName)" : "Radio Spotify: Klik untuk memutar lagu")
    }
    
    private var proceduralRadio: some View {
        ZStack {
            // 0. Tabletop Contact Shadows
            // Main cabinet base shadow
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.44))
                .frame(width: 76, height: 6)
                .offset(x: -8, y: 19)
                .blur(radius: 2)
            
            // Carry strap resting shadow on tabletop
            Capsule()
                .fill(Color.black.opacity(0.38))
                .frame(width: 17, height: 4)
                .offset(x: 35, y: 19)
                .blur(radius: 1.5)
            
            // 1. Dual Rubber Isolation Feet under Speaker Base
            HStack(spacing: 48) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(white: 0.10))
                    .frame(width: 10, height: 2)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(white: 0.10))
                    .frame(width: 10, height: 2)
            }
            .offset(x: -8, y: 18)
            
            // 2. Main Cabinet Enclosure (Pebbled Black Silicone / Textured Vinyl)
            RoundedRectangle(cornerRadius: 7.5)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.24, green: 0.24, blue: 0.27),
                            Color(red: 0.14, green: 0.14, blue: 0.16),
                            Color(red: 0.09, green: 0.09, blue: 0.11)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 76, height: 36)
                .offset(x: -8)
                .overlay(
                    RoundedRectangle(cornerRadius: 7.5)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.20), Color.white.opacity(0.04), Color.black.opacity(0.45)],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                        .offset(x: -8)
                )
                .shadow(color: .black.opacity(0.45), radius: 3.5, y: 2)
            
            // 3. Top Controls
            // Central Multi-directional Brass Control Knob
            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.96, green: 0.86, blue: 0.55),
                                Color(red: 0.72, green: 0.56, blue: 0.28),
                                Color(red: 0.45, green: 0.32, blue: 0.15)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 3.5)
                    .overlay(Ellipse().stroke(Color(red: 0.35, green: 0.25, blue: 0.10), lineWidth: 0.5))
                
                Circle()
                    .fill(Color(red: 0.22, green: 0.16, blue: 0.08))
                    .frame(width: 1.5, height: 1.5)
            }
            .offset(x: -8, y: -16.5)
            .shadow(color: Color.black.opacity(0.4), radius: 0.8, y: 0.5)
            
            // Battery Level Segmented Red LED Bar (Top-left)
            HStack(spacing: 1.2) {
                ForEach(0..<4, id: \.self) { _ in
                    Capsule()
                        .fill(Color(red: 0.95, green: 0.22, blue: 0.18))
                        .frame(width: 1.2, height: 2.8)
                }
            }
            .offset(x: -28, y: -16)
            .shadow(color: spotify.isPlaying ? Color.red.opacity(0.85) : Color.clear, radius: 2)
            
            // Top Right Pairing & Micro Controls
            HStack(spacing: 2.5) {
                Circle()
                    .fill(Color(white: 0.30))
                    .frame(width: 2.2, height: 2.2)
                
                Capsule()
                    .fill(Color(white: 0.24))
                    .frame(width: 4, height: 1.8)
            }
            .offset(x: 12, y: -16)
            
            // 4. Recessed Front Grille Frame
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(red: 0.06, green: 0.06, blue: 0.08))
                    .frame(width: 68, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1.2)
                    )
                
                // Iconic Diamond Fret Acoustic Wire Mesh
                Canvas { context, size in
                    let spacing: CGFloat = 3.2
                    var p1 = Path()
                    var p2 = Path()
                    for i in stride(from: -size.height, to: size.width + size.height, by: spacing) {
                        p1.move(to: CGPoint(x: i, y: 0))
                        p1.addLine(to: CGPoint(x: i + size.height, y: size.height))
                        
                        p2.move(to: CGPoint(x: i, y: size.height))
                        p2.addLine(to: CGPoint(x: i + size.height, y: 0))
                    }
                    context.stroke(p1, with: .color(Color(white: 0.26)), lineWidth: 0.65)
                    context.stroke(p2, with: .color(Color(white: 0.26)), lineWidth: 0.65)
                }
                .frame(width: 66, height: 26)
                .clipShape(RoundedRectangle(cornerRadius: 4.5))
                
                // Deep acoustic cone shading behind mesh
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.70), Color.clear],
                            center: .center, startRadius: 2, endRadius: 26
                        )
                    )
                    .frame(width: 58, height: 22)
                    .allowsHitTesting(false)
                
                // Iconic Gold "Marshall" Script Emblem
                Text("Marshall")
                    .font(.custom("SnellRoundhand-Bold", size: 13.5))
                    .italic()
                    .foregroundColor(Color(red: 0.95, green: 0.84, blue: 0.52))
                    .shadow(color: Color.black, radius: 1, x: 0.8, y: 1.2)
                    .shadow(color: Color.black.opacity(0.9), radius: 2)
            }
            .offset(x: -8)
            
            // 5. Right-Side Heavy-Duty Carry Strap with Burgundy Velvet Inner Lining
            ZStack(alignment: .topLeading) {
                // Outer Black Textured Leather Strap
                Path { path in
                    path.move(to: CGPoint(x: 77.5, y: 13.5))
                    path.addCurve(to: CGPoint(x: 88, y: 17), control1: CGPoint(x: 83, y: 13.5), control2: CGPoint(x: 87, y: 14.5))
                    path.addCurve(to: CGPoint(x: 93.5, y: 28), control1: CGPoint(x: 90, y: 21), control2: CGPoint(x: 94, y: 24))
                    path.addCurve(to: CGPoint(x: 87, y: 39.5), control1: CGPoint(x: 93, y: 34), control2: CGPoint(x: 90.5, y: 38))
                    path.addCurve(to: CGPoint(x: 76, y: 39.5), control1: CGPoint(x: 84, y: 40.5), control2: CGPoint(x: 79, y: 40.5))
                    path.addCurve(to: CGPoint(x: 73.5, y: 35), control1: CGPoint(x: 74, y: 39), control2: CGPoint(x: 73, y: 37))
                    path.addCurve(to: CGPoint(x: 79, y: 32), control1: CGPoint(x: 74, y: 33), control2: CGPoint(x: 77, y: 32.5))
                    path.addCurve(to: CGPoint(x: 86.5, y: 30), control1: CGPoint(x: 81, y: 31.5), control2: CGPoint(x: 85, y: 30.5))
                    path.addCurve(to: CGPoint(x: 87.5, y: 24), control1: CGPoint(x: 88, y: 29), control2: CGPoint(x: 88, y: 26))
                    path.addCurve(to: CGPoint(x: 78, y: 18), control1: CGPoint(x: 87, y: 20), control2: CGPoint(x: 83, y: 18))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.18, blue: 0.20),
                            Color(red: 0.11, green: 0.11, blue: 0.13),
                            Color(red: 0.07, green: 0.07, blue: 0.09)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                
                // Distinctive Rich Burgundy Red Velvet Inner Lining of Strap Loop
                Path { path in
                    path.move(to: CGPoint(x: 74.5, y: 35.5))
                    path.addCurve(to: CGPoint(x: 86, y: 32), control1: CGPoint(x: 77, y: 33), control2: CGPoint(x: 82, y: 32))
                    path.addCurve(to: CGPoint(x: 86, y: 37.5), control1: CGPoint(x: 87.5, y: 34), control2: CGPoint(x: 87.5, y: 36.5))
                    path.addCurve(to: CGPoint(x: 76, y: 39), control1: CGPoint(x: 83, y: 39), control2: CGPoint(x: 79, y: 39.5))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.62, green: 0.12, blue: 0.18),
                            Color(red: 0.44, green: 0.08, blue: 0.13)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    // Inner strap seam line
                    Path { path in
                        path.move(to: CGPoint(x: 75.5, y: 36.5))
                        path.addCurve(to: CGPoint(x: 85, y: 33.5), control1: CGPoint(x: 78, y: 34.5), control2: CGPoint(x: 82, y: 33.5))
                    }
                    .stroke(Color(red: 0.75, green: 0.20, blue: 0.25).opacity(0.6), lineWidth: 0.5)
                )
                
                // Metal Mounting Clip & Brass Pivot Pin on Cabinet Right Wall
                ZStack {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.40), Color(white: 0.18)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 3.5, height: 6)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 0.92, green: 0.80, blue: 0.50), Color(red: 0.45, green: 0.35, blue: 0.18)],
                                center: .center, startRadius: 0.3, endRadius: 1.5
                            )
                        )
                        .frame(width: 2.2, height: 2.2)
                }
                .position(x: 78.5, y: 15)
            }
        }
        .frame(width: 96, height: 42)
    }
}

// MARK: - Modern Glass-Card Envelope (Mail Opener)
struct LetterEnvelopeView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Glass card body
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.88))
                    .frame(width: 50, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.9), Color.white.opacity(0.2)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                
                // V-fold top flap
                Path { path in
                    path.move(to: CGPoint(x: 1, y: 1))
                    path.addLine(to: CGPoint(x: 25, y: 17))
                    path.addLine(to: CGPoint(x: 49, y: 1))
                }
                .stroke(Color(red: 0.18, green: 0.18, blue: 0.22).opacity(0.2), lineWidth: 1)
                
                // Minimalist @ symbol in indigo
                Text("@")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.30, green: 0.30, blue: 0.75).opacity(0.75))
                    .offset(y: 3)
            }
            .rotationEffect(.degrees(-4))
        }
        .buttonStyle(.plain)
        .help("Surat: Klik untuk membuka aplikasi Mail macOS")
    }
}

// MARK: - Modern Minimalist Desk Drawer
struct DrawerBox: View {
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(color)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.8)
            )
            .overlay(
                // Thin brushed-brass horizontal bar pull
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.92, green: 0.80, blue: 0.48), Color(red: 0.75, green: 0.62, blue: 0.30)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 28, height: 4)
                    .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
            )
            .frame(height: 38)
    }
}

// MARK: - Standing Desk Fan (Kos-Kosan)
public struct StandingFanView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            // Fan Cage
            Circle()
                .stroke(Color(red: 0.35, green: 0.60, blue: 0.75), lineWidth: 3)
                .background(Circle().fill(Color.white.opacity(0.85)))
                .frame(width: 58, height: 58)
                .overlay(
                    // Fan blades
                    ZStack {
                        ForEach(0..<3) { i in
                            Capsule()
                                .fill(Color(red: 0.20, green: 0.50, blue: 0.70).opacity(0.7))
                                .frame(width: 10, height: 26)
                                .offset(y: -10)
                                .rotationEffect(.degrees(Double(i) * 120))
                        }
                        Circle().fill(Color.white).frame(width: 10, height: 10)
                    }
                )
            
            // Stand Pole
            Rectangle()
                .fill(Color.gray)
                .frame(width: 4, height: 80)
            
            // Base Stand
            Circle()
                .fill(Color(red: 0.35, green: 0.60, blue: 0.75))
                .frame(width: 40, height: 12)
        }
    }
}

// MARK: - Water Dispenser with Blue Gallon (Kos-Kosan)
public struct WaterDispenserView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            // Upside-down blue gallon bottle
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.20, green: 0.55, blue: 0.88).opacity(0.8))
                    .frame(width: 42, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                // Water level ripple
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 6, height: 35)
                    .offset(x: -12)
            }
            
            // Dispenser base unit
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.92, green: 0.94, blue: 0.96))
                .frame(width: 48, height: 65)
                .overlay(
                    VStack(spacing: 4) {
                        Spacer()
                        // Hot & Cold taps
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.red).frame(width: 8, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.blue).frame(width: 8, height: 12)
                        }
                        Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 26, height: 4)
                        Spacer()
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
        }
    }
}
