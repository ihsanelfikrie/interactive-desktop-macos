import SwiftUI
import UniformTypeIdentifiers
import AppKit

// MARK: - Native Modern Stainless Steel Step Trash Can View (2.5D Isometric Vector Art)
public struct TrashCanView: View {
    @ObservedObject var storage = StorageManager.shared
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private let canWidth: CGFloat = 84
    private let canHeight: CGFloat = 114
    
    private var trashCount: Int {
        guard let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first,
              let contents = try? FileManager.default.contentsOfDirectory(at: trashURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return 0 }
        return contents.count
    }
    
    public var body: some View {
        let cx: CGFloat = canWidth * 0.5 // 42 pt
        let topW: CGFloat = 72
        let botW: CGFloat = 64
        let topY: CGFloat = 20
        let botY: CGFloat = 96
        let topArc: CGFloat = 7.0
        let botArc: CGFloat = 7.5
        
        let isOpen = appState.isTrashTargeted
        let isHovered = appState.isHoveringTrash
        
        ZStack(alignment: .topLeading) {
            // 1. Soft Floor Contact Shadows
            // Ambient soft floor shadow
            Ellipse()
                .fill(Color(red: 0.05, green: 0.16, blue: 0.07).opacity(0.48))
                .frame(width: canWidth * 0.95, height: 18)
                .blur(radius: 5.5)
                .position(x: cx, y: botY + 11)
            
            // Core contact shadow directly under cylinder base
            Ellipse()
                .fill(Color.black.opacity(0.40))
                .frame(width: botW + 6, height: 10)
                .blur(radius: 2)
                .position(x: cx, y: botY + 7.5)
            
            // Pedal contact shadow
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.30))
                .frame(width: 26, height: 5)
                .blur(radius: 1.5)
                .position(x: cx, y: botY + 10.5)
            
            // 2. Base Rubber Gasket Ring (Directly attached to cylinder bottom)
            Canvas { ctx, size in
                let leftX = cx - (botW * 0.5) - 1.5
                let rightX = cx + (botW * 0.5) + 1.5
                
                var path = Path()
                path.move(to: CGPoint(x: leftX, y: botY))
                path.addQuadCurve(to: CGPoint(x: rightX, y: botY), control: CGPoint(x: cx, y: botY + botArc))
                path.addLine(to: CGPoint(x: rightX, y: botY + 5))
                path.addQuadCurve(to: CGPoint(x: leftX, y: botY + 5), control: CGPoint(x: cx, y: botY + botArc + 5))
                path.closeSubpath()
                
                ctx.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.22, green: 0.23, blue: 0.26),
                            Color(red: 0.12, green: 0.13, blue: 0.15)
                        ]),
                        startPoint: CGPoint(x: leftX, y: botY),
                        endPoint: CGPoint(x: rightX, y: botY + 5)
                    )
                )
            }
            .frame(width: canWidth, height: canHeight)
            
            // 3. Chrome Foot Pedal (Front center)
            ZStack {
                // Bracket housing
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(red: 0.16, green: 0.17, blue: 0.20))
                    .frame(width: 20, height: 5)
                    .offset(y: 1.5)
                
                // Chrome Pedal Lever
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.98, blue: 1.0),
                                    Color(red: 0.70, green: 0.74, blue: 0.78),
                                    Color(red: 0.88, green: 0.91, blue: 0.94)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.white.opacity(0.65), lineWidth: 0.5)
                        )
                    
                    // Rubber grip treads
                    HStack(spacing: 2.2) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color(red: 0.16, green: 0.17, blue: 0.19))
                                .frame(width: 1.2, height: 5.5)
                        }
                    }
                }
                .frame(width: 24, height: 7)
                .shadow(color: .black.opacity(0.28), radius: 1, y: 1)
                .offset(y: isOpen ? 3.5 : (isHovered ? 1.2 : 0))
            }
            .position(x: cx, y: botY + 5)
            
            // 4. Main Canister Body (Tapered 2.5D Brushed Stainless Steel Cylinder)
            Canvas { ctx, size in
                let leftTopX = cx - (topW * 0.5)
                let rightTopX = cx + (topW * 0.5)
                let leftBotX = cx - (botW * 0.5)
                let rightBotX = cx + (botW * 0.5)
                
                // Front Body Contour
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: leftTopX, y: topY))
                bodyPath.addQuadCurve(to: CGPoint(x: rightTopX, y: topY), control: CGPoint(x: cx, y: topY + topArc))
                bodyPath.addLine(to: CGPoint(x: rightBotX, y: botY))
                bodyPath.addQuadCurve(to: CGPoint(x: leftBotX, y: botY), control: CGPoint(x: cx, y: botY + botArc))
                bodyPath.closeSubpath()
                
                // Photorealistic Brushed Stainless Steel Gradient
                ctx.fill(
                    bodyPath,
                    with: .linearGradient(
                        Gradient(stops: [
                            .init(color: Color(red: 0.48, green: 0.51, blue: 0.55), location: 0.0),
                            .init(color: Color(red: 0.74, green: 0.77, blue: 0.81), location: 0.14),
                            .init(color: Color(red: 0.97, green: 0.98, blue: 1.0), location: 0.34),
                            .init(color: Color(red: 0.82, green: 0.85, blue: 0.88), location: 0.54),
                            .init(color: Color(red: 0.42, green: 0.45, blue: 0.49), location: 0.84),
                            .init(color: Color(red: 0.68, green: 0.71, blue: 0.75), location: 1.0)
                        ]),
                        startPoint: CGPoint(x: leftTopX, y: topY),
                        endPoint: CGPoint(x: rightTopX, y: topY)
                    )
                )
                
                // Vertical Brushed Grain Texture Lines
                for x in stride(from: leftTopX + 2.5, through: rightTopX - 2.5, by: 3.5) {
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: topY + 2))
                    let botLineX = (x - leftTopX) / topW * botW + leftBotX
                    line.addLine(to: CGPoint(x: botLineX, y: botY - 2))
                    ctx.stroke(line, with: .color(Color.white.opacity(0.05)), lineWidth: 0.7)
                }
                
                // Left & Right Outer Edge Shading
                var leftEdge = Path()
                leftEdge.move(to: CGPoint(x: leftTopX, y: topY))
                leftEdge.addLine(to: CGPoint(x: leftBotX, y: botY))
                ctx.stroke(leftEdge, with: .color(Color.white.opacity(0.35)), lineWidth: 0.6)
                
                var rightEdge = Path()
                rightEdge.move(to: CGPoint(x: rightTopX, y: topY))
                rightEdge.addLine(to: CGPoint(x: rightBotX, y: botY))
                ctx.stroke(rightEdge, with: .color(Color.black.opacity(0.30)), lineWidth: 0.6)
            }
            .frame(width: canWidth, height: canHeight)
            
            // Minimalist Front Status Indicator
            Circle()
                .fill(
                    trashCount > 0
                        ? Color(red: 0.96, green: 0.62, blue: 0.20)
                        : Color(red: 0.40, green: 0.82, blue: 0.52)
                )
                .frame(width: 3.6, height: 3.6)
                .overlay(Circle().stroke(Color.white.opacity(0.65), lineWidth: 0.5))
                .shadow(
                    color: trashCount > 0 ? Color.orange.opacity(0.8) : Color.green.opacity(0.6),
                    radius: 2.5
                )
                .position(x: cx, y: topY + 16)
            
            // 5. Inner Trash Can Cavity & Paper Contents (Visible when lid opens)
            ZStack {
                // Dark Inner Liner Bucket Void
                Ellipse()
                    .fill(Color(red: 0.10, green: 0.11, blue: 0.13))
                    .frame(width: topW - 6, height: topArc * 2)
                    .overlay(Ellipse().stroke(Color(red: 0.24, green: 0.26, blue: 0.29), lineWidth: 0.8))
                
                // Crumpled Paper Waste
                if trashCount > 0 || isOpen {
                    Canvas { ctx, size in
                        let cw = size.width
                        let ch = size.height
                        
                        var paper = Path()
                        paper.move(to: CGPoint(x: cw * 0.30, y: ch * 0.65))
                        paper.addLine(to: CGPoint(x: cw * 0.38, y: ch * 0.20))
                        paper.addLine(to: CGPoint(x: cw * 0.50, y: ch * 0.42))
                        paper.addLine(to: CGPoint(x: cw * 0.64, y: ch * 0.15))
                        paper.addLine(to: CGPoint(x: cw * 0.72, y: ch * 0.60))
                        paper.addLine(to: CGPoint(x: cw * 0.54, y: ch * 0.85))
                        paper.closeSubpath()
                        
                        ctx.fill(
                            paper,
                            with: .linearGradient(
                                Gradient(colors: [
                                    Color.white,
                                    Color(red: 0.86, green: 0.87, blue: 0.90),
                                    Color(red: 0.72, green: 0.74, blue: 0.77)
                                ]),
                                startPoint: CGPoint(x: cw * 0.40, y: ch * 0.15),
                                endPoint: CGPoint(x: cw * 0.60, y: ch * 0.85)
                            )
                        )
                        
                        var crease = Path()
                        crease.move(to: CGPoint(x: cw * 0.38, y: ch * 0.20))
                        crease.addLine(to: CGPoint(x: cw * 0.48, y: ch * 0.52))
                        crease.addLine(to: CGPoint(x: cw * 0.64, y: ch * 0.15))
                        ctx.stroke(crease, with: .color(Color.black.opacity(0.18)), lineWidth: 0.8)
                    }
                    .frame(width: topW - 10, height: topArc * 2)
                    .offset(y: -1)
                }
            }
            .position(x: cx, y: topY)
            
            // 6. Polished Chrome Upper Collar Rim
            Ellipse()
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.58, green: 0.62, blue: 0.66), location: 0.0),
                            .init(color: Color(red: 0.98, green: 0.98, blue: 1.0), location: 0.25),
                            .init(color: Color(red: 0.76, green: 0.79, blue: 0.83), location: 0.50),
                            .init(color: Color(red: 0.46, green: 0.49, blue: 0.53), location: 0.85),
                            .init(color: Color(red: 0.86, green: 0.89, blue: 0.93), location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.0
                )
                .frame(width: topW + 1, height: topArc * 2 + 1)
                .position(x: cx, y: topY)
            
            // 7. Modern Soft-Close Stainless Steel Lid
            ZStack {
                // Elliptical Lid Top
                Ellipse()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.52, green: 0.55, blue: 0.59), location: 0.0),
                                .init(color: Color(red: 0.80, green: 0.83, blue: 0.86), location: 0.20),
                                .init(color: Color(red: 0.97, green: 0.98, blue: 1.0), location: 0.38),
                                .init(color: Color(red: 0.82, green: 0.85, blue: 0.89), location: 0.60),
                                .init(color: Color(red: 0.46, green: 0.49, blue: 0.53), location: 0.88),
                                .init(color: Color(red: 0.72, green: 0.75, blue: 0.78), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Ellipse()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.black.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.8
                            )
                    )
                
                // Front Chrome Recessed Lip Handle
                RoundedRectangle(cornerRadius: 1.2)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.35), Color.white.opacity(0.25)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 16, height: 2.2)
                    .offset(y: topArc * 0.70)
            }
            .frame(width: topW + 3, height: topArc * 2 + 2)
            .shadow(
                color: Color.black.opacity(isOpen ? 0.38 : 0.20),
                radius: isOpen ? 6 : 2,
                y: isOpen ? 4 : 1
            )
            // 3D Perspective Tilt on Opening (Rear Hinge)
            .rotation3DEffect(
                .degrees(isOpen ? 58 : (isHovered ? 12 : 0)),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top
            )
            .position(x: cx, y: isOpen ? topY - 14 : (isHovered ? topY - 2 : topY))
            .animation(.spring(response: 0.32, dampingFraction: 0.74), value: isOpen)
            .animation(.spring(response: 0.25, dampingFraction: 0.80), value: isHovered)
            
            // 8. Drop Target Indicator (Glowing badge when dragging a file over trash)
            if isOpen {
                HStack(spacing: 5) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Buang ke Sampah")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.88))
                        .shadow(color: Color.red.opacity(0.6), radius: 6, y: 2)
                )
                .position(x: cx, y: topY - 26)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: canWidth, height: canHeight)
        .contentShape(Rectangle())
        .shadow(
            color: isOpen
                ? Color.red.opacity(0.55)
                : (isHovered ? Color.black.opacity(0.28) : Color.black.opacity(0.14)),
            radius: isOpen ? 12 : (isHovered ? 8 : 4),
            x: 0,
            y: 3
        )
        .scaleEffect(isOpen ? 1.04 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isOpen)
        .onHover { hovering in
            appState.isHoveringTrash = hovering
        }
        .onTapGesture(count: 2) {
            if let trashURL = FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first {
                NSWorkspace.shared.open(trashURL)
            }
        }
        .onTapGesture {
            appState.toggleQuickView(.trash)
        }
        .help("Tempat Sampah Modern: Klik 1x untuk opsi & kosongkan sampah, klik 2x untuk buka di Finder. Tarik file ke sini untuk membuangnya.")
        .onDrop(of: [.fileURL, .folder, .directory, .item], isTargeted: Binding(
            get: { appState.isTrashTargeted },
            set: { appState.isTrashTargeted = $0 }
        )) { providers in
            for provider in providers {
                StorageManager.extractFileURL(from: provider) { url in
                    _ = storage.moveToTrash(url: url)
                }
            }
            return true
        }
    }
}
