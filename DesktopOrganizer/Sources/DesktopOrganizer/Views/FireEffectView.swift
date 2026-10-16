import SwiftUI
import AppKit

// MARK: - Ultra-Lightweight Batched Asset Fire Effect (GPU Metal Canvas, 30 FPS Cap)
public struct AssetFireEffectView: View {
    @ObservedObject var appState = AppState.shared
    let flameHeight: CGFloat
    let showBaseFlames: Bool
    let showTopFlames: Bool
    
    public init(flameHeight: CGFloat = 28, showBaseFlames: Bool = true, showTopFlames: Bool = true) {
        self.flameHeight = flameHeight
        self.showBaseFlames = showBaseFlames
        self.showTopFlames = showTopFlames
    }
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: appState.isLowPower ? 1.0 / 20.0 : 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                guard appState.isWindowVisible && appState.isAppActive else { return }
                let t = timeline.date.timeIntervalSinceReferenceDate
                let w = size.width
                let h = size.height
                guard w > 4 && h > 4 else { return }
                
                // 1. Lightweight Ambient Glow
                let glowRect = CGRect(x: -4, y: -4, width: w + 8, height: h + 8)
                context.fill(
                    Path(roundedRect: glowRect, cornerRadius: 6),
                    with: .color(Color(red: 1.0, green: 0.35, blue: 0.05).opacity(0.18))
                )
                
                // 2. Base Flames (Bottom of asset - Batched in 2 GPU Draw Calls)
                if showBaseFlames {
                    drawFlamesRow(
                        context: &context,
                        width: w,
                        baseY: h + 1,
                        flameH: flameHeight,
                        time: t,
                        seedOffset: 0.0
                    )
                }
                
                // 3. Top Flames (Top of asset - Batched in 2 GPU Draw Calls)
                if showTopFlames {
                    drawFlamesRow(
                        context: &context,
                        width: w,
                        baseY: 2,
                        flameH: flameHeight * 0.82,
                        time: t,
                        seedOffset: 2.718
                    )
                }
                
                // 4. Subtle Rising Sparks (Batched in 1 GPU Draw Call)
                let emberCount = min(5, max(3, Int(w / 36)))
                var sparksPath = Path()
                for k in 0..<emberCount {
                    let seed = Double(k) * 1.618
                    let cycle = (t * 0.85 + seed).truncatingRemainder(dividingBy: 1.0)
                    let prog = CGFloat(cycle)
                    
                    let emberX = CGFloat((k * 43) % Int(max(w - 6, 1))) + 3 + sin(CGFloat(t * 3.0 + seed * 3)) * 5
                    let emberY = h - prog * (h + flameHeight + 15)
                    let r: CGFloat = 1.3
                    
                    sparksPath.addEllipse(in: CGRect(x: emberX - r, y: emberY - r, width: r * 2, height: r * 2))
                }
                context.fill(
                    sparksPath,
                    with: .color(Color(red: 1.0, green: 0.88, blue: 0.30).opacity(0.75))
                )
            }
        }
    }
    
    // MARK: - Fast Batched Dual-Layer Flame Painter (Only 2 GPU Draw Calls Total)
    private func drawFlamesRow(
        context: inout GraphicsContext,
        width: CGFloat,
        baseY: CGFloat,
        flameH: CGFloat,
        time: TimeInterval,
        seedOffset: Double
    ) {
        let step = max(16.0, min(26.0, width / 5.0))
        let numFlames = max(2, Int(ceil(width / step)))
        let fw = step * 1.10
        
        var outerPath = Path()
        var corePath = Path()
        
        for i in 0..<numFlames {
            let fx = CGFloat(i) * step + (step * 0.5)
            let phase = time * 7.0 + Double(i) * 1.5 + seedOffset
            let sinP = sin(phase)
            let currentH = flameH * CGFloat(0.70 + 0.30 * sinP)
            let sway = CGFloat(sin(phase * 0.75)) * (fw * 0.30)
            
            // Outer Flame Tongue
            outerPath.move(to: CGPoint(x: fx - fw * 0.5, y: baseY))
            outerPath.addCurve(
                to: CGPoint(x: fx + sway, y: baseY - currentH),
                control1: CGPoint(x: fx - fw * 0.5, y: baseY - currentH * 0.45),
                control2: CGPoint(x: fx + sway * 0.5, y: baseY - currentH * 0.80)
            )
            outerPath.addCurve(
                to: CGPoint(x: fx + fw * 0.5, y: baseY),
                control1: CGPoint(x: fx + sway * 0.5, y: baseY - currentH * 0.80),
                control2: CGPoint(x: fx + fw * 0.5, y: baseY - currentH * 0.45)
            )
            outerPath.closeSubpath()
            
            // Core Flame Tongue
            let coreH = currentH * 0.55
            let coreW = fw * 0.55
            corePath.move(to: CGPoint(x: fx - coreW * 0.5, y: baseY))
            corePath.addCurve(
                to: CGPoint(x: fx + sway * 0.7, y: baseY - coreH),
                control1: CGPoint(x: fx - coreW * 0.5, y: baseY - coreH * 0.40),
                control2: CGPoint(x: fx + sway * 0.4, y: baseY - coreH * 0.75)
            )
            corePath.addCurve(
                to: CGPoint(x: fx + coreW * 0.5, y: baseY),
                control1: CGPoint(x: fx + sway * 0.4, y: baseY - coreH * 0.75),
                control2: CGPoint(x: fx + coreW * 0.5, y: baseY - coreH * 0.40)
            )
            corePath.closeSubpath()
        }
        
        // Single Draw Call 1: All Outer Flames
        context.fill(
            outerPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.95, green: 0.18, blue: 0.04).opacity(0.88),
                    Color(red: 1.00, green: 0.48, blue: 0.06).opacity(0.85)
                ]),
                startPoint: CGPoint(x: width * 0.5, y: baseY),
                endPoint: CGPoint(x: width * 0.5, y: baseY - flameH)
            )
        )
        
        // Single Draw Call 2: All Core Flames
        context.fill(
            corePath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 1.00, green: 0.65, blue: 0.12),
                    Color(red: 1.00, green: 0.96, blue: 0.65).opacity(0.95)
                ]),
                startPoint: CGPoint(x: width * 0.5, y: baseY),
                endPoint: CGPoint(x: width * 0.5, y: baseY - flameH * 0.55)
            )
        )
    }
}

// MARK: - Burning Fire View Modifier (Zero Overhead when Inactive)
public struct BurningFireModifier: ViewModifier {
    let isActive: Bool
    let flameHeight: CGFloat
    let showBaseFlames: Bool
    let showTopFlames: Bool
    
    public init(isActive: Bool, flameHeight: CGFloat = 28, showBaseFlames: Bool = true, showTopFlames: Bool = true) {
        self.isActive = isActive
        self.flameHeight = flameHeight
        self.showBaseFlames = showBaseFlames
        self.showTopFlames = showTopFlames
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    AssetFireEffectView(
                        flameHeight: flameHeight,
                        showBaseFlames: showBaseFlames,
                        showTopFlames: showTopFlames
                    )
                    .allowsHitTesting(false)
                    .transition(.opacity)
                )
                .shadow(color: Color(red: 1.0, green: 0.35, blue: 0.05).opacity(0.65), radius: 8)
        } else {
            content
        }
    }
}

public extension View {
    func burningFire(
        isActive: Bool,
        flameHeight: CGFloat = 28,
        showBaseFlames: Bool = true,
        showTopFlames: Bool = true
    ) -> some View {
        self.modifier(BurningFireModifier(
            isActive: isActive,
            flameHeight: flameHeight,
            showBaseFlames: showBaseFlames,
            showTopFlames: showTopFlames
        ))
    }
}

// MARK: - Global Room Fire Atmosphere View (Single Unified Canvas, Fully Click-Through)
public struct RoomFireAtmosphereView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // 1. Static Ambient Glow Layer (Red-Orange Hue Over Whole Room)
                LinearGradient(
                    colors: [
                        Color(red: 0.86, green: 0.18, blue: 0.04).opacity(0.34),
                        Color(red: 1.00, green: 0.40, blue: 0.06).opacity(0.36),
                        Color(red: 0.68, green: 0.08, blue: 0.02).opacity(0.40)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.55, blue: 0.10).opacity(0.32),
                        Color(red: 0.90, green: 0.22, blue: 0.04).opacity(0.25),
                        Color(red: 0.30, green: 0.03, blue: 0.01).opacity(0.38)
                    ],
                    center: UnitPoint(x: 0.5, y: 0.88),
                    startRadius: 70,
                    endRadius: max(w, h) * 0.95
                )
                
                // Smoke gradient near ceiling
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.04, blue: 0.02).opacity(0.55),
                            Color(red: 0.35, green: 0.10, blue: 0.04).opacity(0.30),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: h * 0.25)
                    Spacer()
                }
                
                // 2. Single Unified Canvas: Floor Inferno + 25 Room Embers (Batched in 2 GPU Draw Calls)
                TimelineView(.animation(minimumInterval: appState.isLowPower ? 1.0 / 20.0 : 1.0 / 30.0)) { timeline in
                    Canvas { context, size in
                        guard appState.isWindowVisible && appState.isAppActive else { return }
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        let cw = size.width
                        let ch = size.height
                        
                        // Floor Inferno: Batch All Flames into 1 Path
                        let step: CGFloat = 36
                        let flameCount = Int(ceil(cw / step)) + 1
                        let fw = step * 1.4
                        var floorFlamesPath = Path()
                        
                        for i in 0..<flameCount {
                            let fx = CGFloat(i) * step
                            let phase = t * 6.5 + Double(i) * 1.3
                            let currentH: CGFloat = 60 + CGFloat(sin(phase) * 22.0)
                            let sway = CGFloat(sin(phase * 0.75)) * 8
                            
                            floorFlamesPath.move(to: CGPoint(x: fx - fw * 0.5, y: ch))
                            floorFlamesPath.addCurve(
                                to: CGPoint(x: fx + sway, y: ch - currentH),
                                control1: CGPoint(x: fx - fw * 0.5, y: ch - currentH * 0.45),
                                control2: CGPoint(x: fx + sway * 0.5, y: ch - currentH * 0.80)
                            )
                            floorFlamesPath.addCurve(
                                to: CGPoint(x: fx + fw * 0.5, y: ch),
                                control1: CGPoint(x: fx + sway * 0.5, y: ch - currentH * 0.80),
                                control2: CGPoint(x: fx + fw * 0.5, y: ch - currentH * 0.45)
                            )
                            floorFlamesPath.closeSubpath()
                        }
                        
                        context.fill(
                            floorFlamesPath,
                            with: .linearGradient(
                                Gradient(colors: [
                                    Color(red: 0.95, green: 0.20, blue: 0.04).opacity(0.85),
                                    Color(red: 1.00, green: 0.58, blue: 0.10).opacity(0.80),
                                    Color(red: 1.00, green: 0.90, blue: 0.40).opacity(0.60)
                                ]),
                                startPoint: CGPoint(x: cw * 0.5, y: ch),
                                endPoint: CGPoint(x: cw * 0.5, y: ch - 75)
                            )
                        )
                        
                        // Room Embers: Batch All Embers into 1 Path
                        let totalEmbers = 25
                        var embersPath = Path()
                        for k in 0..<totalEmbers {
                            let seed = Double(k) * 2.39996
                            let speed = 0.16 + (Double(k % 6) * 0.035)
                            let cycle = (t * speed + seed).truncatingRemainder(dividingBy: 1.0)
                            let prog = CGFloat(cycle)
                            
                            let startX = CGFloat((k * 137) % Int(max(cw, 100)))
                            let swayX = CGFloat(sin(Double(prog * 7.0) + seed * 4.0)) * 20.0
                            let emberX = startX + swayX
                            let emberY = ch - (prog * ch)
                            let r: CGFloat = 1.3
                            
                            embersPath.addEllipse(in: CGRect(x: emberX - r, y: emberY - r, width: r * 2, height: r * 2))
                        }
                        
                        context.fill(
                            embersPath,
                            with: .color(Color(red: 1.00, green: 0.72, blue: 0.20).opacity(0.75))
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}
