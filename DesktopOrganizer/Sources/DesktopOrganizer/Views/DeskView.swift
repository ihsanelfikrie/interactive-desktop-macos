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
                    
                    // DESK TWIN PEDESTALS (Front Layer)
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

// MARK: - Tabletop Surface with Edge Bevel & Sheen
struct DeskTabletopSurface: View {
    let scaleX: CGFloat
    let scaleY: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Drop shadow cast downward
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.28))
                .frame(width: 555 * scaleX, height: 22 * scaleY)
                .blur(radius: 4)
                .offset(y: 3 * scaleY)
            
            // Main Solid Lacquered Top
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
            
            // Polished Chamfer Top Edge Highlight
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.95))
                .frame(width: 549 * scaleX, height: 2 * scaleY)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 1.5)
            
            // Dark Under-beveled shadow lip
            Rectangle()
                .fill(Color.black.opacity(0.18))
                .frame(width: 553 * scaleX, height: 2 * scaleY)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

// MARK: - Modern Cantilever Chair (Chrome Tubing + Navy Sapphire Cushion)
struct CantileverChairView: View {
    let scaleX: CGFloat
    let scaleY: CGFloat
    
    var body: some View {
        ZStack {
            // Chrome Sled Base (Continuous Bent Tube on floor)
            Path { path in
                path.move(to: CGPoint(x: 10 * scaleX, y: 110 * scaleY))
                path.addLine(to: CGPoint(x: 10 * scaleX, y: 118 * scaleY))
                path.addLine(to: CGPoint(x: 140 * scaleX, y: 118 * scaleY))
                path.addLine(to: CGPoint(x: 140 * scaleX, y: 110 * scaleY))
            }
            .stroke(
                LinearGradient(
                    colors: [Color(white: 0.88), Color(white: 0.60), Color(white: 0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 6 * scaleX, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
            
            // Chrome Vertical Stems (Rising up from front base)
            Path { path in
                path.move(to: CGPoint(x: 18 * scaleX, y: 116 * scaleY))
                path.addLine(to: CGPoint(x: 18 * scaleX, y: 55 * scaleY))
                path.addLine(to: CGPoint(x: 18 * scaleX, y: 20 * scaleY))
                
                path.move(to: CGPoint(x: 132 * scaleX, y: 116 * scaleY))
                path.addLine(to: CGPoint(x: 132 * scaleX, y: 55 * scaleY))
                path.addLine(to: CGPoint(x: 132 * scaleX, y: 20 * scaleY))
            }
            .stroke(
                LinearGradient(
                    colors: [Color(white: 0.92), Color(white: 0.65), Color(white: 0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5.5 * scaleX, lineCap: .round)
            )
            
            // Cushioned Seat Cushion (Ocean Sapphire Navy)
            ZStack {
                // Seat shadow
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.black.opacity(0.32))
                    .frame(width: 128 * scaleX, height: 26 * scaleY)
                    .offset(y: 4 * scaleY)
                    .blur(radius: 3)
                
                // Plush Foam Cushion
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.44, blue: 0.64),
                                Color(red: 0.14, green: 0.30, blue: 0.48),
                                Color(red: 0.08, green: 0.20, blue: 0.36)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 128 * scaleX, height: 26 * scaleY)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.20), lineWidth: 0.8)
                    )
                
                // Seat highlight line
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 118 * scaleX, height: 1.5 * scaleY)
                    .offset(y: -9 * scaleY)
            }
            .offset(y: 52 * scaleY)
            
            // Ergonomic Backrest Cushion (Navy Upholstery)
            ZStack {
                // Backrest shadow
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 112 * scaleX, height: 85 * scaleY)
                    .offset(y: 3 * scaleY)
                    .blur(radius: 3)
                
                // Backrest body
                RoundedRectangle(cornerRadius: 9)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.24, green: 0.46, blue: 0.66),
                                Color(red: 0.16, green: 0.32, blue: 0.50),
                                Color(red: 0.10, green: 0.22, blue: 0.38)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 112 * scaleX, height: 85 * scaleY)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                
                // Horizontal stitching indent / channel tuft
                Rectangle()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 96 * scaleX, height: 1.2 * scaleY)
                Rectangle()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 96 * scaleX, height: 1.0 * scaleY)
                    .offset(y: 1.2 * scaleY)
            }
            .offset(y: -10 * scaleY)
            
            // Padded Armrest Caps
            HStack(spacing: 96 * scaleX) {
                // Left armrest
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.18, green: 0.35, blue: 0.52), Color(red: 0.10, green: 0.22, blue: 0.36)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 12 * scaleX, height: 32 * scaleY)
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.8))
                
                // Right armrest
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.18, green: 0.35, blue: 0.52), Color(red: 0.10, green: 0.22, blue: 0.36)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 12 * scaleX, height: 32 * scaleY)
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.8))
            }
            .offset(y: 20 * scaleY)
        }
        .frame(width: 150 * scaleX, height: 170 * scaleY)
    }
}

// MARK: - Workstation iMac Monitor (Interactive Vector Display)
public struct WorkstationMonitorView: View {
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
                // Aluminum L-Stand Foot on desk
                ZStack {
                    // Foot shadow on tabletop
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.25))
                        .frame(width: 64, height: 8)
                        .blur(radius: 2)
                        .offset(y: 3)
                    
                    // Stand Base Plate
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.90), Color(white: 0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 62, height: 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.5)
                                .stroke(Color.white.opacity(0.85), lineWidth: 0.5)
                        )
                    
                    // Vertical Stand Stem
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.82), Color(white: 0.70)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 32, height: 38)
                        .offset(y: -16)
                }
                .offset(y: 12)
                
                // Display Enclosure Body
                VStack(spacing: 0) {
                    // Retina Screen Area
                    ZStack {
                        // Outer Ultra-thin bezel
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color(white: 0.12))
                            .frame(width: 175, height: 114)
                            .shadow(color: .black.opacity(0.28), radius: 6, y: 3)
                        
                        // Active Screen Workspace Surface (Wallpaper Glow)
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
                            .overlay(
                                // Subtle macOS window buttons in screen
                                VStack(spacing: 4) {
                                    HStack(spacing: 3) {
                                        Circle().fill(Color.red.opacity(0.8)).frame(width: 3.5, height: 3.5)
                                        Circle().fill(Color.yellow.opacity(0.8)).frame(width: 3.5, height: 3.5)
                                        Circle().fill(Color.green.opacity(0.8)).frame(width: 3.5, height: 3.5)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.top, 5)
                                    
                                    Spacer()
                                    
                                    // Mini desktop dock glow
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 70, height: 5)
                                        .blur(radius: 1)
                                        .padding(.bottom, 5)
                                }
                                .frame(width: 167, height: 104)
                            )
                        
                        // Glass Glare Sheen Reflection
                        Path { path in
                            path.move(to: CGPoint(x: 10, y: 5))
                            path.addLine(to: CGPoint(x: 110, y: 5))
                            path.addLine(to: CGPoint(x: 40, y: 105))
                            path.addLine(to: CGPoint(x: 5, y: 105))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.01)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .allowsHitTesting(false)
                    }
                    
                    // Iconic Metallic Aluminum Chin
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.90), Color(white: 0.78)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 175, height: 18)
                        
                        // Apple logo silhouette
                        Image(systemName: "applelogo")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.35))
                    }
                }
            }
            .frame(width: 175, height: 155)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                NSWorkspace.shared.activateFileViewerSelecting([FileManager.default.homeDirectoryForCurrentUser])
            }
            .onTapGesture {
                AppState.shared.toggleQuickView(.monitor)
            }
            .help("Layar iMac: Klik untuk melihat info Mac & akses cepat, klik 2x untuk buka Finder")
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
                    .fill(Color.black.opacity(0.42))
                    .frame(width: 64, height: 9)
                    .offset(y: 4)
                    .blur(radius: 2)
                
                // B. Crisp deep dark contact occlusion line (Zero gap between plinth and desk)
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 52, height: 4)
                    .offset(y: 1.5)
                
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
struct BoudoirEmeraldLampVector: View {
    let isOn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Brass Finial Tip
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.86, blue: 0.55), Color(red: 0.75, green: 0.58, blue: 0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 6, height: 6)
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.68, blue: 0.35))
                    .frame(width: 3, height: 4)
                    .offset(y: 3)
            }
            .offset(y: 2)
            .zIndex(5)
            
            // Fluted / Scalloped Bell Shade
            ZStack(alignment: .bottom) {
                // Main Fluted Shade Trapezoid / Bell
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 0))
                    path.addLine(to: CGPoint(x: 52, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 68, y: 46), control: CGPoint(x: 62, y: 22))
                    path.addLine(to: CGPoint(x: 4, y: 46))
                    path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 10, y: 22))
                    path.closeSubpath()
                }
                .fill(
                    isOn ?
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.96, blue: 0.82),
                            Color(red: 1.0, green: 0.88, blue: 0.60),
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
                .shadow(color: isOn ? Color.yellow.opacity(0.4) : Color.black.opacity(0.2), radius: isOn ? 6 : 2, y: 2)
                
                // Pleated Vertical Ribbing on Shade
                HStack(spacing: 7) {
                    ForEach(0..<7, id: \.self) { _ in
                        Rectangle()
                            .fill(
                                isOn ?
                                Color(red: 0.92, green: 0.74, blue: 0.38).opacity(0.4) :
                                Color.black.opacity(0.10)
                            )
                            .frame(width: 1, height: 42)
                    }
                }
                
                // Scalloped Bottom Hem Trim (Antique Gold piping)
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { _ in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.92, green: 0.80, blue: 0.48), Color(red: 0.72, green: 0.54, blue: 0.26)],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                            .frame(width: 8.5, height: 5)
                            .offset(y: 2)
                    }
                }
                .frame(width: 68)
            }
            .frame(width: 72, height: 48)
            
            // Brass Neck Collar with Dual Pull Chains
            ZStack {
                // Brass Collar Ring
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.96, green: 0.88, blue: 0.60), Color(red: 0.76, green: 0.58, blue: 0.28)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 14, height: 6)
                
                // Left & Right Brass Pull Chains
                HStack(spacing: 24) {
                    VStack(spacing: 1.5) {
                        ForEach(0..<5, id: \.self) { _ in
                            Circle().fill(Color(red: 0.88, green: 0.74, blue: 0.38)).frame(width: 1.8, height: 1.8)
                        }
                        Circle().fill(Color(red: 0.95, green: 0.82, blue: 0.44)).frame(width: 3.5, height: 3.5)
                    }
                    VStack(spacing: 1.5) {
                        ForEach(0..<6, id: \.self) { _ in
                            Circle().fill(Color(red: 0.88, green: 0.74, blue: 0.38)).frame(width: 1.8, height: 1.8)
                        }
                        Circle().fill(Color(red: 0.95, green: 0.82, blue: 0.44)).frame(width: 3.5, height: 3.5)
                    }
                }
                .offset(y: 8)
            }
            .offset(y: -1)
            .zIndex(4)
            
            // Ribbed Emerald Ceramic Urn Body
            ZStack {
                // Urn Shadow
                Ellipse()
                    .fill(Color.black.opacity(0.20))
                    .frame(width: 28, height: 36)
                    .blur(radius: 2)
                    .offset(y: 2)
                
                // Deep Emerald Green Ceramic / Glass Body
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.55, blue: 0.38),
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
                
                // Glossy Glass Reflection Highlight
                Path { path in
                    path.addArc(center: CGPoint(x: 10, y: 16), radius: 8, startAngle: .degrees(130), endAngle: .degrees(230), clockwise: false)
                }
                .stroke(Color.white.opacity(0.65), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                
                // Subtle Vertical Fluting / Ribs on Urn
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(0.18))
                            .frame(width: 1, height: 26)
                    }
                }
            }
            .frame(width: 32, height: 38)
            .offset(y: 2)
            
            // Stepped Tiered Brass Pedestal Base
            VStack(spacing: 1) {
                // Upper Brass Ring Collar
                RoundedRectangle(cornerRadius: 1)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.86, blue: 0.55), Color(red: 0.72, green: 0.54, blue: 0.26)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: 18, height: 4)
                
                // Middle Stepped Disc
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.92, green: 0.82, blue: 0.50), Color(red: 0.68, green: 0.48, blue: 0.22)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: 28, height: 5)
                
                // Heavy Wide Beveled Base Plinth
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.96, green: 0.88, blue: 0.58), Color(red: 0.70, green: 0.52, blue: 0.24)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 38, height: 6)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
            }
            .offset(y: 1)
        }
        .frame(width: 76, height: 122)
    }
}



// MARK: - Animated Floating Music Notes
struct FloatingNotesView: View {
    var body: some View {
        HStack(spacing: 5) {
            Text("♪")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(SANSColors.lime)
                .offset(y: -10)
            
            Text("♫")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.yellow)
                .offset(y: -17)
            
            Text("♩")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(SANSColors.pink)
                .offset(y: -12)
        }
        .shadow(color: Color.yellow.opacity(0.8), radius: 3)
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
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                appState.showSpotifyPopup.toggle()
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
