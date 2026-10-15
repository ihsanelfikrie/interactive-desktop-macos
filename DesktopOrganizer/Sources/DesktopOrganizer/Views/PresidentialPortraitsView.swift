import SwiftUI
import AppKit

// MARK: - Indonesian Presidential Portrait Types
public enum PresidentialPortraitType {
    case president
    case vicePresident
    
    public var name: String {
        switch self {
        case .president: return "H. Prabowo Subianto"
        case .vicePresident: return "Gibran Rakabuming Raka"
        }
    }
    
    public var title: String {
        switch self {
        case .president: return "Presiden Republik Indonesia"
        case .vicePresident: return "Wakil Presiden RI"
        }
    }
    
    public var plateName: String {
        switch self {
        case .president: return "H. PRABOWO S."
        case .vicePresident: return "GIBRAN R. R."
        }
    }
    
    public var plateTitle: String {
        switch self {
        case .president: return "PRESIDEN RI"
        case .vicePresident: return "WAPRES RI"
        }
    }
}

// MARK: - Native Framed Presidential Portrait View (Flat Stylized Vector Art)
public struct PresidentialPortraitView: View {
    public let type: PresidentialPortraitType
    
    public init(type: PresidentialPortraitType) {
        self.type = type
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // 1. Soft Wall Cast Shadow
                RoundedRectangle(cornerRadius: 3.5)
                    .fill(Color.black.opacity(0.32))
                    .frame(width: w, height: h)
                    .blur(radius: 3)
                    .offset(x: 1, y: 2.5)
                
                // 2. Elegant Walnut Wood Outer Frame
                RoundedRectangle(cornerRadius: 3.5)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.32, green: 0.20, blue: 0.12),
                                Color(red: 0.22, green: 0.13, blue: 0.08),
                                Color(red: 0.16, green: 0.09, blue: 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3.5)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.black.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
                    .frame(width: w, height: h)
                
                // 3. Inner Metallic Gold Fillet Rim
                RoundedRectangle(cornerRadius: 2)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.84, blue: 0.52),
                                Color(red: 0.70, green: 0.56, blue: 0.30),
                                Color(red: 0.88, green: 0.76, blue: 0.44)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .frame(width: w - 5, height: h - 5)
                
                // 4. Archival Ivory Mat Board (Passe-partout)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(red: 0.96, green: 0.95, blue: 0.92))
                    .frame(width: w - 7.5, height: h - 7.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1.5)
                            .stroke(Color.black.opacity(0.18), lineWidth: 0.6)
                    )
                
                // 5. Official Photograph Inner Canvas
                let photoW = w - 12
                let photoH = h - 20
                
                ZStack {
                    // Studio Portrait Art
                    Canvas { ctx, size in
                        drawPortrait(ctx: ctx, size: size, type: type)
                    }
                    
                    // Glass Sheen Glare Reflection
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: photoW * 0.65, y: 0))
                        path.addLine(to: CGPoint(x: photoW * 0.15, y: photoH))
                        path.addLine(to: CGPoint(x: 0, y: photoH))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.white.opacity(0.01)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .allowsHitTesting(false)
                    
                    // Razor-thin top bevel catchlight
                    VStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.28))
                            .frame(height: 0.6)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
                .frame(width: photoW, height: photoH)
                .clipped()
                .overlay(Rectangle().stroke(Color.black.opacity(0.35), lineWidth: 0.6))
                .offset(y: -4)
                
                // 6. Polished Brass Nameplate Plaque at Bottom
                let plateW = w - 13
                let plateH: CGFloat = 8.5
                
                ZStack {
                    RoundedRectangle(cornerRadius: 1.2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.94, green: 0.84, blue: 0.54),
                                    Color(red: 0.76, green: 0.62, blue: 0.34)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 1.2)
                                .stroke(Color(red: 0.55, green: 0.42, blue: 0.22), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.22), radius: 1, y: 0.6)
                    
                    VStack(spacing: 0.5) {
                        Text(type.plateName)
                            .font(.system(size: 4.8, weight: .black))
                            .foregroundColor(Color(red: 0.16, green: 0.11, blue: 0.05))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        Text(type.plateTitle)
                            .font(.system(size: 3.8, weight: .bold))
                            .foregroundColor(Color(red: 0.35, green: 0.24, blue: 0.10))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 1.5)
                }
                .frame(width: plateW, height: plateH)
                .position(x: w * 0.5, y: h - 7.5)
            }
            .help("\(type.title): \(type.name)")
        }
    }
}

// MARK: - Native Vector Portrait Painter
extension PresidentialPortraitView {
    private func drawPortrait(ctx: GraphicsContext, size: CGSize, type: PresidentialPortraitType) {
        let w = size.width
        let h = size.height
        
        // 1. Warm Presidential Studio Backdrop (Gradient)
        let bgRect = CGRect(origin: .zero, size: size)
        ctx.fill(
            Path(bgRect),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.52, green: 0.32, blue: 0.18),
                    Color(red: 0.36, green: 0.22, blue: 0.12),
                    Color(red: 0.22, green: 0.13, blue: 0.07)
                ]),
                startPoint: CGPoint(x: w * 0.6, y: 0),
                endPoint: CGPoint(x: w * 0.4, y: h)
            )
        )
        
        // 2. Draped Indonesian National Flag (Bendera Merah Putih) in Background Left
        var redFlagPath = Path()
        redFlagPath.move(to: CGPoint(x: 0, y: 0))
        redFlagPath.addLine(to: CGPoint(x: w * 0.38, y: 0))
        redFlagPath.addCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.48),
            control1: CGPoint(x: w * 0.34, y: h * 0.16),
            control2: CGPoint(x: w * 0.30, y: h * 0.32)
        )
        redFlagPath.addLine(to: CGPoint(x: 0, y: h * 0.40))
        redFlagPath.closeSubpath()
        
        ctx.fill(
            redFlagPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.88, green: 0.14, blue: 0.16),
                    Color(red: 0.72, green: 0.10, blue: 0.12)
                ]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: w * 0.38, y: h * 0.48)
            )
        )
        
        var whiteFlagPath = Path()
        whiteFlagPath.move(to: CGPoint(x: 0, y: h * 0.40))
        whiteFlagPath.addLine(to: CGPoint(x: w * 0.28, y: h * 0.48))
        whiteFlagPath.addCurve(
            to: CGPoint(x: w * 0.20, y: h * 0.82),
            control1: CGPoint(x: w * 0.26, y: h * 0.60),
            control2: CGPoint(x: w * 0.22, y: h * 0.72)
        )
        whiteFlagPath.addLine(to: CGPoint(x: 0, y: h * 0.75))
        whiteFlagPath.closeSubpath()
        
        ctx.fill(
            whiteFlagPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.95),
                    Color(red: 0.82, green: 0.81, blue: 0.79)
                ]),
                startPoint: CGPoint(x: 0, y: h * 0.40),
                endPoint: CGPoint(x: w * 0.28, y: h * 0.82)
            )
        )
        
        // 3. Figures (Suit, Shirt, Tie, Head, Hair/Peci, and Clean Faceless Flat Art)
        switch type {
        case .president:
            drawPresident(ctx: ctx, w: w, h: h)
        case .vicePresident:
            drawVicePresident(ctx: ctx, w: w, h: h)
        }
    }
    
    // MARK: - President H. Prabowo Subianto (Faceless Minimalist Flat Art with Black Peci)
    private func drawPresident(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        let headCenterX = w * 0.52
        let headCenterY = h * 0.44
        let headW = w * 0.46
        let headH = h * 0.40
        
        // 1. Formal Black Suit Jacket (Broad, Dignified Presidential Shoulders)
        var suitPath = Path()
        suitPath.move(to: CGPoint(x: w * 0.02, y: h))
        suitPath.addLine(to: CGPoint(x: headCenterX - (headW * 0.65), y: h * 0.62))
        suitPath.addLine(to: CGPoint(x: headCenterX - (headW * 0.24), y: h * 0.59))
        suitPath.addLine(to: CGPoint(x: headCenterX, y: h * 0.68))
        suitPath.addLine(to: CGPoint(x: headCenterX + (headW * 0.24), y: h * 0.59))
        suitPath.addLine(to: CGPoint(x: headCenterX + (headW * 0.67), y: h * 0.63))
        suitPath.addLine(to: CGPoint(x: w * 0.98, y: h))
        suitPath.closeSubpath()
        
        ctx.fill(
            suitPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.16, green: 0.16, blue: 0.18),
                    Color(red: 0.08, green: 0.08, blue: 0.10)
                ]),
                startPoint: CGPoint(x: headCenterX, y: h * 0.59),
                endPoint: CGPoint(x: headCenterX, y: h)
            )
        )
        
        // Suit Lapels (Left & Right peak lapels with subtle shadow)
        var leftLapel = Path()
        leftLapel.move(to: CGPoint(x: headCenterX - (headW * 0.24), y: h * 0.59))
        leftLapel.addLine(to: CGPoint(x: headCenterX - (headW * 0.45), y: h * 0.68))
        leftLapel.addLine(to: CGPoint(x: headCenterX - 4, y: h * 0.88))
        leftLapel.addLine(to: CGPoint(x: headCenterX - 2, y: h * 0.72))
        leftLapel.closeSubpath()
        ctx.fill(leftLapel, with: .color(Color(red: 0.12, green: 0.12, blue: 0.14)))
        
        var rightLapel = Path()
        rightLapel.move(to: CGPoint(x: headCenterX + (headW * 0.24), y: h * 0.59))
        rightLapel.addLine(to: CGPoint(x: headCenterX + (headW * 0.45), y: h * 0.68))
        rightLapel.addLine(to: CGPoint(x: headCenterX + 4, y: h * 0.88))
        rightLapel.addLine(to: CGPoint(x: headCenterX + 2, y: h * 0.72))
        rightLapel.closeSubpath()
        ctx.fill(rightLapel, with: .color(Color(red: 0.12, green: 0.12, blue: 0.14)))
        
        // 2. Crisp White Dress Shirt (V-neck opening)
        var shirtPath = Path()
        shirtPath.move(to: CGPoint(x: headCenterX - 11, y: h * 0.56))
        shirtPath.addLine(to: CGPoint(x: headCenterX + 11, y: h * 0.56))
        shirtPath.addLine(to: CGPoint(x: headCenterX + 6, y: h * 0.80))
        shirtPath.addLine(to: CGPoint(x: headCenterX - 6, y: h * 0.80))
        shirtPath.closeSubpath()
        ctx.fill(shirtPath, with: .color(Color(red: 0.98, green: 0.98, blue: 0.99)))
        
        // Pointed Shirt Collars
        var leftCollar = Path()
        leftCollar.move(to: CGPoint(x: headCenterX - 11, y: h * 0.56))
        leftCollar.addLine(to: CGPoint(x: headCenterX - 2.5, y: h * 0.67))
        leftCollar.addLine(to: CGPoint(x: headCenterX - 7.5, y: h * 0.67))
        leftCollar.closeSubpath()
        ctx.fill(leftCollar, with: .color(Color.white))
        
        var rightCollar = Path()
        rightCollar.move(to: CGPoint(x: headCenterX + 11, y: h * 0.56))
        rightCollar.addLine(to: CGPoint(x: headCenterX + 2.5, y: h * 0.67))
        rightCollar.addLine(to: CGPoint(x: headCenterX + 7.5, y: h * 0.67))
        rightCollar.closeSubpath()
        ctx.fill(rightCollar, with: .color(Color.white))
        
        // 3. Presidential Red Necktie (Dasi Merah Kenegaraan)
        // Knot
        var tieKnot = Path()
        tieKnot.move(to: CGPoint(x: headCenterX - 3.2, y: h * 0.63))
        tieKnot.addLine(to: CGPoint(x: headCenterX + 3.2, y: h * 0.63))
        tieKnot.addLine(to: CGPoint(x: headCenterX + 2.4, y: h * 0.69))
        tieKnot.addLine(to: CGPoint(x: headCenterX - 2.4, y: h * 0.69))
        tieKnot.closeSubpath()
        ctx.fill(
            tieKnot,
            with: .linearGradient(
                Gradient(colors: [Color(red: 0.90, green: 0.16, blue: 0.18), Color(red: 0.72, green: 0.10, blue: 0.12)]),
                startPoint: CGPoint(x: headCenterX, y: h * 0.63),
                endPoint: CGPoint(x: headCenterX, y: h * 0.69)
            )
        )
        // Tie Body
        var tieBody = Path()
        tieBody.move(to: CGPoint(x: headCenterX - 2.4, y: h * 0.69))
        tieBody.addLine(to: CGPoint(x: headCenterX + 2.4, y: h * 0.69))
        tieBody.addLine(to: CGPoint(x: headCenterX + 5.2, y: h))
        tieBody.addLine(to: CGPoint(x: headCenterX - 5.2, y: h))
        tieBody.closeSubpath()
        ctx.fill(
            tieBody,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.84, green: 0.12, blue: 0.15),
                    Color(red: 0.62, green: 0.08, blue: 0.10)
                ]),
                startPoint: CGPoint(x: headCenterX, y: h * 0.69),
                endPoint: CGPoint(x: headCenterX, y: h)
            )
        )
        
        // 4. Presidential Lapel Pin / Lencana Garuda (On Left Lapel)
        let pinX = headCenterX + 14
        let pinY = h * 0.71
        var ribbonRed = Path()
        ribbonRed.addRect(CGRect(x: pinX, y: pinY, width: 1.6, height: 6.0))
        ctx.fill(ribbonRed, with: .color(Color(red: 0.88, green: 0.12, blue: 0.15)))
        var ribbonWhite = Path()
        ribbonWhite.addRect(CGRect(x: pinX + 1.6, y: pinY, width: 1.6, height: 6.0))
        ctx.fill(ribbonWhite, with: .color(Color.white))
        ctx.fill(
            Path(ellipseIn: CGRect(x: pinX + 0.6, y: pinY + 6.4, width: 2.0, height: 2.0)),
            with: .color(Color(red: 0.95, green: 0.82, blue: 0.35))
        )
        
        // 5. Neck with Soft Jaw Shadow
        let neckRect = CGRect(x: headCenterX - 7, y: h * 0.49, width: 14, height: 12)
        ctx.fill(Path(neckRect), with: .color(Color(red: 0.82, green: 0.65, blue: 0.52)))
        var neckShadow = Path()
        neckShadow.move(to: CGPoint(x: headCenterX - 7, y: h * 0.49))
        neckShadow.addLine(to: CGPoint(x: headCenterX + 7, y: h * 0.49))
        neckShadow.addCurve(
            to: CGPoint(x: headCenterX, y: h * 0.54),
            control1: CGPoint(x: headCenterX + 4, y: h * 0.54),
            control2: CGPoint(x: headCenterX - 4, y: h * 0.54)
        )
        neckShadow.closeSubpath()
        ctx.fill(neckShadow, with: .color(Color(red: 0.72, green: 0.54, blue: 0.42).opacity(0.65)))
        
        // 6. Faceless Head Silhouette (Clean, Smooth, Flat Aesthetic)
        var facePath = Path()
        facePath.move(to: CGPoint(x: headCenterX - (headW * 0.44), y: headCenterY - (headH * 0.22)))
        facePath.addLine(to: CGPoint(x: headCenterX + (headW * 0.44), y: headCenterY - (headH * 0.22)))
        facePath.addCurve(
            to: CGPoint(x: headCenterX, y: headCenterY + (headH * 0.46)),
            control1: CGPoint(x: headCenterX + (headW * 0.46), y: headCenterY + (headH * 0.22)),
            control2: CGPoint(x: headCenterX + (headW * 0.22), y: headCenterY + (headH * 0.46))
        )
        facePath.addCurve(
            to: CGPoint(x: headCenterX - (headW * 0.44), y: headCenterY - (headH * 0.22)),
            control1: CGPoint(x: headCenterX - (headW * 0.22), y: headCenterY + (headH * 0.46)),
            control2: CGPoint(x: headCenterX - (headW * 0.46), y: headCenterY + (headH * 0.22))
        )
        facePath.closeSubpath()
        
        ctx.fill(
            facePath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.92, green: 0.76, blue: 0.64),
                    Color(red: 0.86, green: 0.69, blue: 0.56)
                ]),
                startPoint: CGPoint(x: headCenterX - 10, y: headCenterY - 10),
                endPoint: CGPoint(x: headCenterX + 10, y: headCenterY + 15)
            )
        )
        
        // Clean Minimalist Ears
        let leftEarRect = CGRect(x: headCenterX - (headW * 0.46), y: headCenterY - 4, width: 3.2, height: 8.5)
        let rightEarRect = CGRect(x: headCenterX + (headW * 0.46) - 3.2, y: headCenterY - 4, width: 3.2, height: 8.5)
        ctx.fill(Path(ellipseIn: leftEarRect), with: .color(Color(red: 0.85, green: 0.68, blue: 0.56)))
        ctx.fill(Path(ellipseIn: rightEarRect), with: .color(Color(red: 0.85, green: 0.68, blue: 0.56)))
        
        // (NOTE: NO EYES, NO NOSE, NO MOUTH — Clean Faceless Flat Art as requested!)
        
        // 7. Black Velvet Peci / Songkok (Presiden RI)
        let peciBottomY = headCenterY - (headH * 0.22)
        let peciTopY = h * 0.14
        var peciPath = Path()
        peciPath.move(to: CGPoint(x: headCenterX - (headW * 0.44), y: peciBottomY))
        peciPath.addLine(to: CGPoint(x: headCenterX - (headW * 0.38), y: peciTopY))
        peciPath.addCurve(
            to: CGPoint(x: headCenterX + (headW * 0.38), y: peciTopY),
            control1: CGPoint(x: headCenterX - (headW * 0.18), y: peciTopY - 2.5),
            control2: CGPoint(x: headCenterX + (headW * 0.18), y: peciTopY - 2.5)
        )
        peciPath.addLine(to: CGPoint(x: headCenterX + (headW * 0.44), y: peciBottomY))
        peciPath.addCurve(
            to: CGPoint(x: headCenterX - (headW * 0.44), y: peciBottomY),
            control1: CGPoint(x: headCenterX + (headW * 0.20), y: peciBottomY + 1.2),
            control2: CGPoint(x: headCenterX - (headW * 0.20), y: peciBottomY + 1.2)
        )
        peciPath.closeSubpath()
        
        ctx.fill(
            peciPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.17),
                    Color(red: 0.06, green: 0.06, blue: 0.07)
                ]),
                startPoint: CGPoint(x: headCenterX - 5, y: peciTopY),
                endPoint: CGPoint(x: headCenterX + 5, y: peciBottomY)
            )
        )
        
        // Velvet Crown Sheen
        var peciSheen = Path()
        peciSheen.move(to: CGPoint(x: headCenterX - (headW * 0.30), y: peciTopY + 1.5))
        peciSheen.addCurve(
            to: CGPoint(x: headCenterX + (headW * 0.30), y: peciTopY + 1.5),
            control1: CGPoint(x: headCenterX - (headW * 0.12), y: peciTopY - 0.5),
            control2: CGPoint(x: headCenterX + (headW * 0.12), y: peciTopY - 0.5)
        )
        ctx.stroke(peciSheen, with: .color(Color.white.opacity(0.14)), lineWidth: 1.0)
    }
    
    // MARK: - Vice President Gibran Rakabuming Raka (Faceless Minimalist Flat Art with Side-Parted Hair - NO SONGKOK)
    private func drawVicePresident(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
        let headCenterX = w * 0.50
        let headCenterY = h * 0.46
        let headW = w * 0.42
        let headH = h * 0.42
        
        // 1. Formal Black Suit Jacket (Tailored Cut)
        var suitPath = Path()
        suitPath.move(to: CGPoint(x: w * 0.04, y: h))
        suitPath.addLine(to: CGPoint(x: headCenterX - (headW * 0.62), y: h * 0.63))
        suitPath.addLine(to: CGPoint(x: headCenterX - (headW * 0.22), y: h * 0.60))
        suitPath.addLine(to: CGPoint(x: headCenterX, y: h * 0.70))
        suitPath.addLine(to: CGPoint(x: headCenterX + (headW * 0.22), y: h * 0.60))
        suitPath.addLine(to: CGPoint(x: headCenterX + (headW * 0.64), y: h * 0.63))
        suitPath.addLine(to: CGPoint(x: w * 0.96, y: h))
        suitPath.closeSubpath()
        
        ctx.fill(
            suitPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.15, green: 0.16, blue: 0.18),
                    Color(red: 0.07, green: 0.07, blue: 0.09)
                ]),
                startPoint: CGPoint(x: headCenterX, y: h * 0.60),
                endPoint: CGPoint(x: headCenterX, y: h)
            )
        )
        
        // Suit Lapels
        var leftLapel = Path()
        leftLapel.move(to: CGPoint(x: headCenterX - (headW * 0.22), y: h * 0.60))
        leftLapel.addLine(to: CGPoint(x: headCenterX - (headW * 0.42), y: h * 0.68))
        leftLapel.addLine(to: CGPoint(x: headCenterX - 3.5, y: h * 0.88))
        leftLapel.addLine(to: CGPoint(x: headCenterX - 1.5, y: h * 0.72))
        leftLapel.closeSubpath()
        ctx.fill(leftLapel, with: .color(Color(red: 0.11, green: 0.12, blue: 0.14)))
        
        var rightLapel = Path()
        rightLapel.move(to: CGPoint(x: headCenterX + (headW * 0.22), y: h * 0.60))
        rightLapel.addLine(to: CGPoint(x: headCenterX + (headW * 0.42), y: h * 0.68))
        rightLapel.addLine(to: CGPoint(x: headCenterX + 3.5, y: h * 0.88))
        rightLapel.addLine(to: CGPoint(x: headCenterX + 1.5, y: h * 0.72))
        rightLapel.closeSubpath()
        ctx.fill(rightLapel, with: .color(Color(red: 0.11, green: 0.12, blue: 0.14)))
        
        // 2. Crisp White Dress Shirt
        var shirtPath = Path()
        shirtPath.move(to: CGPoint(x: headCenterX - 10, y: h * 0.58))
        shirtPath.addLine(to: CGPoint(x: headCenterX + 10, y: h * 0.58))
        shirtPath.addLine(to: CGPoint(x: headCenterX + 5, y: h * 0.82))
        shirtPath.addLine(to: CGPoint(x: headCenterX - 5, y: h * 0.82))
        shirtPath.closeSubpath()
        ctx.fill(shirtPath, with: .color(Color(red: 0.98, green: 0.98, blue: 0.99)))
        
        // Shirt Collars
        var leftCollar = Path()
        leftCollar.move(to: CGPoint(x: headCenterX - 10, y: h * 0.58))
        leftCollar.addLine(to: CGPoint(x: headCenterX - 2.5, y: h * 0.68))
        leftCollar.addLine(to: CGPoint(x: headCenterX - 6.5, y: h * 0.68))
        leftCollar.closeSubpath()
        ctx.fill(leftCollar, with: .color(Color.white))
        
        var rightCollar = Path()
        rightCollar.move(to: CGPoint(x: headCenterX + 10, y: h * 0.58))
        rightCollar.addLine(to: CGPoint(x: headCenterX + 2.5, y: h * 0.68))
        rightCollar.addLine(to: CGPoint(x: headCenterX + 6.5, y: h * 0.68))
        rightCollar.closeSubpath()
        ctx.fill(rightCollar, with: .color(Color.white))
        
        // 3. Red Necktie
        // Knot
        var tieKnot = Path()
        tieKnot.move(to: CGPoint(x: headCenterX - 2.8, y: h * 0.65))
        tieKnot.addLine(to: CGPoint(x: headCenterX + 2.8, y: h * 0.65))
        tieKnot.addLine(to: CGPoint(x: headCenterX + 2.0, y: h * 0.70))
        tieKnot.addLine(to: CGPoint(x: headCenterX - 2.0, y: h * 0.70))
        tieKnot.closeSubpath()
        ctx.fill(
            tieKnot,
            with: .linearGradient(
                Gradient(colors: [Color(red: 0.90, green: 0.16, blue: 0.18), Color(red: 0.72, green: 0.10, blue: 0.12)]),
                startPoint: CGPoint(x: headCenterX, y: h * 0.65),
                endPoint: CGPoint(x: headCenterX, y: h * 0.70)
            )
        )
        // Tie Body
        var tieBody = Path()
        tieBody.move(to: CGPoint(x: headCenterX - 2.0, y: h * 0.70))
        tieBody.addLine(to: CGPoint(x: headCenterX + 2.0, y: h * 0.70))
        tieBody.addLine(to: CGPoint(x: headCenterX + 4.5, y: h))
        tieBody.addLine(to: CGPoint(x: headCenterX - 4.5, y: h))
        tieBody.closeSubpath()
        ctx.fill(
            tieBody,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.85, green: 0.14, blue: 0.16),
                    Color(red: 0.64, green: 0.09, blue: 0.11)
                ]),
                startPoint: CGPoint(x: headCenterX, y: h * 0.70),
                endPoint: CGPoint(x: headCenterX, y: h)
            )
        )
        
        // 4. Lapel Pin / Medal Ribbon (On Left Lapel)
        let pinX = headCenterX + 13
        let pinY = h * 0.71
        var ribbonRed = Path()
        ribbonRed.addRect(CGRect(x: pinX, y: pinY, width: 1.6, height: 6.0))
        ctx.fill(ribbonRed, with: .color(Color(red: 0.88, green: 0.12, blue: 0.15)))
        var ribbonWhite = Path()
        ribbonWhite.addRect(CGRect(x: pinX + 1.6, y: pinY, width: 1.6, height: 6.0))
        ctx.fill(ribbonWhite, with: .color(Color.white))
        ctx.fill(
            Path(ellipseIn: CGRect(x: pinX + 0.6, y: pinY + 6.4, width: 2.0, height: 2.0)),
            with: .color(Color(red: 0.95, green: 0.82, blue: 0.35))
        )
        
        // 5. Neck with Jaw Shadow
        let neckRect = CGRect(x: headCenterX - 6, y: h * 0.51, width: 12, height: 12)
        ctx.fill(Path(neckRect), with: .color(Color(red: 0.84, green: 0.67, blue: 0.54)))
        var neckShadow = Path()
        neckShadow.move(to: CGPoint(x: headCenterX - 6, y: h * 0.51))
        neckShadow.addLine(to: CGPoint(x: headCenterX + 6, y: h * 0.51))
        neckShadow.addCurve(
            to: CGPoint(x: headCenterX, y: h * 0.56),
            control1: CGPoint(x: headCenterX + 3.5, y: h * 0.56),
            control2: CGPoint(x: headCenterX - 3.5, y: h * 0.56)
        )
        neckShadow.closeSubpath()
        ctx.fill(neckShadow, with: .color(Color(red: 0.74, green: 0.56, blue: 0.44).opacity(0.65)))
        
        // 6. Faceless Head Silhouette (Slimmer, Youthful Modern Oval Jawline)
        var facePath = Path()
        facePath.move(to: CGPoint(x: headCenterX - (headW * 0.40), y: headCenterY - (headH * 0.28)))
        facePath.addLine(to: CGPoint(x: headCenterX + (headW * 0.40), y: headCenterY - (headH * 0.28)))
        facePath.addCurve(
            to: CGPoint(x: headCenterX, y: headCenterY + (headH * 0.46)),
            control1: CGPoint(x: headCenterX + (headW * 0.40), y: headCenterY + (headH * 0.24)),
            control2: CGPoint(x: headCenterX + (headW * 0.18), y: headCenterY + (headH * 0.46))
        )
        facePath.addCurve(
            to: CGPoint(x: headCenterX - (headW * 0.40), y: headCenterY - (headH * 0.28)),
            control1: CGPoint(x: headCenterX - (headW * 0.18), y: headCenterY + (headH * 0.46)),
            control2: CGPoint(x: headCenterX - (headW * 0.40), y: headCenterY + (headH * 0.24))
        )
        facePath.closeSubpath()
        
        ctx.fill(
            facePath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.93, green: 0.78, blue: 0.66),
                    Color(red: 0.87, green: 0.71, blue: 0.58)
                ]),
                startPoint: CGPoint(x: headCenterX - 8, y: headCenterY - 10),
                endPoint: CGPoint(x: headCenterX + 8, y: headCenterY + 15)
            )
        )
        
        // Clean Minimalist Ears
        let leftEarRect = CGRect(x: headCenterX - (headW * 0.43), y: headCenterY - 4, width: 3.2, height: 8.5)
        let rightEarRect = CGRect(x: headCenterX + (headW * 0.43) - 3.2, y: headCenterY - 4, width: 3.2, height: 8.5)
        ctx.fill(Path(ellipseIn: leftEarRect), with: .color(Color(red: 0.86, green: 0.69, blue: 0.57)))
        ctx.fill(Path(ellipseIn: rightEarRect), with: .color(Color(red: 0.86, green: 0.69, blue: 0.57)))
        
        // (NOTE: NO EYES, NO NOSE, NO MOUTH — Clean Faceless Flat Art as requested!)
        
        // 7. Neatly Combed Side-Parted Hair (NO SONGKOK!)
        let hairTopY = headCenterY - (headH * 0.52)
        let hairForeheadY = headCenterY - (headH * 0.26)
        var hairPath = Path()
        hairPath.move(to: CGPoint(x: headCenterX - (headW * 0.42), y: headCenterY - 3))
        hairPath.addCurve(
            to: CGPoint(x: headCenterX - (headW * 0.18), y: hairTopY),
            control1: CGPoint(x: headCenterX - (headW * 0.44), y: headCenterY - (headH * 0.35)),
            control2: CGPoint(x: headCenterX - (headW * 0.35), y: hairTopY + 1)
        )
        hairPath.addCurve(
            to: CGPoint(x: headCenterX + (headW * 0.42), y: headCenterY - 3),
            control1: CGPoint(x: headCenterX + (headW * 0.25), y: hairTopY - 0.5),
            control2: CGPoint(x: headCenterX + (headW * 0.44), y: headCenterY - (headH * 0.25))
        )
        hairPath.addCurve(
            to: CGPoint(x: headCenterX - 3, y: hairForeheadY - 2),
            control1: CGPoint(x: headCenterX + (headW * 0.28), y: hairForeheadY),
            control2: CGPoint(x: headCenterX + 5, y: hairForeheadY - 2)
        )
        hairPath.addCurve(
            to: CGPoint(x: headCenterX - (headW * 0.42), y: headCenterY - 3),
            control1: CGPoint(x: headCenterX - 8, y: hairForeheadY - 1),
            control2: CGPoint(x: headCenterX - (headW * 0.30), y: headCenterY - (headH * 0.18))
        )
        hairPath.closeSubpath()
        
        ctx.fill(
            hairPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.16, green: 0.16, blue: 0.18),
                    Color(red: 0.06, green: 0.06, blue: 0.08)
                ]),
                startPoint: CGPoint(x: headCenterX - 6, y: hairTopY),
                endPoint: CGPoint(x: headCenterX + 6, y: headCenterY)
            )
        )
        
        // Hair Sheen Arc
        var hairSheen = Path()
        hairSheen.move(to: CGPoint(x: headCenterX - (headW * 0.15), y: hairTopY + 1.5))
        hairSheen.addQuadCurve(
            to: CGPoint(x: headCenterX + (headW * 0.20), y: hairTopY + 2.0),
            control: CGPoint(x: headCenterX + 2, y: hairTopY + 0.5)
        )
        ctx.stroke(hairSheen, with: .color(Color.white.opacity(0.15)), lineWidth: 1.0)
    }
}
