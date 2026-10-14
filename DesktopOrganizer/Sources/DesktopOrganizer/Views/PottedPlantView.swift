import SwiftUI
import AppKit

// MARK: - Tropical Potted Houseplant (Bird of Paradise / Strelitzia with Hardware CoreAnimation Sway)
public struct PottedPlantView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            // Pot dimensions & placement (Conical matte planter sitting on floor)
            let potW = w * 0.46
            let potH = h * 0.22
            let potX = w * 0.50
            let potY = h - (potH * 0.50)
            let potTopY = h - potH
            let soilCenterY = potTopY + (potH * 0.11)
            let clusterTopY = soilCenterY - (h * 0.14)
            
            ZStack(alignment: .top) {
                // 1. Natural Floor Contact Shadow
                Ellipse()
                    .fill(Color.black.opacity(0.36))
                    .frame(width: potW * 1.15, height: potH * 0.22)
                    .blur(radius: 4)
                    .position(x: potX, y: h - 2)
                
                // 2. Minimalist Conical Matte Ceramic Pot & Soil Container (Base - Static)
                ModernCeramicPot(potW: potW, potH: potH)
                    .position(x: potX, y: potY)
                
                // 3. Tall Clustered Basal Stalks rising directly out of the potting soil
                Path { path in
                    // Left outer stem base
                    path.move(to: CGPoint(x: potX - 7, y: soilCenterY))
                    path.addLine(to: CGPoint(x: potX - 5, y: clusterTopY))
                    
                    // Left inner stem base
                    path.move(to: CGPoint(x: potX - 3, y: soilCenterY))
                    path.addLine(to: CGPoint(x: potX - 2, y: clusterTopY))
                    
                    // Center stem base
                    path.move(to: CGPoint(x: potX, y: soilCenterY))
                    path.addLine(to: CGPoint(x: potX, y: clusterTopY))
                    
                    // Right inner stem base
                    path.move(to: CGPoint(x: potX + 3, y: soilCenterY))
                    path.addLine(to: CGPoint(x: potX + 2, y: clusterTopY))
                    
                    // Right outer stem base
                    path.move(to: CGPoint(x: potX + 7, y: soilCenterY))
                    path.addLine(to: CGPoint(x: potX + 5, y: clusterTopY))
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.24, blue: 0.11),
                            Color(red: 0.16, green: 0.36, blue: 0.15)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    ),
                    style: StrokeStyle(lineWidth: 4.2, lineCap: .round)
                )
                
                // 4. Potting soil root collar (Mulch mound embedding stems firmly into the soil)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.08, green: 0.05, blue: 0.03),
                                Color(red: 0.14, green: 0.10, blue: 0.07).opacity(0.85)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 16
                        )
                    )
                    .frame(width: 26, height: 8)
                    .position(x: potX, y: soilCenterY + 1)
                
                // 5. The 5 Tropical Stems & Upright Wavy Paddle Leaves (Hardware GPU CoreAnimation Sway)
                
                // Leaf 1: Lower-Left Mid Leaf (Arches out left, blade points upright-left)
                PlantBranchView(
                    stemEnd: CGPoint(x: w * 0.24, y: h * 0.38),
                    soilOrigin: CGPoint(x: potX - 5, y: clusterTopY),
                    controlPoint: CGPoint(x: w * 0.26, y: h * 0.54),
                    leafWidth: w * 0.44,
                    leafHeight: h * 0.38,
                    baseAngle: -28.0,
                    swayDelta: 2.8,
                    duration: 4.6,
                    appState: appState,
                    leafColorSheen: Color(red: 0.26, green: 0.54, blue: 0.24),
                    leafColorShadow: Color(red: 0.11, green: 0.32, blue: 0.13)
                )
                
                // Leaf 5: Lower-Right Mid Leaf (Arches out right, blade points upright-right)
                PlantBranchView(
                    stemEnd: CGPoint(x: w * 0.76, y: h * 0.40),
                    soilOrigin: CGPoint(x: potX + 5, y: clusterTopY),
                    controlPoint: CGPoint(x: w * 0.74, y: h * 0.56),
                    leafWidth: w * 0.43,
                    leafHeight: h * 0.38,
                    baseAngle: 30.0,
                    swayDelta: 2.7,
                    duration: 4.2,
                    appState: appState,
                    leafColorSheen: Color(red: 0.25, green: 0.52, blue: 0.23),
                    leafColorShadow: Color(red: 0.10, green: 0.30, blue: 0.12)
                )
                
                // Leaf 2: Upper-Left Tall Leaf (Rises high, blade points upright-left)
                PlantBranchView(
                    stemEnd: CGPoint(x: w * 0.34, y: h * 0.22),
                    soilOrigin: CGPoint(x: potX - 2, y: clusterTopY),
                    controlPoint: CGPoint(x: w * 0.36, y: h * 0.44),
                    leafWidth: w * 0.46,
                    leafHeight: h * 0.45,
                    baseAngle: -14.0,
                    swayDelta: 2.2,
                    duration: 5.5,
                    appState: appState,
                    leafColorSheen: Color(red: 0.29, green: 0.58, blue: 0.26),
                    leafColorShadow: Color(red: 0.13, green: 0.36, blue: 0.15)
                )
                
                // Leaf 4: Upper-Right Tall Leaf (Rises high, blade points upright-right)
                PlantBranchView(
                    stemEnd: CGPoint(x: w * 0.66, y: h * 0.23),
                    soilOrigin: CGPoint(x: potX + 2, y: clusterTopY),
                    controlPoint: CGPoint(x: w * 0.64, y: h * 0.45),
                    leafWidth: w * 0.45,
                    leafHeight: h * 0.44,
                    baseAngle: 16.0,
                    swayDelta: 2.1,
                    duration: 5.1,
                    appState: appState,
                    leafColorSheen: Color(red: 0.27, green: 0.56, blue: 0.25),
                    leafColorShadow: Color(red: 0.12, green: 0.34, blue: 0.14)
                )
                
                // Leaf 3: Center Top Crown Leaf (Majestic, highest upright leaf)
                PlantBranchView(
                    stemEnd: CGPoint(x: w * 0.50, y: h * 0.16),
                    soilOrigin: CGPoint(x: potX, y: clusterTopY),
                    controlPoint: CGPoint(x: w * 0.50, y: h * 0.40),
                    leafWidth: w * 0.45,
                    leafHeight: h * 0.47,
                    baseAngle: 2.0,
                    swayDelta: 1.6,
                    duration: 6.3,
                    appState: appState,
                    leafColorSheen: Color(red: 0.30, green: 0.62, blue: 0.28),
                    leafColorShadow: Color(red: 0.14, green: 0.39, blue: 0.17)
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                appState.plantSwayPhase = true
            }
        }
        .onDisappear {
            appState.plantSwayPhase = false
        }
    }
}

// MARK: - Plant Branch (Curved Long Stalk + Upright Wavy Leaf with Hardware CoreAnimation Sway)
struct PlantBranchView: View {
    let stemEnd: CGPoint
    let soilOrigin: CGPoint
    let controlPoint: CGPoint
    let leafWidth: CGFloat
    let leafHeight: CGFloat
    let baseAngle: Double
    let swayDelta: Double
    let duration: Double
    @ObservedObject var appState: AppState
    let leafColorSheen: Color
    let leafColorShadow: Color
    
    var body: some View {
        ZStack {
            // Elegant Slender Green Stem (Static)
            Path { path in
                path.move(to: soilOrigin)
                path.addQuadCurve(to: stemEnd, control: controlPoint)
            }
            .stroke(
                LinearGradient(
                    colors: [
                        Color(red: 0.11, green: 0.28, blue: 0.12),
                        Color(red: 0.18, green: 0.40, blue: 0.18),
                        Color(red: 0.14, green: 0.34, blue: 0.15)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                ),
                style: StrokeStyle(lineWidth: 3.8, lineCap: .round)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 2, y: 1)
            
            // Broad Tropical Leaf Paddle with undulating edges (Hardware GPU CoreAnimation rotation)
            TropicalLeafPaddle(
                width: leafWidth,
                height: leafHeight,
                colorSheen: leafColorSheen,
                colorShadow: leafColorShadow
            )
            .rotationEffect(
                .degrees(appState.plantSwayPhase ? (baseAngle + swayDelta) : (baseAngle - swayDelta)),
                anchor: .bottom
            )
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: appState.plantSwayPhase
            )
            .position(stemEnd)
        }
    }
}

// MARK: - Tropical Leaf Paddle (Detailed Botanical Wavy Contours & Vein Fold)
struct TropicalLeafPaddle: View {
    let width: CGFloat
    let height: CGFloat
    let colorSheen: Color
    let colorShadow: Color
    
    var body: some View {
        WavyTropicalLeafShape()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: colorSheen, location: 0.0),
                        .init(color: colorSheen.opacity(0.96), location: 0.49),
                        .init(color: colorShadow.opacity(0.94), location: 0.51),
                        .init(color: colorShadow, location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                // Prominent Central Leaf Midrib Vein
                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: height))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.04))
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.65, green: 0.82, blue: 0.42),
                            Color(red: 0.38, green: 0.64, blue: 0.28),
                            Color(red: 0.22, green: 0.45, blue: 0.18)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    ),
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0.5)
            )
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.20), radius: 3, y: 2.5)
    }
}

// MARK: - Wavy Tropical Leaf Contour (Pointed Paddle with Undulating Natural Margins)
struct WavyTropicalLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midX = rect.midX
        
        path.move(to: CGPoint(x: midX, y: h))
        
        // Left margin with organic wavy undulations (like reference image)
        path.addCurve(
            to: CGPoint(x: midX - w * 0.38, y: h * 0.74),
            control1: CGPoint(x: midX - w * 0.08, y: h * 0.90),
            control2: CGPoint(x: midX - w * 0.32, y: h * 0.84)
        )
        // First wavy crest & dip
        path.addCurve(
            to: CGPoint(x: midX - w * 0.48, y: h * 0.48),
            control1: CGPoint(x: midX - w * 0.44, y: h * 0.65),
            control2: CGPoint(x: midX - w * 0.52, y: h * 0.56)
        )
        // Second wavy crest
        path.addCurve(
            to: CGPoint(x: midX - w * 0.32, y: h * 0.22),
            control1: CGPoint(x: midX - w * 0.42, y: h * 0.38),
            control2: CGPoint(x: midX - w * 0.36, y: h * 0.28)
        )
        // Taper smoothly to sharp leaf tip
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX - w * 0.20, y: h * 0.12),
            control2: CGPoint(x: midX - w * 0.04, y: h * 0.03)
        )
        
        // Right margin with mirrored organic wavy undulations
        path.addCurve(
            to: CGPoint(x: midX + w * 0.32, y: h * 0.22),
            control1: CGPoint(x: midX + w * 0.04, y: h * 0.03),
            control2: CGPoint(x: midX + w * 0.20, y: h * 0.12)
        )
        // Second wavy crest
        path.addCurve(
            to: CGPoint(x: midX + w * 0.48, y: h * 0.48),
            control1: CGPoint(x: midX + w * 0.36, y: h * 0.28),
            control2: CGPoint(x: midX + w * 0.42, y: h * 0.38)
        )
        // First wavy crest
        path.addCurve(
            to: CGPoint(x: midX + w * 0.38, y: h * 0.74),
            control1: CGPoint(x: midX + w * 0.52, y: h * 0.56),
            control2: CGPoint(x: midX + w * 0.44, y: h * 0.65)
        )
        // Return to leaf stem base
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX + w * 0.32, y: h * 0.84),
            control2: CGPoint(x: midX + w * 0.08, y: h * 0.90)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Minimalist Conical Matte Ceramic Pot (Matching Reference)
struct ModernCeramicPot: View {
    let potW: CGFloat
    let potH: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            // Tapered Matte Ceramic Body
            Path { path in
                let topW = potW
                let btmW = potW * 0.72
                let xTopL: CGFloat = 0
                let xTopR = topW
                let xBtmL = (topW - btmW) / 2
                let xBtmR = xBtmL + btmW
                
                path.move(to: CGPoint(x: xTopL, y: potH * 0.10))
                path.addLine(to: CGPoint(x: xBtmL, y: potH))
                path.addLine(to: CGPoint(x: xBtmR, y: potH))
                path.addLine(to: CGPoint(x: xTopR, y: potH * 0.10))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.93, green: 0.92, blue: 0.89), // Sunlit matte cream-grey ceramic
                        Color(red: 0.86, green: 0.84, blue: 0.81),
                        Color(red: 0.73, green: 0.71, blue: 0.67)  // Soft ambient shaded depth
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: Color.black.opacity(0.24), radius: 5, x: -1, y: 3)
            
            // Rich Dark Potting Soil inside rim
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.14, green: 0.10, blue: 0.07),
                            Color(red: 0.22, green: 0.17, blue: 0.12)
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: potW * 0.44
                    )
                )
                .frame(width: potW * 0.94, height: potH * 0.20)
                .offset(y: potH * 0.02)
            
            // Subtle Ceramic Rim Lip
            Ellipse()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.85),
                            Color(red: 0.78, green: 0.76, blue: 0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.8
                )
                .frame(width: potW, height: potH * 0.22)
        }
        .frame(width: potW, height: potH)
    }
}
