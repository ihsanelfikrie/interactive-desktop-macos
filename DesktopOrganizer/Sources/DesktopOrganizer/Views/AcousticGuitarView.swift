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
    
    // Scale reference for neck & headstock (preserves exact original neck proportions)
    let neckW = w * (0.365 / 0.44)
    let tubeW = max(3.5, neckW * 0.038)
    
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
    // 1. STAND STRUCTURE (BEHIND GUITAR - CLEAN A-FRAME CRADLE)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Central rear spine behind guitar body (clean & free of neck horns)
    strokeTube(from: p(0.50, 0.65), to: p(0.50, 0.90), lw: tubeW * 1.1)
    
    // Bottom cradle support arms (behind acoustic body)
    strokeTube(from: p(0.32, 0.88), to: p(0.50, 0.90), lw: tubeW * 1.15)
    strokeTube(from: p(0.68, 0.88), to: p(0.50, 0.90), lw: tubeW * 1.15)
    
    // Tripod Legs extending down to floor (clear of dock)
    strokeTube(from: p(0.50, 0.90), to: p(0.50, 0.965), lw: tubeW * 1.05)
    strokeTube(from: p(0.50, 0.90), to: p(0.12, 0.975), lw: tubeW * 1.1)
    strokeTube(from: p(0.50, 0.90), to: p(0.88, 0.975), lw: tubeW * 1.1)
    
    // Rubber feet on floor
    let footR = w * 0.032
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.12 - footR, y: h * 0.975 - footR * 0.6, width: footR * 2, height: footR * 1.2)), with: .color(.black))
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.88 - footR, y: h * 0.975 - footR * 0.6, width: footR * 2, height: footR * 1.2)), with: .color(.black))
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.50 - footR * 0.8, y: h * 0.965 - footR * 0.5, width: footR * 1.6, height: footR)), with: .color(.black))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 2. DREADNOUGHT ACOUSTIC BODY (True Martin D-28 Blueprint)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Authentic proportions: Lower bout 0.712*w, Upper bout 0.545*w, Waist 0.491*w (90% of upper bout!)
    let bodyHalf: [(CGFloat, CGFloat)] = [
        // Neck joint (14th fret)
        (0.560, 0.470),
        // Full rounded Dreadnought shoulders curving out from neck
        (0.620, 0.474),
        (0.680, 0.485),
        (0.730, 0.505),
        (0.765, 0.530),
        (0.780, 0.555),
        // Upper bout flank
        (0.775, 0.585),
        // Waist curve (gentle, sturdy)
        (0.755, 0.615),
        (0.740, 0.640),
        (0.750, 0.665),
        // Lower bout expansion
        (0.780, 0.700),
        (0.825, 0.735),
        (0.860, 0.775),
        (0.865, 0.800),
        // Bottom sweep
        (0.840, 0.830),
        (0.795, 0.855),
        (0.720, 0.870),
        (0.620, 0.875),
        (0.500, 0.875)
    ]
    
    var bodyPath = Path()
    if let first = bodyHalf.first {
        bodyPath.move(to: p(first.0, first.1))
        for pt in bodyHalf.dropFirst() {
            bodyPath.addLine(to: p(pt.0, pt.1))
        }
        for pt in bodyHalf.reversed().dropFirst() {
            let mirrorX = 0.500 - (pt.0 - 0.500)
            bodyPath.addLine(to: p(mirrorX, pt.1))
        }
        bodyPath.closeSubpath()
    }
    
    // Solid Sitka Spruce soundboard with warm natural honey/amber acoustic glow
    let spruceTop = Color(red: 0.97, green: 0.89, blue: 0.75)
    let spruceMid = Color(red: 0.92, green: 0.80, blue: 0.60)
    let spruceEdge = Color(red: 0.80, green: 0.62, blue: 0.40)
    let spruceDark = Color(red: 0.65, green: 0.45, blue: 0.26)
    
    ctx.fill(bodyPath, with: .radialGradient(
        Gradient(colors: [spruceTop, spruceMid, spruceEdge, spruceDark]),
        center: p(0.50, 0.72),
        startRadius: w * 0.05,
        endRadius: w * 0.45
    ))
    
    // Natural wood grain sheen (fine vertical line overlay)
    var grainPath = Path()
    for g in 0...26 {
        let gx = w * (0.20 + CGFloat(g) * 0.023)
        grainPath.move(to: CGPoint(x: gx, y: h * 0.47))
        grainPath.addLine(to: CGPoint(x: gx, y: h * 0.88))
    }
    ctx.stroke(grainPath, with: .color(Color(red: 0.55, green: 0.38, blue: 0.20).opacity(0.06)), style: StrokeStyle(lineWidth: 0.6))
    
    // Multi-ply Body Binding: Outer ivory cream rim + inner dark purfling pinstripe
    ctx.stroke(bodyPath, with: .color(Color(red: 0.96, green: 0.94, blue: 0.88)), style: StrokeStyle(lineWidth: 2.2))
    ctx.stroke(bodyPath, with: .color(Color(red: 0.25, green: 0.18, blue: 0.12)), style: StrokeStyle(lineWidth: 0.8))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 3. SOUNDHOLE & VINTAGE HERRINGBONE ROSETTE (Martin Style 28)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let shCx = w * 0.50
    let shCy = h * 0.605
    let shR  = w * 0.076
    
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
    ctx.stroke(Circle().path(in: shRect), with: .color(Color(red: 0.22, green: 0.16, blue: 0.12)), style: StrokeStyle(lineWidth: 1.2))
    
    // Visible inner back brace / interior wood label glimpsed inside soundhole
    let labelW = shR * 1.2
    let labelH = shR * 0.50
    let labelRect = CGRect(x: shCx - labelW / 2, y: shCy - labelH / 2, width: labelW, height: labelH)
    ctx.fill(RoundedRectangle(cornerRadius: 1).path(in: labelRect),
             with: .color(Color(red: 0.35, green: 0.26, blue: 0.18).opacity(0.35)))
    
    // Rosette concentric purfling rings (Martin Style 28)
    // Inner single black ring
    ctx.stroke(Circle().path(in: CGRect(x: shCx - shR * 1.12, y: shCy - shR * 1.12, width: shR * 2.24, height: shR * 2.24)),
               with: .color(Color(red: 0.25, green: 0.18, blue: 0.14)), style: StrokeStyle(lineWidth: 0.9))
    
    // Main center band (warm ivory / herringbone texture)
    let rosMidR = shR * 1.25
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosMidR, y: shCy - rosMidR, width: rosMidR * 2, height: rosMidR * 2)),
               with: .color(Color(red: 0.92, green: 0.89, blue: 0.82)), style: StrokeStyle(lineWidth: 2.5))
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosMidR, y: shCy - rosMidR, width: rosMidR * 2, height: rosMidR * 2)),
               with: .color(Color(red: 0.30, green: 0.22, blue: 0.16).opacity(0.4)), style: StrokeStyle(lineWidth: 1.0, dash: [2, 2]))
    
    // Outer multi-ply ring
    let rosOuterR = shR * 1.38
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosOuterR, y: shCy - rosOuterR, width: rosOuterR * 2, height: rosOuterR * 2)),
               with: .color(Color(red: 0.25, green: 0.18, blue: 0.14)), style: StrokeStyle(lineWidth: 1.0))
    ctx.stroke(Circle().path(in: CGRect(x: shCx - rosOuterR * 1.04, y: shCy - rosOuterR * 1.04, width: rosOuterR * 2.08, height: rosOuterR * 2.08)),
               with: .color(Color(red: 0.88, green: 0.84, blue: 0.76)), style: StrokeStyle(lineWidth: 0.6))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 4. ACOUSTIC TORTOISESHELL TEARDROP PICKGUARD (Snug to Fretboard & Rosette)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    var pgPath = Path()
    let pgTopL = CGPoint(x: neckCx + w * 0.066, y: h * 0.540)
    pgPath.move(to: pgTopL)
    // Follow rosette ring contour
    pgPath.addArc(
        center: CGPoint(x: shCx, y: shCy),
        radius: rosOuterR * 1.03,
        startAngle: .degrees(-45),
        endAngle: .degrees(75),
        clockwise: false
    )
    // Lower sweep towards waist
    pgPath.addCurve(
        to: CGPoint(x: shCx + w * 0.160, y: shCy + rosOuterR * 1.15),
        control1: CGPoint(x: shCx + rosOuterR * 0.85, y: shCy + rosOuterR * 1.12),
        control2: CGPoint(x: shCx + w * 0.130, y: shCy + rosOuterR * 1.18)
    )
    // Teardrop pointed lobe
    pgPath.addQuadCurve(
        to: CGPoint(x: shCx + w * 0.180, y: shCy + rosOuterR * 0.45),
        control: CGPoint(x: shCx + w * 0.195, y: shCy + rosOuterR * 0.85)
    )
    // Upper contour sweeping back up to fretboard edge
    pgPath.addCurve(
        to: pgTopL,
        control1: CGPoint(x: shCx + w * 0.165, y: shCy - rosOuterR * 0.20),
        control2: CGPoint(x: shCx + w * 0.110, y: h * 0.535)
    )
    pgPath.closeSubpath()
    
    // Rich amber-ruby tortoiseshell
    ctx.fill(pgPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.50, green: 0.16, blue: 0.08),
            Color(red: 0.30, green: 0.09, blue: 0.04),
            Color(red: 0.16, green: 0.05, blue: 0.02)
        ]),
        startPoint: CGPoint(x: shCx + w * 0.07, y: h * 0.54),
        endPoint: CGPoint(x: shCx + w * 0.18, y: h * 0.68)
    ))
    ctx.stroke(pgPath, with: .color(Color(red: 0.70, green: 0.28, blue: 0.12).opacity(0.35)), style: StrokeStyle(lineWidth: 0.6))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 5. ROSEWOOD BELLY BRIDGE, BONE SADDLE & BRIDGE PINS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let brW = w * 0.250
    let brH = h * 0.032
    let brX = neckCx - brW / 2
    let brY = h * 0.745
    
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
            Color(red: 0.30, green: 0.19, blue: 0.14),
            Color(red: 0.20, green: 0.13, blue: 0.09),
            Color(red: 0.14, green: 0.08, blue: 0.05)
        ]),
        startPoint: CGPoint(x: brX, y: brY),
        endPoint: CGPoint(x: brX + brW, y: brY + brH)
    ))
    ctx.stroke(brPath, with: .color(Color(red: 0.40, green: 0.26, blue: 0.18)), style: StrokeStyle(lineWidth: 0.8))
    
    // Slanted compensated white bone saddle
    var saddlePath = Path()
    let sadX1 = brX + brW * 0.24
    let sadX2 = brX + brW * 0.76
    let sadY1 = brY + brH * 0.31
    let sadY2 = brY + brH * 0.36
    saddlePath.move(to: CGPoint(x: sadX1, y: sadY1))
    saddlePath.addLine(to: CGPoint(x: sadX2, y: sadY2))
    ctx.stroke(saddlePath, with: .color(Color(red: 0.96, green: 0.95, blue: 0.90)),
               style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
    
    // 6 Acoustic Bridge Pins (Cream with black center dot)
    let pinY = brY + brH * 0.65
    for j in 0..<6 {
        let pinX = (brX + brW * 0.25) + CGFloat(j) * (brW * 0.10)
        let pinR: CGFloat = 2.0
        let pinRect = CGRect(x: pinX - pinR, y: pinY - pinR, width: pinR * 2, height: pinR * 2)
        // White pin collar
        ctx.fill(Circle().path(in: pinRect), with: .color(Color(red: 0.96, green: 0.95, blue: 0.92)))
        ctx.stroke(Circle().path(in: pinRect), with: .color(Color(red: 0.35, green: 0.25, blue: 0.20)), style: StrokeStyle(lineWidth: 0.5))
        // Black pin center dot
        ctx.fill(Circle().path(in: CGRect(x: pinX - 0.9, y: pinY - 0.9, width: 1.8, height: 1.8)),
                 with: .color(Color.black))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 6. MAHOGANY NECK & ROSEWOOD FRETBOARD
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let nutY = h * 0.245
    let neckBotY = h * 0.542
    let nutW = w * 0.100
    let neckBotW = w * 0.138
    
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
        let dr = max(1.4, neckW * 0.007)
        ctx.fill(Circle().path(in: CGRect(x: neckCx - dr, y: dy - dr, width: dr * 2, height: dr * 2)), with: .color(pearlColor))
        ctx.stroke(Circle().path(in: CGRect(x: neckCx - dr, y: dy - dr, width: dr * 2, height: dr * 2)),
                   with: .color(Color.black.opacity(0.3)), style: StrokeStyle(lineWidth: 0.4))
    }
    // 12th fret double pearl dots
    let t12 = pow(11.5 / 21.0, 0.88)
    let d12y = nutY + (neckBotY - nutY) * t12
    let d12w = nutW + (neckBotW - nutW) * t12
    let ddr = max(1.3, neckW * 0.006)
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
    emblem.move(to: CGPoint(x: neckCx - neckW * 0.022, y: emblemY))
    emblem.addLine(to: CGPoint(x: neckCx + neckW * 0.022, y: emblemY))
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
        let shaftLen = neckW * 0.030
        let lShaftEnd = CGPoint(x: lEdgeX - shaftLen, y: ty)
        
        // Shaft
        var lShaft = Path()
        lShaft.move(to: CGPoint(x: lEdgeX, y: ty))
        lShaft.addLine(to: lShaftEnd)
        ctx.stroke(lShaft, with: .color(Color(red: 0.78, green: 0.80, blue: 0.84)),
                   style: StrokeStyle(lineWidth: max(1.6, neckW * 0.009), lineCap: .round))
        
        // Butterbean / oval knob
        let btnW = neckW * 0.026
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
                   style: StrokeStyle(lineWidth: max(1.6, neckW * 0.009), lineCap: .round))
        
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
        let postR: CGFloat = max(2.8, neckW * 0.013)
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
    let prongW = max(5.0, neckW * 0.038)
    let prongH = max(11.0, h * 0.022)
    
    for cxRel in [0.270, 0.730] as [CGFloat] {
        let px = w * cxRel
        let py = h * 0.882
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
