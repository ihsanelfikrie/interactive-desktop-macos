import SwiftUI
import AppKit

// MARK: - Native Ergonomic Sandal Sole Shape (Right Foot Vector Silhouette)
struct SandalSoleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Start at heel center bottom: (0.50, 0.97)
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.97))
        
        // 1. Curve to outer heel: (0.50, 0.97) -> (0.80, 0.85)
        path.addCurve(
            to: CGPoint(x: w * 0.80, y: h * 0.85),
            control1: CGPoint(x: w * 0.68, y: h * 0.97),
            control2: CGPoint(x: w * 0.78, y: h * 0.94)
        )
        
        // 2. Outer foot to ball of pinky toe: (0.80, 0.85) -> (0.88, 0.35)
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.35),
            control1: CGPoint(x: w * 0.82, y: h * 0.68),
            control2: CGPoint(x: w * 0.86, y: h * 0.50)
        )
        
        // 3. Pinky toe turn to top-right: (0.88, 0.35) -> (0.75, 0.12)
        path.addCurve(
            to: CGPoint(x: w * 0.75, y: h * 0.12),
            control1: CGPoint(x: w * 0.90, y: h * 0.22),
            control2: CGPoint(x: w * 0.84, y: h * 0.14)
        )
        
        // 4. Across toes slanting upward to big toe: (0.75, 0.12) -> (0.35, 0.04)
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.04),
            control1: CGPoint(x: w * 0.64, y: h * 0.08),
            control2: CGPoint(x: w * 0.48, y: h * 0.04)
        )
        
        // 5. Big toe turn to inner edge: (0.35, 0.04) -> (0.16, 0.22)
        path.addCurve(
            to: CGPoint(x: w * 0.16, y: h * 0.22),
            control1: CGPoint(x: w * 0.24, y: h * 0.04),
            control2: CGPoint(x: w * 0.16, y: h * 0.12)
        )
        
        // 6. Inner ball to inner arch: (0.16, 0.22) -> (0.25, 0.60)
        path.addCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.60),
            control1: CGPoint(x: w * 0.16, y: h * 0.36),
            control2: CGPoint(x: w * 0.22, y: h * 0.48)
        )
        
        // 7. Inner arch curve to heel: (0.25, 0.60) -> (0.22, 0.86)
        path.addCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.86),
            control1: CGPoint(x: w * 0.26, y: h * 0.70),
            control2: CGPoint(x: w * 0.22, y: h * 0.78)
        )
        
        // 8. Inner heel back into bottom-center: (0.22, 0.86) -> (0.50, 0.97)
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.97),
            control1: CGPoint(x: w * 0.22, y: h * 0.94),
            control2: CGPoint(x: w * 0.32, y: h * 0.97)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Single Sandal Jepit Vector Component (Swallow Style)
struct SingleSandalJepitView: View {
    let isLeft: Bool
    
    // Iconic Swallow Royal Blue & White palette
    private let primaryBlue = Color(red: 0.08, green: 0.34, blue: 0.82)
    private let strapDeepBlue = Color(red: 0.06, green: 0.26, blue: 0.70)
    private let strapHighlightBlue = Color(red: 0.38, green: 0.66, blue: 0.98)
    private let soleRimBlue = Color(red: 0.05, green: 0.22, blue: 0.58)
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // 1. Lower Tread Layer (creates realistic rubber sole thickness)
                SandalSoleShape()
                    .fill(soleRimBlue)
                    .offset(y: 3.5)
                
                // 2. White Rubber Midsole Line
                SandalSoleShape()
                    .fill(Color.white.opacity(0.85))
                    .offset(y: 1.5)
                
                // 3. Top Footbed (Clean Off-White Rubber)
                SandalSoleShape()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.98), Color(white: 0.93)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        SandalSoleShape()
                            .stroke(primaryBlue, lineWidth: 1.5)
                    )
                
                // 4. Subtle Inner Footbed Decorative Contour
                SandalSoleShape()
                    .stroke(primaryBlue.opacity(0.35), lineWidth: 0.8)
                    .scaleEffect(0.90)
                
                // 5. Classic Swallow Heel Medallion (Circular Brand Emboss)
                let heelX = w * 0.50
                let heelY = h * 0.80
                Circle()
                    .stroke(primaryBlue.opacity(0.40), lineWidth: 1.2)
                    .frame(width: w * 0.30, height: w * 0.30)
                    .position(x: heelX, y: heelY)
                
                Circle()
                    .fill(primaryBlue.opacity(0.12))
                    .frame(width: w * 0.22, height: w * 0.22)
                    .position(x: heelX, y: heelY)
                
                // Subtle Swallow bird silhouette / initial icon in center
                Image(systemName: "bird.fill")
                    .font(.system(size: w * 0.11))
                    .foregroundColor(primaryBlue.opacity(0.55))
                    .position(x: heelX, y: heelY)
                
                // 6. Rubber Y-Strap (Tali Jepit) with 3D Cylindrical Highlights
                let toePlugPos = CGPoint(x: w * 0.38, y: h * 0.24)
                let innerAnchor = CGPoint(x: w * 0.20, y: h * 0.56)
                let outerAnchor = CGPoint(x: w * 0.84, y: h * 0.56)
                
                // Outer Strap Shadow
                Path { p in
                    p.move(to: toePlugPos)
                    p.addCurve(
                        to: outerAnchor,
                        control1: CGPoint(x: w * 0.62, y: h * 0.28),
                        control2: CGPoint(x: w * 0.78, y: h * 0.42)
                    )
                }
                .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: 5.5, lineCap: .round))
                .offset(x: 1.5, y: 2)
                
                // Inner Strap Shadow
                Path { p in
                    p.move(to: toePlugPos)
                    p.addCurve(
                        to: innerAnchor,
                        control1: CGPoint(x: w * 0.26, y: h * 0.30),
                        control2: CGPoint(x: w * 0.20, y: h * 0.44)
                    )
                }
                .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: 5.5, lineCap: .round))
                .offset(x: -1.5, y: 2)
                
                // Outer Strap Main Body
                Path { p in
                    p.move(to: toePlugPos)
                    p.addCurve(
                        to: outerAnchor,
                        control1: CGPoint(x: w * 0.62, y: h * 0.28),
                        control2: CGPoint(x: w * 0.78, y: h * 0.42)
                    )
                }
                .stroke(strapDeepBlue, style: StrokeStyle(lineWidth: 4.8, lineCap: .round))
                
                // Outer Strap 3D Specular Highlight Ridge
                Path { p in
                    p.move(to: toePlugPos)
                    p.addCurve(
                        to: outerAnchor,
                        control1: CGPoint(x: w * 0.62, y: h * 0.28),
                        control2: CGPoint(x: w * 0.78, y: h * 0.42)
                    )
                }
                .stroke(strapHighlightBlue, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                .offset(y: -0.6)
                
                // Inner Strap Main Body
                Path { p in
                    p.move(to: toePlugPos)
                    p.addCurve(
                        to: innerAnchor,
                        control1: CGPoint(x: w * 0.26, y: h * 0.30),
                        control2: CGPoint(x: w * 0.20, y: h * 0.44)
                    )
                }
                .stroke(strapDeepBlue, style: StrokeStyle(lineWidth: 4.8, lineCap: .round))
                
                // Inner Strap 3D Specular Highlight Ridge
                Path { p in
                    p.move(to: toePlugPos)
                    p.addCurve(
                        to: innerAnchor,
                        control1: CGPoint(x: w * 0.26, y: h * 0.30),
                        control2: CGPoint(x: w * 0.20, y: h * 0.44)
                    )
                }
                .stroke(strapHighlightBlue, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                .offset(y: -0.6)
                
                // 7. Toe Post Anchor Plug
                Circle()
                    .fill(strapDeepBlue)
                    .frame(width: w * 0.16, height: w * 0.16)
                    .position(toePlugPos)
                
                Circle()
                    .fill(strapHighlightBlue)
                    .frame(width: w * 0.09, height: w * 0.09)
                    .position(toePlugPos)
                    .offset(x: -0.5, y: -0.5)
            }
            .scaleEffect(x: isLeft ? -1 : 1, y: 1) // Mirrored for left foot
        }
    }
}

// MARK: - Native Sendal Jepit Pair (With Floor Perspective & Chrome Launch Action)
public struct SandalJepitView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private func openChrome() {
        // 1. Try launching Google Chrome by Bundle Identifier
        if let chromeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
            NSWorkspace.shared.openApplication(at: chromeURL, configuration: NSWorkspace.OpenConfiguration())
            return
        }
        
        // 2. Direct Applications path
        let chromeAppPath = "/Applications/Google Chrome.app"
        if FileManager.default.fileExists(atPath: chromeAppPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: chromeAppPath))
            return
        }
        
        // 3. Fallback: Google Chrome custom URI scheme
        if let schemeURL = URL(string: "googlechrome://"), NSWorkspace.shared.open(schemeURL) {
            return
        }
        
        // 4. Final Fallback: Default web browser to Google
        if let defaultWeb = URL(string: "https://www.google.com") {
            NSWorkspace.shared.open(defaultWeb)
        }
    }
    
    public var body: some View {
        let isHovered = appState.isHoveringSandal
        
        ZStack {
            // A Pair of Swallow Sandal Jepit casually positioned side-by-side on the grass floor
            HStack(spacing: 7) {
                // Left Sandal (Slightly tilted inward -10 deg)
                SingleSandalJepitView(isLeft: true)
                    .frame(width: 28, height: 66)
                    .rotationEffect(.degrees(-10))
                    .offset(y: 2)
                
                // Right Sandal (Slightly tilted outward +7 deg, casually shifted)
                SingleSandalJepitView(isLeft: false)
                    .frame(width: 28, height: 66)
                    .rotationEffect(.degrees(7))
                    .offset(y: -2)
            }
            // Floor Perspective Projection (Identical 60° floor tilt & 0.45 perspective as the room floor)
            .rotation3DEffect(
                .degrees(60),
                axis: (x: 1, y: 0, z: 0),
                anchor: .center,
                perspective: 0.45
            )
            // Realistic Ground Shadow onto Grass Floor
            .shadow(
                color: Color.black.opacity(isHovered ? 0.48 : 0.38),
                radius: isHovered ? 5 : 3.5,
                x: 0,
                y: isHovered ? 6 : 4
            )
            .scaleEffect(isHovered ? 1.08 : 1.0)
            .offset(y: isHovered ? -2 : 0)
            .animation(.spring(response: 0.32, dampingFraction: 0.75), value: isHovered)
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            appState.isHoveringSandal = hovering
        }
        .onTapGesture {
            openChrome()
        }
        .contextMenu {
            Button("Buka Google Chrome") {
                openChrome()
            }
            Button("Buka Tab Baru (Google.com)") {
                if let url = URL(string: "https://www.google.com") {
                    NSWorkspace.shared.open(url)
                }
            }
            Divider()
            Button("Buka YouTube") {
                if let url = URL(string: "https://www.youtube.com") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .help("Sandal Jepit: Klik untuk membuka Google Chrome")
    }
}
