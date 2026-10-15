import SwiftUI
import AppKit

// MARK: - Fender Stratocaster Guitar View (Native Vector Illustration)
public struct StratocasterGuitarView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // Soft floor shadow under stand feet
                Ellipse()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: w * 0.85, height: h * 0.04)
                    .blur(radius: 6)
                    .position(x: w * 0.53, y: h * 0.98)
                
                Canvas { ctx, size in
                    drawStratocaster(ctx: ctx, w: size.width, h: size.height)
                }
                .shadow(
                    color: Color.black.opacity(0.18),
                    radius: 5,
                    x: 2, y: 4
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { openMusicOrGarageBand() }
        .onTapGesture {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                appState.toggleQuickView(.guitar)
            }
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

// MARK: - Guitar & Stand Drawing
// Draw order (natural depth):
//   1. Stand structure (mast, neck yoke, legs, bottom cradle bar) — behind guitar
//   2. Guitar body (solid neck pocket behind neck, smooth horns, no gaps/leaks)
//   3. Pickguard (nested cleanly inside body bevel)
//   4. Pickups, bridge, controls
//   5. Neck, frets, 6-in-line headstock (flows seamlessly into body to 21st fret)
//   6. Strings running over nut to bridge
//   7. Cradle retaining prongs — discreet rubber bumpers holding the bottom rim
private func drawStratocaster(ctx: GraphicsContext, w: CGFloat, h: CGFloat) {
    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
    }
    
    let neckCx = w * 0.539
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
    // 1. STAND (BEHIND GUITAR)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // Central vertical mast (runs behind guitar)
    strokeTube(from: p(0.539, 0.38), to: p(0.539, 0.90), lw: tubeW * 1.05)
    
    // Neck cradle yoke (holds upper neck from behind)
    var yoke = Path()
    yoke.addArc(center: p(0.539, 0.40), radius: w * 0.155,
                startAngle: .degrees(10), endAngle: .degrees(170), clockwise: false)
    ctx.stroke(yoke, with: .color(standDark), style: StrokeStyle(lineWidth: tubeW * 1.1, lineCap: .round))
    // Rubber end caps on yoke
    ctx.fill(Circle().path(in: CGRect(x: w * 0.38 - 4, y: h * 0.40 - 4, width: 8, height: 8)), with: .color(standDark))
    ctx.fill(Circle().path(in: CGRect(x: w * 0.698 - 4, y: h * 0.40 - 4, width: 8, height: 8)), with: .color(standDark))
    
    // Bottom cradle support arms (behind the body)
    strokeTube(from: p(0.33, 0.88), to: p(0.539, 0.90), lw: tubeW * 1.15)
    strokeTube(from: p(0.74, 0.88), to: p(0.539, 0.90), lw: tubeW * 1.15)
    
    // Tripod Legs extending down to floor (behind/under guitar)
    // Center/rear leg
    strokeTube(from: p(0.539, 0.90), to: p(0.539, 0.975), lw: tubeW * 1.05)
    // Left front leg
    strokeTube(from: p(0.539, 0.90), to: p(0.12, 0.985), lw: tubeW * 1.1)
    // Right front leg
    strokeTube(from: p(0.539, 0.90), to: p(0.94, 0.985), lw: tubeW * 1.1)
    
    // Rubber feet on floor
    let footR = w * 0.040
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.12 - footR, y: h * 0.985 - footR * 0.6, width: footR * 2, height: footR * 1.2)), with: .color(.black))
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.94 - footR, y: h * 0.985 - footR * 0.6, width: footR * 2, height: footR * 1.2)), with: .color(.black))
    ctx.fill(Capsule().path(in: CGRect(x: w * 0.539 - footR * 0.8, y: h * 0.975 - footR * 0.5, width: footR * 1.6, height: footR)), with: .color(.black))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 2. GUITAR BODY (Seamless Solid Neck Pocket & Horns)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let bodyNorm: [(CGFloat, CGFloat)] = [
        // Neck pocket top (solid wood behind neck, no gap!)
        (0.460, 0.490), (0.618, 0.490),
        // Treble cutaway
        (0.630, 0.515), (0.665, 0.538), (0.730, 0.530), (0.790, 0.518), (0.830, 0.502),
        // Treble horn tip
        (0.875, 0.490), (0.910, 0.505), (0.932, 0.530), (0.930, 0.555), (0.910, 0.582),
        // Treble waist
        (0.880, 0.605), (0.865, 0.625), (0.865, 0.645), (0.880, 0.665), (0.910, 0.688),
        // Lower treble bout
        (0.945, 0.712), (0.978, 0.740), (0.995, 0.770), (0.995, 0.792), (0.980, 0.820),
        // Bottom rim
        (0.935, 0.846), (0.855, 0.862), (0.710, 0.872), (0.539, 0.874), (0.360, 0.869),
        (0.230, 0.857), (0.138, 0.838), (0.088, 0.812), (0.070, 0.783), (0.070, 0.757),
        // Bass waist
        (0.095, 0.725), (0.128, 0.696), (0.165, 0.667), (0.198, 0.638), (0.205, 0.616),
        (0.198, 0.594), (0.176, 0.565), (0.153, 0.536), (0.137, 0.507), (0.135, 0.485),
        // Bass horn tip
        (0.146, 0.464), (0.168, 0.446), (0.202, 0.431), (0.236, 0.424), (0.261, 0.424),
        // Bass inner cutaway down to neck pocket
        (0.282, 0.431), (0.288, 0.450), (0.295, 0.472), (0.315, 0.490), (0.345, 0.505),
        (0.395, 0.512), (0.435, 0.502)
    ]
    
    var bodyPath = Path()
    if let first = bodyNorm.first {
        bodyPath.move(to: p(first.0, first.1))
        for pt in bodyNorm.dropFirst() { bodyPath.addLine(to: p(pt.0, pt.1)) }
        bodyPath.closeSubpath()
    }
    
    // Body deep gloss black finish with soft lacquer gradient
    ctx.fill(bodyPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.22, green: 0.22, blue: 0.25),
            Color(red: 0.11, green: 0.11, blue: 0.13),
            Color(red: 0.04, green: 0.04, blue: 0.05)
        ]),
        startPoint: p(0.25, 0.45), endPoint: p(0.85, 0.85)))
    ctx.stroke(bodyPath, with: .color(Color(red: 0.32, green: 0.32, blue: 0.36)), style: StrokeStyle(lineWidth: 1.3))
    
    // Horn & edge lacquer highlights
    var hornHL = Path()
    hornHL.move(to: p(0.165, 0.50))
    hornHL.addQuadCurve(to: p(0.24, 0.435), control: p(0.19, 0.46))
    ctx.stroke(hornHL, with: .color(Color.white.opacity(0.14)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
    
    // Lower body highlight reflection
    var botHL = Path()
    botHL.move(to: p(0.28, 0.855))
    botHL.addQuadCurve(to: p(0.80, 0.855), control: p(0.54, 0.875))
    ctx.stroke(botHL, with: .color(Color.white.opacity(0.06)), style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 3. PICKGUARD (Cleanly nested inside body bevel)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let pgNorm: [(CGFloat, CGFloat)] = [
        (0.440, 0.520), (0.615, 0.525),
        (0.655, 0.540), (0.725, 0.535), (0.795, 0.524), (0.840, 0.515), (0.865, 0.525),
        (0.880, 0.545), (0.870, 0.570), (0.850, 0.598), (0.825, 0.632), (0.835, 0.668),
        (0.815, 0.704), (0.775, 0.732), (0.670, 0.743), (0.525, 0.743), (0.380, 0.725),
        (0.315, 0.703), (0.348, 0.645), (0.375, 0.602), (0.380, 0.560), (0.355, 0.530),
        (0.380, 0.520)
    ]
    var pgPath = Path()
    if let first = pgNorm.first {
        pgPath.move(to: p(first.0, first.1))
        for pt in pgNorm.dropFirst() { pgPath.addLine(to: p(pt.0, pt.1)) }
        pgPath.closeSubpath()
    }
    // Aged parchment 3-ply pickguard
    ctx.fill(pgPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.98, green: 0.97, blue: 0.95),
            Color(red: 0.91, green: 0.90, blue: 0.87)
        ]),
        startPoint: p(0.40, 0.52), endPoint: p(0.70, 0.74)))
    ctx.stroke(pgPath, with: .color(Color(red: 0.78, green: 0.77, blue: 0.74)), style: StrokeStyle(lineWidth: 0.9))
    
    // Pickguard screws
    for sp in [(0.36, 0.53), (0.84, 0.53), (0.83, 0.65), (0.75, 0.73), (0.34, 0.69), (0.38, 0.58)] as [(CGFloat, CGFloat)] {
        ctx.fill(Circle().path(in: CGRect(x: w * sp.0 - 1.2, y: h * sp.1 - 1.2, width: 2.4, height: 2.4)),
                 with: .color(Color(red: 0.65, green: 0.65, blue: 0.68)))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 4. PICKUPS (3 Single-Coils)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for pyRel in [0.585, 0.640, 0.695] as [CGFloat] {
        let puW = w * 0.205
        let puH = h * 0.016
        let puX = neckCx - puW / 2
        let puY = h * pyRel - puH / 2
        let puRect = CGRect(x: puX, y: puY, width: puW, height: puH)
        let puPath = RoundedRectangle(cornerRadius: 3).path(in: puRect)
        ctx.fill(puPath, with: .linearGradient(
            Gradient(colors: [Color(red: 0.99, green: 0.98, blue: 0.96), Color(red: 0.89, green: 0.88, blue: 0.85)]),
            startPoint: CGPoint(x: puRect.minX, y: puRect.minY), endPoint: CGPoint(x: puRect.maxX, y: puRect.maxY)))
        ctx.stroke(puPath, with: .color(Color(red: 0.75, green: 0.74, blue: 0.71)), style: StrokeStyle(lineWidth: 0.5))
        
        // 6 chrome pole pieces
        for j in 0..<6 {
            let px = puX + puW * 0.14 + CGFloat(j) * (puW * 0.144)
            let py = puY + puH * 0.50
            let pr = max(1.2, w * 0.007)
            ctx.fill(Circle().path(in: CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2)),
                     with: .color(Color(red: 0.65, green: 0.66, blue: 0.70)))
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 5. BRIDGE + TREMOLO ARM
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let brW = w * 0.175
    let brH = h * 0.030
    let brX = neckCx - brW / 2
    let brY = h * 0.740 - brH / 2
    let brRect = CGRect(x: brX, y: brY, width: brW, height: brH)
    ctx.fill(RoundedRectangle(cornerRadius: 2).path(in: brRect), with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.92, green: 0.93, blue: 0.96),
            Color(red: 0.68, green: 0.70, blue: 0.74),
            Color(red: 0.88, green: 0.90, blue: 0.93)
        ]),
        startPoint: CGPoint(x: brRect.minX, y: brRect.midY),
        endPoint: CGPoint(x: brRect.maxX, y: brRect.midY)))
    ctx.stroke(RoundedRectangle(cornerRadius: 2).path(in: brRect),
               with: .color(Color(red: 0.45, green: 0.46, blue: 0.50)), style: StrokeStyle(lineWidth: 0.8))
    for j in 0..<6 {
        let sx = brX + brW * 0.08 + CGFloat(j) * (brW * 0.145)
        let sRect = CGRect(x: sx, y: brY + brH * 0.10, width: brW * 0.12, height: brH * 0.75)
        ctx.fill(RoundedRectangle(cornerRadius: 1).path(in: sRect), with: .color(Color(red: 0.58, green: 0.60, blue: 0.65)))
    }
    // Whammy bar
    var bar = Path()
    bar.move(to: CGPoint(x: brX + brW * 0.90, y: brY + brH * 0.50))
    bar.addLine(to: CGPoint(x: brX + brW * 1.35, y: brY + brH * 1.50))
    bar.addLine(to: CGPoint(x: brX + brW * 1.25, y: brY - brH * 0.60))
    ctx.stroke(bar, with: .color(Color(red: 0.82, green: 0.84, blue: 0.87)),
               style: StrokeStyle(lineWidth: max(1.8, w * 0.012), lineCap: .round))
    ctx.fill(Capsule().path(in: CGRect(x: brX + brW * 1.25 - 2, y: brY - brH * 0.70, width: 5, height: 10)),
             with: .color(Color(red: 0.96, green: 0.95, blue: 0.92)))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 6. CONTROLS (Knobs & Jack)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for (kxRel, kyRel) in [(0.7053, 0.7000), (0.7579, 0.7283), (0.8105, 0.7572)] as [(CGFloat, CGFloat)] {
        let kr = w * 0.026
        let kx = w * kxRel
        let ky = h * kyRel
        let kRect = CGRect(x: kx - kr, y: ky - kr, width: kr * 2, height: kr * 2)
        ctx.fill(Circle().path(in: kRect), with: .radialGradient(
            Gradient(colors: [Color(red: 0.98, green: 0.97, blue: 0.94), Color(red: 0.85, green: 0.83, blue: 0.79)]),
            center: CGPoint(x: kx - kr * 0.3, y: ky - kr * 0.3), startRadius: 0, endRadius: kr))
        ctx.stroke(Circle().path(in: kRect), with: .color(Color(red: 0.70, green: 0.68, blue: 0.64)), style: StrokeStyle(lineWidth: 0.6))
        ctx.fill(Circle().path(in: CGRect(x: kx - kr * 0.6, y: ky - kr * 0.6, width: kr * 1.2, height: kr * 1.2)),
                 with: .color(.white.opacity(0.8)))
    }
    // Jack plate
    let jx = w * 0.82
    let jy = h * 0.80
    let jw = w * 0.11
    let jh = h * 0.035
    let jRect = CGRect(x: jx - jw / 2, y: jy - jh / 2, width: jw, height: jh)
    ctx.fill(Ellipse().path(in: jRect), with: .linearGradient(
        Gradient(colors: [Color(red: 0.92, green: 0.93, blue: 0.96), Color(red: 0.65, green: 0.67, blue: 0.72)]),
        startPoint: CGPoint(x: jRect.minX, y: jRect.minY), endPoint: CGPoint(x: jRect.maxX, y: jRect.maxY)))
    ctx.stroke(Ellipse().path(in: jRect), with: .color(Color(red: 0.45, green: 0.46, blue: 0.50)), style: StrokeStyle(lineWidth: 0.6))
    ctx.fill(Circle().path(in: CGRect(x: jx - 3.5, y: jy - 3.5, width: 7, height: 7)),
             with: .color(Color(red: 0.15, green: 0.15, blue: 0.18)))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 7. PROPORTIONAL NECK & FRETBOARD (Seamless Into Body to 21st Fret)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Authentic scale length: Nut at 0.250, body joint at 0.50, 21st fret terminates at 0.570 (just above neck pickup)
    let nutY = h * 0.250
    let neckBotY = h * 0.570
    let nutW = w * 0.112
    let neckBotW = w * 0.155
    
    var fbPath = Path()
    fbPath.move(to: CGPoint(x: neckCx - nutW / 2, y: nutY))
    fbPath.addLine(to: CGPoint(x: neckCx + nutW / 2, y: nutY))
    fbPath.addLine(to: CGPoint(x: neckCx + neckBotW / 2, y: neckBotY))
    fbPath.addLine(to: CGPoint(x: neckCx - neckBotW / 2, y: neckBotY))
    fbPath.closeSubpath()
    
    // Vintage amber hard-rock maple neck & fretboard (matching reference silhouette)
    ctx.fill(fbPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.94, green: 0.84, blue: 0.67),
            Color(red: 0.88, green: 0.76, blue: 0.58),
            Color(red: 0.82, green: 0.70, blue: 0.50)
        ]),
        startPoint: CGPoint(x: neckCx - nutW / 2, y: nutY),
        endPoint: CGPoint(x: neckCx + nutW / 2, y: nutY)))
    ctx.stroke(fbPath, with: .color(Color(red: 0.65, green: 0.52, blue: 0.35)), style: StrokeStyle(lineWidth: 0.7))
    
    // Frets (21 frets with realistic scale spacing)
    let fretColor = Color(red: 0.60, green: 0.50, blue: 0.40)
    for i in 1...21 {
        let t = pow(CGFloat(i) / 22.0, 0.88)
        let fy = nutY + (neckBotY - nutY) * t
        let curW = nutW + (neckBotW - nutW) * t
        var fp = Path()
        fp.move(to: CGPoint(x: neckCx - curW / 2, y: fy))
        fp.addLine(to: CGPoint(x: neckCx + curW / 2, y: fy))
        ctx.stroke(fp, with: .color(fretColor), style: StrokeStyle(lineWidth: 0.9))
    }
    
    // Classic black fret position markers (matching 1-piece maple neck)
    let dotColor = Color(red: 0.16, green: 0.14, blue: 0.12)
    for fret in [3, 5, 7, 9, 15, 17, 19, 21] {
        let t = pow((CGFloat(fret) - 0.5) / 22.0, 0.88)
        let dy = nutY + (neckBotY - nutY) * t
        let dr = max(1.4, w * 0.0065)
        ctx.fill(Circle().path(in: CGRect(x: neckCx - dr, y: dy - dr, width: dr * 2, height: dr * 2)), with: .color(dotColor))
    }
    // 12th fret double dot
    let t12 = pow(11.5 / 22.0, 0.88)
    let d12y = nutY + (neckBotY - nutY) * t12
    let d12w = nutW + (neckBotW - nutW) * t12
    let ddr = max(1.2, w * 0.0055)
    ctx.fill(Circle().path(in: CGRect(x: neckCx - d12w * 0.22 - ddr, y: d12y - ddr, width: ddr * 2, height: ddr * 2)), with: .color(dotColor))
    ctx.fill(Circle().path(in: CGRect(x: neckCx + d12w * 0.22 - ddr, y: d12y - ddr, width: ddr * 2, height: ddr * 2)), with: .color(dotColor))
    
    // Bone nut
    ctx.fill(RoundedRectangle(cornerRadius: 1).path(in: CGRect(x: neckCx - nutW * 0.52, y: nutY - 2.5, width: nutW * 1.04, height: 3.5)),
             with: .color(Color(red: 0.96, green: 0.95, blue: 0.90)))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 8. 6-IN-LINE HEADSTOCK (Telecaster / Stratocaster Style matching user reference)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let hsTop = h * 0.095
    let hsBot = nutY
    let hsH = hsBot - hsTop
    
    var hsPath = Path()
    let pNutL = CGPoint(x: neckCx - nutW * 0.50, y: nutY)
    let pNutR = CGPoint(x: neckCx + nutW * 0.50, y: nutY)
    
    hsPath.move(to: pNutL)
    
    // 1. Transition shoulder step out on the left
    hsPath.addQuadCurve(
        to: CGPoint(x: neckCx - nutW * 0.74, y: nutY - hsH * 0.08),
        control: CGPoint(x: neckCx - nutW * 0.65, y: nutY - hsH * 0.02)
    )
    
    // 2. Left slanted tuner edge (slants upward-right towards top crest)
    hsPath.addCurve(
        to: CGPoint(x: neckCx - nutW * 0.22, y: hsTop + hsH * 0.12),
        control1: CGPoint(x: neckCx - nutW * 0.68, y: hsBot - hsH * 0.38),
        control2: CGPoint(x: neckCx - nutW * 0.40, y: hsTop + hsH * 0.40)
    )
    
    // 3. Top-left shoulder rounding up over the crest
    hsPath.addCurve(
        to: CGPoint(x: neckCx + nutW * 0.18, y: hsTop),
        control1: CGPoint(x: neckCx - nutW * 0.14, y: hsTop + hsH * 0.03),
        control2: CGPoint(x: neckCx + nutW * 0.02, y: hsTop)
    )
    
    // 4. Iconic bulbous rounded tip / beak on the upper right (generous Fender curve)
    hsPath.addCurve(
        to: CGPoint(x: neckCx + nutW * 0.82, y: hsTop + hsH * 0.10),
        control1: CGPoint(x: neckCx + nutW * 0.42, y: hsTop + hsH * 0.01),
        control2: CGPoint(x: neckCx + nutW * 0.68, y: hsTop + hsH * 0.03)
    )
    hsPath.addCurve(
        to: CGPoint(x: neckCx + nutW * 0.76, y: hsTop + hsH * 0.24),
        control1: CGPoint(x: neckCx + nutW * 0.90, y: hsTop + hsH * 0.15),
        control2: CGPoint(x: neckCx + nutW * 0.86, y: hsTop + hsH * 0.21)
    )
    
    // 5. Classic graceful scoop (concave waist curve) on the right side
    hsPath.addCurve(
        to: CGPoint(x: neckCx + nutW * 0.46, y: hsTop + hsH * 0.58),
        control1: CGPoint(x: neckCx + nutW * 0.58, y: hsTop + hsH * 0.32),
        control2: CGPoint(x: neckCx + nutW * 0.44, y: hsTop + hsH * 0.44)
    )
    
    // 6. Smooth flare returning down to right edge of nut
    hsPath.addCurve(
        to: pNutR,
        control1: CGPoint(x: neckCx + nutW * 0.48, y: hsTop + hsH * 0.74),
        control2: CGPoint(x: neckCx + nutW * 0.50, y: nutY - hsH * 0.06)
    )
    hsPath.closeSubpath()
    
    // Rich vintage amber maple finish
    ctx.fill(hsPath, with: .linearGradient(
        Gradient(colors: [
            Color(red: 0.94, green: 0.84, blue: 0.67),
            Color(red: 0.88, green: 0.76, blue: 0.57),
            Color(red: 0.80, green: 0.66, blue: 0.47)
        ]),
        startPoint: CGPoint(x: neckCx - nutW * 0.4, y: hsTop),
        endPoint: CGPoint(x: neckCx + nutW * 0.4, y: hsBot)
    ))
    ctx.stroke(hsPath, with: .color(Color(red: 0.68, green: 0.54, blue: 0.36)), style: StrokeStyle(lineWidth: 1.0))
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 9. 6-IN-LINE TUNING PEGS ON LEFT EDGE
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    let postY0 = hsTop + hsH * 0.76  // Lowest post (string 0, low E)
    let postY5 = hsTop + hsH * 0.14  // Highest post (string 5, high E)
    
    for i in 0..<6 {
        let frac = CGFloat(i) / 5.0
        // Calculate point along left slanted edge
        let edgeX = (neckCx - nutW * 0.74) + (nutW * 0.50) * frac
        let edgeY = postY0 - (postY0 - postY5) * frac
        
        // Tuner post shaft protruding to the left
        let shaftLen = w * 0.026
        let shaftAngle = -0.22 // slightly tilted up-left
        let shaftEndX = edgeX - shaftLen * cos(shaftAngle)
        let shaftEndY = edgeY + shaftLen * sin(shaftAngle)
        
        var shaftPath = Path()
        shaftPath.move(to: CGPoint(x: edgeX, y: edgeY))
        shaftPath.addLine(to: CGPoint(x: shaftEndX, y: shaftEndY))
        ctx.stroke(shaftPath, with: .color(Color(red: 0.75, green: 0.76, blue: 0.80)),
                   style: StrokeStyle(lineWidth: max(1.6, w * 0.008), lineCap: .round))
        
        // Tuning peg button (oval / pill shaped knob)
        let btnW = w * 0.025
        let btnH = h * 0.011
        let btnRect = CGRect(x: shaftEndX - btnW * 0.6, y: shaftEndY - btnH / 2, width: btnW, height: btnH)
        ctx.fill(Capsule().path(in: btnRect), with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99),
                Color(red: 0.76, green: 0.78, blue: 0.83),
                Color(red: 0.89, green: 0.91, blue: 0.94)
            ]),
            startPoint: CGPoint(x: btnRect.minX, y: btnRect.minY),
            endPoint: CGPoint(x: btnRect.maxX, y: btnRect.maxY)
        ))
        ctx.stroke(Capsule().path(in: btnRect), with: .color(Color(red: 0.50, green: 0.52, blue: 0.56)), style: StrokeStyle(lineWidth: 0.6))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 10. 6 STRINGS & CIRCULAR HEADSTOCK POSTS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for i in 0..<6 {
        let frac = CGFloat(i) / 5.0
        let strX = (neckCx - nutW * 0.36) + nutW * 0.72 * frac
        let botX = (brX + brW * 0.12) + brW * 0.76 * frac
        let postY = postY0 - (postY0 - postY5) * frac
        
        // Fretboard string running over frets down to bridge
        var strPath = Path()
        strPath.move(to: CGPoint(x: botX, y: brY + brH * 0.20))
        strPath.addLine(to: CGPoint(x: strX, y: nutY))
        ctx.stroke(strPath, with: .color(Color.white.opacity(0.60 + frac * 0.25)),
                   style: StrokeStyle(lineWidth: 0.7 + (1.0 - frac) * 0.6))
        
        // Headstock string: runs straight vertically from nut into its circular post!
        var headStr = Path()
        headStr.move(to: CGPoint(x: strX, y: nutY))
        headStr.addLine(to: CGPoint(x: strX, y: postY))
        ctx.stroke(headStr, with: .color(Color.white.opacity(0.85)),
                   style: StrokeStyle(lineWidth: 0.7 + (1.0 - frac) * 0.5))
        
        // Circular string post (outer ring + inner hole) exactly matching user's image
        let postR: CGFloat = max(3.0, w * 0.014)
        let postRect = CGRect(x: strX - postR, y: postY - postR, width: postR * 2, height: postR * 2)
        // White/chrome ferrule ring
        ctx.fill(Circle().path(in: postRect), with: .color(Color.white.opacity(0.95)))
        ctx.stroke(Circle().path(in: postRect), with: .color(Color(red: 0.28, green: 0.30, blue: 0.34)), style: StrokeStyle(lineWidth: 1.1))
        // Inner post center (eyelet / hole)
        let innerR = postR * 0.50
        let innerRect = CGRect(x: strX - innerR, y: postY - innerR, width: innerR * 2, height: innerR * 2)
        ctx.fill(Circle().path(in: innerRect), with: .color(Color(red: 0.20, green: 0.18, blue: 0.16)))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 10. STAND FRONT CRADLE RETAINING PRONGS (CUPS GUITAR BOTTOM)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Natural look: the guitar is resting on the stand, unobstructed!
    let prongW = max(5.0, w * 0.038)
    let prongH = max(11.0, h * 0.022)
    
    for (cxRel, cyRel) in [(0.335, 0.870), (0.740, 0.870)] as [(CGFloat, CGFloat)] {
        let px = w * cxRel
        let py = h * cyRel
        let pRect = CGRect(x: px - prongW / 2, y: py - prongH * 0.6, width: prongW, height: prongH)
        ctx.fill(Capsule().path(in: pRect), with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.25, green: 0.25, blue: 0.28),
                Color(red: 0.10, green: 0.10, blue: 0.12)
            ]),
            startPoint: CGPoint(x: pRect.minX, y: pRect.minY), endPoint: CGPoint(x: pRect.maxX, y: pRect.maxY)))
        ctx.stroke(Capsule().path(in: pRect), with: .color(Color(red: 0.35, green: 0.35, blue: 0.40)), style: StrokeStyle(lineWidth: 0.6))
    }
}
