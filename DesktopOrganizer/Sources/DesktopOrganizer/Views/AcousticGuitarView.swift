import SwiftUI
import AppKit

// MARK: - Dreadnought Acoustic Guitar View on Stand (Native Vector Illustration)
public struct AcousticGuitarView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // Soft floor shadow under stand tripod feet
                Ellipse()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: w * 0.86, height: h * 0.042)
                    .blur(radius: 6)
                    .position(x: w * 0.50, y: h * 0.982)
                
                Canvas { ctx, size in
                    drawAcousticGuitar(ctx: ctx, w: size.width, h: size.height)
                }
                .shadow(
                    color: Color.black.opacity(0.20),
                    radius: 5,
                    x: 2, y: 4
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { openMusicOrGarageBand() }
        .onTapGesture {
            appState.toggleQuickView(.acousticGuitar)
        }
    }
    
    private func openMusicOrGarageBand() {
        if let gb = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.garageband10") {
            NSWorkspace.shared.openApplication(at: gb, configuration: NSWorkspace.OpenConfiguration())
        } else if let m = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
            NSWorkspace.shared.openApplication(at: m, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Music.app"))
        }
    }
}

// MARK: - Acoustic Guitar & Stand Vector Drawing
// Natural depth layering:
//   1. Stand structure behind guitar (mast, neck yoke, legs, rear cradle arms)
//   2. Resonant Dreadnought Acoustic Body (Spruce top, warm golden gradient, multi-ply binding)
//   3. Rosette (concentric abalone and purfling rings) & Soundhole (dark interior)
//   4. Tortoiseshell teardrop pickguard
//   5. Rosewood belly bridge, bone saddle, and 6 bridge pins
//   6. Mahogany neck, dark rosewood fretboard, 20 frets, pearl dot inlays, bone nut
//   7. Symmetrical 3+3 acoustic headstock, mahogany/rosewood face, gold logo
//   8. 6 Tuning machines (3 left, 3 right chrome posts & butterbean buttons)
//   9. 6 Phosphor bronze acoustic strings running over nut to bridge pins
//  10. Front stand cradle rubber bumper prongs holding the bottom rim
private func drawAcousticGuitar(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
    }
    
    let neckCx = w * 0.50
    let standDark = Color(red: 0.12, green: 0.12, blue: 0.15)
    let standMid  = Color(red: 0.25, green: 0.25, blue: 0.29)
    let tubeW = max(3.5, w * 0.038)
    
    func strokeTube(from a: CGPoint, to b: CGPoint, lw: CGFloat) {
        var path = Path()
        path.move(to: a)
        path.addLine(to: b)
        ctx.stroke(path,
            with: .linearGradient(Gradient(colors: [standDark, standMid, standDark]),
                                  startPoint: a, endPoint: b),
            style: StrokeStyle(lineWidth: lw, lineCap: .round))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 1. STAND STRUCTURE (BEHIND GUITAR)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // Central vertical mast
    strokeTube(from: p(0.50, 0.36), to: p(0.50, 0.90), lw: tubeW * 1.05)
    
    // Height adjustment collar
    let collarRect = CGRect(x: w * 0.50 - tubeW * 0.75, y: h * 0.52 - 4, width: tubeW * 1.5, height: 8)
    ctx.fill(RoundedRectangle(cornerRadius: 2).path(in: collarRect), with: .color(standMid))
    
    // Neck cradle yoke (holds upper neck from behind)
    var yoke = Path()
    yoke.addArc(center: p(0.50, 0.39), radius: w * 0.145,
                startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
    ctx.stroke(yoke, with: .color(standDark), style: StrokeStyle(lineWidth: tubeW * 1.1, lineCap: .round))
    // Soft rubber foam end caps on yoke
    ctx.fill(Circle().path(in: CGRect(x: w * 0.355 - 4, y: h * 0.39 - 4, width: 8, height: 8)), with: .color(standDark))
    ctx.fill(Circle().path(in: CGRect(x: w * 0.645 - 4, y: h * 0.39 - 4, width: 8, height: 8)), with: .color(standDark))
    
    // Bottom cradle support arms (behind the acoustic body)
    strokeTube(from: p(0.31, 0.88), to: p(0.50, 0.90), lw: tubeW * 1.15)
    strokeTube(from: p(0.69, 0.88), to: p(0.50, 0.90), lw: tubeW * 1.15)
    
    // Tripod Legs extending down to floor (clear of dock)
    // Center/rear leg
    strokeTube(from: p(0.50, 0.89), to: p(0.50, 0.965), lw: tubeW * 1.05)
    // Left front leg
    strokeTube(from: p(0.50, 0.89), to: p(0.14, 0.972), lw: tubeW * 1.1)
    // Right front leg
    strokeTube(from: p(0.50, 0.89), to: p(0.86, 0.972), lw: tubeW * 1.1)
    
    // Rubber feet on floor
    let footR = w * 0.038
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.14 - footR, y: h * 0.972 - footR * 0.6, width: footR * 2, height: footR * 1.2)), with: .color(.black))
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.86 - footR, y: h * 0.972 - footR * 0.6, width: footR * 2, height: footR * 1.2)), with: .color(.black))
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.50 - footR * 0.8, y: h * 0.965 - footR * 0.5, width: footR * 1.6, height: footR)), with: .color(.black))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 2. DREADNOUGHT ACOUSTIC BODY
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Authentic Martin D-28 Dreadnought silhouette:
    // Full rounded upper shoulders, gentle waist, broad resonant lower bout
    let bodyHalf: [(CGFloat, CGFloat)] = [
        // Neck joint (14th fret)
        (0.500, 0.490), (0.575, 0.490),
        // Upper bout shoulder curve (generous Dreadnought radius)
        (0.635, 0.498), (0.690, 0.514), (0.740, 0.538), (0.772, 0.568), (0.780, 0.600),
        // Waist taper
        (0.770, 0.624), (0.748, 0.644), (0.732, 0.662), (0.735, 0.680),
        // Lower bout expansion
        (0.760, 0.705), (0.805, 0.732), (0.850, 0.765), (0.875, 0.800), (0.865, 0.835),
        // Bottom curve toward centerline
        (0.825, 0.860), (0.745, 0.874), (0.640, 0.878), (0.500, 0.878)
    ]
    
    var bodyPath = Path()
    if let first = bodyHalf.first {
        bodyPath.move(to: p(first.0, first.1))
        // Treble / right side
        for pt in bodyHalf.dropFirst() {
            bodyPath.addLine(to: p(pt.0, pt.1))
        }
        // Bass / left side (mirrored along centerline x = 0.500)
        for pt in bodyHalf.reversed().dropFirst() {
            let mirrorX = 0.500 - (pt.0 - 0.500)
            bodyPath.addLine(to: p(mirrorX, pt.1))
        }
        bodyPath.closeSubpath()
    }
    
    // Solid Sitka Spruce soundboard with warm natural honey/amber acoustic glow
    let spruceTop = Color(red: 0.96, green: 0.86, blue: 0.68)
    let spruceMid = Color(red: 0.90, green: 0.75, blue: 0.52)
    let spruceEdge = Color(red: 0.78, green: 0.58, blue: 0.36)
    let spruceDark = Color(red: 0.62, green: 0.42, blue: 0.24)
    
    ctx.fill(bodyPath, with: .radialGradient(
        Gradient(colors: [spruceTop, spruceMid, spruceEdge, spruceDark]),
        center: p(0.50, 0.66),
        startRadius: w * 0.05,
        endRadius: w * 0.44
    ))
    
    // Natural wood grain sheen (fine vertical line overlay)
    var grainPath = Path()
    for g in 0...24 {
        let gx = w * (0.16 + CGFloat(g) * 0.028)
        grainPath.move(to: CGPoint(x: gx, y: h * 0.50))
        grainPath.addLine(to: CGPoint(x: gx, y: h * 0.87))
    }
    ctx.stroke(grainPath, with: .color(Color(red: 0.55, green: 0.38, blue: 0.20).opacity(0.08)), style: StrokeStyle(lineWidth: 0.6))
    
    // Soft acoustic soundboard lacquer reflection (diagonal gloss sheen)
    var glossPath = Path()
    glossPath.move(to: p(0.24, 0.53))
    glossPath.addQuadCurve(to: p(0.35, 0.81), control: p(0.23, 0.67))
    ctx.stroke(glossPath, with: .color(Color.white.opacity(0.18)), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
    
    // Multi-ply Body Binding: Outer ivory cream rim + inner dark purfling pinstripe
    ctx.stroke(bodyPath, with: .color(Color(red: 0.96, green: 0.94, blue: 0.88)), style: StrokeStyle(lineWidth: 2.2))
    ctx.stroke(bodyPath, with: .color(Color(red: 0.22, green: 0.16, blue: 0.12)), style: StrokeStyle(lineWidth: 0.8))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 3. SOUNDHOLE & CONCENTRIC ROSETTE
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let shCx = w * 0.50
    let shCy = h * 0.608
    let shR  = w * 0.114
    
    // Rosette outer ring (Abalone / Pearl multi-colored purfling)
    let rosOuterR = shR * 1.48
    ctx.fill(Circle().path(in: CGRect(x: shCx - rosOuterR, y: shCy - rosOuterR, width: rosOuterR * 2, height: rosOuterR * 2)),
             with: .color(Color(red: 0.94, green: 0.92, blue: 0.86)))
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosOuterR, y: shCy - rosOuterR, width: rosOuterR * 2, height: rosOuterR * 2)),
               with: .color(Color(red: 0.30, green: 0.20, blue: 0.15)), style: StrokeStyle(lineWidth: 0.8))
    
    // Rosette middle abalone ring
    let rosMidR = shR * 1.35
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosMidR, y: shCy - rosMidR, width: rosMidR * 2, height: rosMidR * 2)),
               with: .color(Color(red: 0.72, green: 0.82, blue: 0.80)), style: StrokeStyle(lineWidth: 2.4))
    
    // Rosette inner rings
    let rosInnerR = shR * 1.18
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosInnerR, y: shCy - rosInnerR, width: rosInnerR * 2, height: rosInnerR * 2)),
               with: .color(Color(red: 0.28, green: 0.18, blue: 0.12)), style: StrokeStyle(lineWidth: 1.2))
    
    // Soundhole interior (deep dark resonant chamber)
    let shRect = CGRect(x: shCx - shR, y: shCy - shR, width: shR * 2, height: shR * 2)
    ctx.fill(Circle().path(in: shRect), with: .radialGradient(
        Gradient(colors: [
            Color(red: 0.08, green: 0.06, blue: 0.05),
            Color(red: 0.03, green: 0.02, blue: 0.02)
        ]),
        center: CGPoint(x: shCx - shR * 0.2, y: shCy - shR * 0.2),
        startRadius: 0,
        endRadius: shR
    ))
    ctx.stroke(Circle().path(in: shRect), with: .color(Color(red: 0.18, green: 0.12, blue: 0.08)), style: StrokeStyle(lineWidth: 1.2))
    
    // Visible inner back brace / interior wood label glimpsed inside soundhole
    let labelW = shR * 1.3
    let labelH = shR * 0.55
    let labelRect = CGRect(x: shCx - labelW / 2, y: shCy - labelH / 2, width: labelW, height: labelH)
    ctx.fill(RoundedRectangle(cornerRadius: 1).path(in: labelRect),
             with: .color(Color(red: 0.35, green: 0.26, blue: 0.18).opacity(0.55)))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 4. ACOUSTIC TORTOISESHELL TEARDROP PICKGUARD
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Classic Martin teardrop pickguard nestled snugly against the treble rosette
    var pgPath = Path()
    let pgTop = CGPoint(x: shCx + rosOuterR * 0.72, y: shCy - rosOuterR * 0.68)
    pgPath.move(to: pgTop)
    
    // Inner concave contour hugging rosette ring
    pgPath.addQuadCurve(
        to: CGPoint(x: shCx + rosOuterR * 0.72, y: shCy + rosOuterR * 0.70),
        control: CGPoint(x: shCx + rosOuterR * 0.98, y: shCy)
    )
    
    // Outer teardrop belly sweeping down & right
    pgPath.addCurve(
        to: CGPoint(x: shCx + w * 0.24, y: shCy + rosOuterR * 0.85),
        control1: CGPoint(x: shCx + rosOuterR * 0.70, y: shCy + rosOuterR * 1.05),
        control2: CGPoint(x: shCx + w * 0.18, y: shCy + rosOuterR * 1.15)
    )
    
    // Rounded teardrop lobe
    pgPath.addQuadCurve(
        to: CGPoint(x: shCx + w * 0.25, y: shCy + rosOuterR * 0.40),
        control: CGPoint(x: shCx + w * 0.28, y: shCy + rosOuterR * 0.65)
    )
    
    // Upper sweep back to starting top corner
    pgPath.addCurve(
        to: pgTop,
        control1: CGPoint(x: shCx + w * 0.23, y: shCy - rosOuterR * 0.20),
        control2: CGPoint(x: shCx + w * 0.15, y: shCy - rosOuterR * 0.65)
    )
    pgPath.closeSubpath()
    
    // Deep red-amber tortoiseshell pattern
    ctx.fill(pgPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.55, green: 0.18, blue: 0.08),
            Color(red: 0.35, green: 0.10, blue: 0.04),
            Color(red: 0.20, green: 0.05, blue: 0.02)
        ]),
        startPoint: p(0.54, 0.59),
        endPoint: p(0.68, 0.75)
    ))
    ctx.stroke(pgPath, with: .color(Color(red: 0.75, green: 0.30, blue: 0.12).opacity(0.4)), style: StrokeStyle(lineWidth: 0.8))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 5. ROSEWOOD BELLY BRIDGE, BONE SADDLE & BRIDGE PINS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let brW = w * 0.320
    let brH = h * 0.038
    let brX = neckCx - brW / 2
    let brY = h * 0.758
    
    // Traditional acoustic belly bridge silhouette
    var brPath = Path()
    brPath.move(to: CGPoint(x: brX, y: brY + brH * 0.30))
    // Left wing
    brPath.addQuadCurve(to: CGPoint(x: brX + brW * 0.22, y: brY + brH * 0.10),
                        control: CGPoint(x: brX + brW * 0.10, y: brY + brH * 0.18))
    // Central belly plateau
    brPath.addLine(to: CGPoint(x: brX + brW * 0.78, y: brY + brH * 0.10))
    // Right wing
    brPath.addQuadCurve(to: CGPoint(x: brX + brW, y: brY + brH * 0.30),
                        control: CGPoint(x: brX + brW * 0.90, y: brY + brH * 0.18))
    // Right bottom curve
    brPath.addQuadCurve(to: CGPoint(x: brX + brW * 0.82, y: brY + brH * 0.90),
                        control: CGPoint(x: brX + brW * 0.96, y: brY + brH * 0.75))
    // Bottom convex belly contour
    brPath.addQuadCurve(to: CGPoint(x: brX + brW * 0.18, y: brY + brH * 0.90),
                        control: CGPoint(x: neckCx, y: brY + brH * 1.05))
    // Left bottom curve
    brPath.addQuadCurve(to: CGPoint(x: brX, y: brY + brH * 0.30),
                        control: CGPoint(x: brX + brW * 0.04, y: brY + brH * 0.75))
    brPath.closeSubpath()
    
    // Dark East Indian Rosewood bridge timber
    ctx.fill(brPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.32, green: 0.20, blue: 0.15),
            Color(red: 0.22, green: 0.14, blue: 0.10),
            Color(red: 0.15, green: 0.09, blue: 0.06)
        ]),
        startPoint: CGPoint(x: brX, y: brY),
        endPoint: CGPoint(x: brX + brW, y: brY + brH)
    ))
    ctx.stroke(brPath, with: .color(Color(red: 0.42, green: 0.28, blue: 0.20)), style: StrokeStyle(lineWidth: 0.8))
    
    // Slanted compensated white bone saddle
    var saddlePath = Path()
    let sadX1 = brX + brW * 0.24
    let sadX2 = brX + brW * 0.76
    let sadY1 = brY + brH * 0.32
    let sadY2 = brY + brH * 0.36
    saddlePath.move(to: CGPoint(x: sadX1, y: sadY1))
    saddlePath.addLine(to: CGPoint(x: sadX2, y: sadY2))
    ctx.stroke(saddlePath, with: .color(Color(red: 0.96, green: 0.95, blue: 0.90)),
               style: StrokeStyle(lineWidth: max(2.0, w * 0.012), lineCap: .round))
    
    // 6 Acoustic Bridge Pins (Cream with black center dot)
    let pinY = brY + brH * 0.65
    for j in 0..<6 {
        let pinX = (brX + brW * 0.25) + CGFloat(j) * (brW * 0.10)
        let pinR = max(1.5, w * 0.008)
        let pinRect = CGRect(x: pinX - pinR, y: pinY - pinR, width: pinR * 2, height: pinR * 2)
        // White pin collar
        ctx.fill(Circle().path(in: pinRect), with: .color(Color(red: 0.96, green: 0.95, blue: 0.92)))
        ctx.stroke(Circle().path(in: pinRect), with: .color(Color(red: 0.35, green: 0.25, blue: 0.20)), style: StrokeStyle(lineWidth: 0.5))
        // Black pin center dot
        let dotR = pinR * 0.45
        ctx.fill(Circle().path(in: CGRect(x: pinX - dotR, y: pinY - dotR, width: dotR * 2, height: dotR * 2)),
                 with: .color(Color.black))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 6. MAHOGANY NECK & ROSEWOOD FRETBOARD (14-Fret Joint)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let nutY = h * 0.240
    let neckBotY = h * 0.565
    let nutW = w * 0.114
    let neckBotW = w * 0.158
    
    var fbPath = Path()
    fbPath.move(to: CGPoint(x: neckCx - nutW / 2, y: nutY))
    fbPath.addLine(to: CGPoint(x: neckCx + nutW / 2, y: nutY))
    fbPath.addLine(to: CGPoint(x: neckCx + neckBotW / 2, y: neckBotY))
    fbPath.addLine(to: CGPoint(x: neckCx - neckBotW / 2, y: neckBotY))
    fbPath.closeSubpath()
    
    // Dark rosewood fretboard
    ctx.fill(fbPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.26, green: 0.19, blue: 0.15),
            Color(red: 0.19, green: 0.14, blue: 0.11),
            Color(red: 0.15, green: 0.10, blue: 0.08)
        ]),
        startPoint: CGPoint(x: neckCx - nutW / 2, y: nutY),
        endPoint: CGPoint(x: neckCx + nutW / 2, y: neckBotY)
    ))
    ctx.stroke(fbPath, with: .color(Color(red: 0.42, green: 0.32, blue: 0.25)), style: StrokeStyle(lineWidth: 0.7))
    
    // Frets (20 frets with realistic scale spacing)
    let fretColor = Color(red: 0.78, green: 0.79, blue: 0.82)
    for i in 1...20 {
        let t = pow(CGFloat(i) / 21.0, 0.88)
        let fy = nutY + (neckBotY - nutY) * t
        let curW = nutW + (neckBotW - nutW) * t
        var fp = Path()
        fp.move(to: CGPoint(x: neckCx - curW / 2, y: fy))
        fp.addLine(to: CGPoint(x: neckCx + curW / 2, y: fy))
        ctx.stroke(fp, with: .color(fretColor), style: StrokeStyle(lineWidth: 0.85))
    }
    
    // Mother-of-pearl fret position markers (3, 5, 7, 9, 15, 17)
    let pearlColor = Color(red: 0.94, green: 0.95, blue: 0.96)
    for fret in [3, 5, 7, 9, 15, 17] {
        let t = pow((CGFloat(fret) - 0.5) / 21.0, 0.88)
        let dy = nutY + (neckBotY - nutY) * t
        let dr = max(1.4, w * 0.007)
        ctx.fill(Circle().path(in: CGRect(x: neckCx - dr, y: dy - dr, width: dr * 2, height: dr * 2)), with: .color(pearlColor))
        ctx.stroke(Circle().path(in: CGRect(x: neckCx - dr, y: dy - dr, width: dr * 2, height: dr * 2)),
                   with: .color(Color.black.opacity(0.3)), style: StrokeStyle(lineWidth: 0.4))
    }
    // 12th fret double pearl dots
    let t12 = pow(11.5 / 21.0, 0.88)
    let d12y = nutY + (neckBotY - nutY) * t12
    let d12w = nutW + (neckBotW - nutW) * t12
    let ddr = max(1.3, w * 0.006)
    ctx.fill(Circle().path(in: CGRect(x: neckCx - d12w * 0.22 - ddr, y: d12y - ddr, width: ddr * 2, height: ddr * 2)), with: .color(pearlColor))
    ctx.fill(Circle().path(in: CGRect(x: neckCx + d12w * 0.22 - ddr, y: d12y - ddr, width: ddr * 2, height: ddr * 2)), with: .color(pearlColor))
    
    // Bone nut at top of fretboard
    let nutRect = CGRect(x: neckCx - nutW * 0.52, y: nutY - 2.8, width: nutW * 1.04, height: 3.8)
    ctx.fill(RoundedRectangle(cornerRadius: 1).path(in: nutRect),
             with: .color(Color(red: 0.96, green: 0.95, blue: 0.90)))
    ctx.stroke(RoundedRectangle(cornerRadius: 1).path(in: nutRect),
               with: .color(Color(red: 0.55, green: 0.48, blue: 0.40)), style: StrokeStyle(lineWidth: 0.5))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 7. SYMMETRICAL 3+3 ACOUSTIC HEADSTOCK (Martin / Taylor Paddle Style)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let hsTop = h * 0.088
    let hsBot = nutY
    let hsH = hsBot - hsTop
    
    var hsPath = Path()
    let pNutL = CGPoint(x: neckCx - nutW * 0.50, y: nutY)
    let pNutR = CGPoint(x: neckCx + nutW * 0.50, y: nutY)
    
    hsPath.move(to: pNutL)
    // Left shoulder step out
    hsPath.addQuadCurve(to: CGPoint(x: neckCx - nutW * 0.72, y: nutY - hsH * 0.12),
                        control: CGPoint(x: neckCx - nutW * 0.62, y: nutY - hsH * 0.04))
    // Left straight taper expanding slightly towards top
    hsPath.addLine(to: CGPoint(x: neckCx - nutW * 0.78, y: hsTop + hsH * 0.18))
    // Left top corner curve
    hsPath.addQuadCurve(to: CGPoint(x: neckCx - nutW * 0.35, y: hsTop),
                        control: CGPoint(x: neckCx - nutW * 0.76, y: hsTop))
    // Gentle crown center dip
    hsPath.addQuadCurve(to: CGPoint(x: neckCx + nutW * 0.35, y: hsTop),
                        control: CGPoint(x: neckCx, y: hsTop + hsH * 0.05))
    // Right top corner curve
    hsPath.addQuadCurve(to: CGPoint(x: neckCx + nutW * 0.78, y: hsTop + hsH * 0.18),
                        control: CGPoint(x: neckCx + nutW * 0.76, y: hsTop))
    // Right straight taper
    hsPath.addLine(to: CGPoint(x: neckCx + nutW * 0.72, y: nutY - hsH * 0.12))
    // Right shoulder step returning to nut
    hsPath.addQuadCurve(to: pNutR,
                        control: CGPoint(x: neckCx + nutW * 0.62, y: nutY - hsH * 0.04))
    hsPath.closeSubpath()
    
    // Rosewood headstock faceplate
    ctx.fill(hsPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.28, green: 0.18, blue: 0.14),
            Color(red: 0.18, green: 0.12, blue: 0.09),
            Color(red: 0.12, green: 0.08, blue: 0.06)
        ]),
        startPoint: CGPoint(x: neckCx, y: hsTop),
        endPoint: CGPoint(x: neckCx, y: hsBot)
    ))
    ctx.stroke(hsPath, with: .color(Color(red: 0.48, green: 0.36, blue: 0.28)), style: StrokeStyle(lineWidth: 1.0))
    
    // Gold acoustic script / emblem in center of headstock
    let emblemY = hsTop + hsH * 0.35
    var emblem = Path()
    emblem.move(to: CGPoint(x: neckCx - w * 0.022, y: emblemY))
    emblem.addLine(to: CGPoint(x: neckCx + w * 0.022, y: emblemY))
    ctx.stroke(emblem, with: .color(Color(red: 0.94, green: 0.82, blue: 0.45)), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
    ctx.fill(Circle().path(in: CGRect(x: neckCx - 1.8, y: emblemY - 1.8, width: 3.6, height: 3.6)),
             with: .color(Color(red: 0.96, green: 0.86, blue: 0.50)))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 8. 3+3 TUNING MACHINES (3 Left, 3 Right Chrome Butterbean Tuners)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let tunerYPositions: [CGFloat] = [
        hsTop + hsH * 0.30, // Top tuner
        hsTop + hsH * 0.54, // Mid tuner
        hsTop + hsH * 0.78  // Bottom tuner
    ]
    
    for (idx, ty) in tunerYPositions.enumerated() {
        // --- Left Side Tuners (E, A, D strings) ---
        let lEdgeX = neckCx - nutW * 0.76 + CGFloat(idx) * (nutW * 0.02)
        let shaftLen = w * 0.030
        let lShaftEnd = CGPoint(x: lEdgeX - shaftLen, y: ty)
        
        // Shaft
        var lShaft = Path()
        lShaft.move(to: CGPoint(x: lEdgeX, y: ty))
        lShaft.addLine(to: lShaftEnd)
        ctx.stroke(lShaft, with: .color(Color(red: 0.78, green: 0.80, blue: 0.84)),
                   style: StrokeStyle(lineWidth: max(1.6, w * 0.009), lineCap: .round))
        
        // Butterbean / oval knob
        let btnW = w * 0.026
        let btnH = h * 0.013
        let lBtnRect = CGRect(x: lShaftEnd.x - btnW * 0.6, y: lShaftEnd.y - btnH / 2, width: btnW, height: btnH)
        ctx.fill(Capsule().path(in: lBtnRect), with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99),
                Color(red: 0.75, green: 0.78, blue: 0.82),
                Color(red: 0.88, green: 0.90, blue: 0.94)
            ]),
            startPoint: CGPoint(x: lBtnRect.minX, y: lBtnRect.minY),
            endPoint: CGPoint(x: lBtnRect.maxX, y: lBtnRect.maxY)
        ))
        ctx.stroke(Capsule().path(in: lBtnRect), with: .color(Color(red: 0.50, green: 0.52, blue: 0.56)), style: StrokeStyle(lineWidth: 0.6))
        
        // --- Right Side Tuners (G, B, e strings) ---
        let rEdgeX = neckCx + nutW * 0.76 - CGFloat(idx) * (nutW * 0.02)
        let rShaftEnd = CGPoint(x: rEdgeX + shaftLen, y: ty)
        
        // Shaft
        var rShaft = Path()
        rShaft.move(to: CGPoint(x: rEdgeX, y: ty))
        rShaft.addLine(to: rShaftEnd)
        ctx.stroke(rShaft, with: .color(Color(red: 0.78, green: 0.80, blue: 0.84)),
                   style: StrokeStyle(lineWidth: max(1.6, w * 0.009), lineCap: .round))
        
        // Butterbean / oval knob
        let rBtnRect = CGRect(x: rShaftEnd.x - btnW * 0.4, y: rShaftEnd.y - btnH / 2, width: btnW, height: btnH)
        ctx.fill(Capsule().path(in: rBtnRect), with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99),
                Color(red: 0.75, green: 0.78, blue: 0.82),
                Color(red: 0.88, green: 0.90, blue: 0.94)
            ]),
            startPoint: CGPoint(x: rBtnRect.minX, y: rBtnRect.minY),
            endPoint: CGPoint(x: rBtnRect.maxX, y: rBtnRect.maxY)
        ))
        ctx.stroke(Capsule().path(in: rBtnRect), with: .color(Color(red: 0.50, green: 0.52, blue: 0.56)), style: StrokeStyle(lineWidth: 0.6))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 9. 6 PHOSPHOR BRONZE ACOUSTIC STRINGS & POSTS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // String post coordinates on headstock (3 Left, 3 Right):
    // Left posts: low E (idx 2, bot), A (idx 1, mid), D (idx 0, top)
    // Right posts: G (idx 0, top), B (idx 1, mid), high e (idx 2, bot)
    let leftPostPoints: [CGPoint] = [
        CGPoint(x: neckCx - nutW * 0.38, y: tunerYPositions[0]), // D
        CGPoint(x: neckCx - nutW * 0.38, y: tunerYPositions[1]), // A
        CGPoint(x: neckCx - nutW * 0.38, y: tunerYPositions[2])  // E
    ]
    let rightPostPoints: [CGPoint] = [
        CGPoint(x: neckCx + nutW * 0.38, y: tunerYPositions[0]), // G
        CGPoint(x: neckCx + nutW * 0.38, y: tunerYPositions[1]), // B
        CGPoint(x: neckCx + nutW * 0.38, y: tunerYPositions[2])  // e
    ]
    
    let stringPostTargets: [CGPoint] = [
        leftPostPoints[2],  // Low E  (String 0)
        leftPostPoints[1],  // A      (String 1)
        leftPostPoints[0],  // D      (String 2)
        rightPostPoints[0], // G      (String 3)
        rightPostPoints[1], // B      (String 4)
        rightPostPoints[2]  // High e (String 5)
    ]
    
    // Draw circular string ferrules/posts on headstock
    for pt in leftPostPoints + rightPostPoints {
        let postR: CGFloat = max(2.8, w * 0.013)
        let postRect = CGRect(x: pt.x - postR, y: pt.y - postR, width: postR * 2, height: postR * 2)
        ctx.fill(Circle().path(in: postRect), with: .color(Color.white.opacity(0.92)))
        ctx.stroke(Circle().path(in: postRect), with: .color(Color(red: 0.28, green: 0.30, blue: 0.34)), style: StrokeStyle(lineWidth: 1.0))
        let innerR = postR * 0.45
        ctx.fill(Circle().path(in: CGRect(x: pt.x - innerR, y: pt.y - innerR, width: innerR * 2, height: innerR * 2)),
                 with: .color(Color(red: 0.18, green: 0.16, blue: 0.14)))
    }
    
    // Strings running from bridge pins -> over saddle -> over nut -> to headstock posts
    for i in 0..<6 {
        let frac = CGFloat(i) / 5.0
        let nutStrX = (neckCx - nutW * 0.36) + nutW * 0.72 * frac
        let bridgeStrX = (brX + brW * 0.25) + CGFloat(i) * (brW * 0.10)
        let bridgePinY = pinY
        let postTarget = stringPostTargets[i]
        
        // Phosphor Bronze tone: heavier wound bass strings have warm bronze color; treble strings have brighter sheen
        let strColor: Color
        let strLW: CGFloat
        if i < 3 {
            // Wound Phosphor Bronze (E, A, D)
            strColor = Color(red: 0.88 - CGFloat(i) * 0.04, green: 0.68 - CGFloat(i) * 0.04, blue: 0.40)
            strLW = 1.3 - CGFloat(i) * 0.2
        } else {
            // Plain Steel & Light Bronze (G, B, e)
            strColor = Color(red: 0.94, green: 0.88, blue: 0.75).opacity(0.85)
            strLW = 0.85 - CGFloat(i - 3) * 0.15
        }
        
        // Body & fretboard string span (Bridge pin up to nut)
        var strPath = Path()
        strPath.move(to: CGPoint(x: bridgeStrX, y: bridgePinY))
        strPath.addLine(to: CGPoint(x: nutStrX, y: nutY))
        ctx.stroke(strPath, with: .color(strColor), style: StrokeStyle(lineWidth: strLW))
        
        // Headstock string span (Nut to tuning post)
        var headStr = Path()
        headStr.move(to: CGPoint(x: nutStrX, y: nutY))
        headStr.addLine(to: postTarget)
        ctx.stroke(headStr, with: .color(strColor), style: StrokeStyle(lineWidth: strLW))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 10. STAND FRONT CRADLE RETAINING PRONGS (CUPS GUITAR RIM)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let prongW = max(5.0, w * 0.038)
    let prongH = max(11.0, h * 0.022)
    
    for cxRel in [0.320, 0.680] as [CGFloat] {
        let px = w * cxRel
        let py = h * 0.878
        let pRect = CGRect(x: px - prongW / 2, y: py - prongH * 0.6, width: prongW, height: prongH)
        ctx.fill(Capsule().path(in: pRect), with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.25, green: 0.25, blue: 0.28),
                Color(red: 0.10, green: 0.10, blue: 0.12)
            ]),
            startPoint: CGPoint(x: pRect.minX, y: pRect.minY),
            endPoint: CGPoint(x: pRect.maxX, y: pRect.maxY)))
        ctx.stroke(Capsule().path(in: pRect), with: .color(Color(red: 0.35, green: 0.35, blue: 0.40)), style: StrokeStyle(lineWidth: 0.6))
    }
}
