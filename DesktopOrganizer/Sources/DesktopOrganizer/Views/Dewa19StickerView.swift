import SwiftUI
import AppKit

// MARK: - Native Vector DEWA 19 Die-Cut Sticker View
public struct Dewa19StickerView: View {
    @ObservedObject var appState = AppState.shared
    
    public let width: CGFloat
    public let height: CGFloat
    
    public init(width: CGFloat = 52, height: CGFloat = 35) {
        self.width = width
        self.height = height
    }
    
    private var isHovered: Bool {
        appState.isHoveringDewa19Sticker
    }
    
    private func openDewa19(query: String = "Dewa 19") {
        let escaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Dewa%2019"
        
        // 1. Try Spotify App Scheme
        if let spotifyURL = URL(string: "spotify:search:\(escaped)"), NSWorkspace.shared.open(spotifyURL) {
            return
        }
        
        // 2. Fallback to Spotify Web
        if let webURL = URL(string: "https://open.spotify.com/search/\(escaped)") {
            NSWorkspace.shared.open(webURL)
        }
    }
    
    private func openYouTube(query: String = "Dewa 19") {
        let escaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Dewa%2019"
        if let ytURL = URL(string: "https://www.youtube.com/results?search_query=\(escaped)") {
            NSWorkspace.shared.open(ytURL)
        }
    }
    
    public var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            
            // 1. Black sticker background with sharp lancip corners (no rounding)
            let bgRect = CGRect(origin: .zero, size: size)
            context.fill(Path(bgRect), with: .color(.black))
            
            // Sharp white perimeter border
            context.stroke(
                Path(bgRect.insetBy(dx: 0.8, dy: 0.8)),
                with: .color(.white),
                lineWidth: 1.0
            )
            
            // 2. Red "19" Block (placed below E)
            let redRect = CGRect(x: w * 0.28, y: h * 0.51, width: w * 0.22, height: h * 0.41)
            context.fill(Path(redRect), with: .color(Color(red: 0.88, green: 0.12, blue: 0.14)))
            
            // "19" number inside red block
            let numFont = Font.system(size: h * 0.27, weight: .heavy, design: .default)
            let numText = Text("19").font(numFont).foregroundColor(.black)
            context.draw(context.resolve(numText), at: CGPoint(x: redRect.midX, y: redRect.midY))
            
            // 3. Letters D, E, W, A using Times-Bold serif font
            let fontTall = Font.custom("Times-Bold", size: h * 0.76)
            
            // "D" (Tall condensed serif)
            var ctxD = context
            ctxD.translateBy(x: w * 0.155, y: h * 0.50)
            ctxD.scaleBy(x: 0.62, y: 1.25)
            let textD = Text("D").font(fontTall).foregroundColor(.white)
            ctxD.draw(ctxD.resolve(textD), at: .zero)
            
            // "E" (Smaller serif positioned top-middle)
            var ctxE = context
            ctxE.translateBy(x: w * 0.39, y: h * 0.28)
            ctxE.scaleBy(x: 0.82, y: 1.05)
            let fontE = Font.custom("Times-Bold", size: h * 0.46)
            let textE = Text("E").font(fontE).foregroundColor(.white)
            ctxE.draw(ctxE.resolve(textE), at: .zero)
            
            // "W" (Tall condensed serif)
            var ctxW = context
            ctxW.translateBy(x: w * 0.64, y: h * 0.50)
            ctxW.scaleBy(x: 0.56, y: 1.25)
            let textW = Text("W").font(fontTall).foregroundColor(.white)
            ctxW.draw(ctxW.resolve(textW), at: .zero)
            
            // "A" (Tall condensed serif)
            var ctxA = context
            ctxA.translateBy(x: w * 0.84, y: h * 0.50)
            ctxA.scaleBy(x: 0.56, y: 1.25)
            let textA = Text("A").font(fontTall).foregroundColor(.white)
            ctxA.draw(ctxA.resolve(textA), at: .zero)
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(isHovered ? -1.2 : -3.0))
        .scaleEffect(isHovered ? 1.06 : 1.0)
        .shadow(
            color: Color.black.opacity(isHovered ? 0.38 : 0.25),
            radius: isHovered ? 3.5 : 2.2,
            x: 0.5,
            y: isHovered ? 2.0 : 1.2
        )
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isHovered)
        .contentShape(Rectangle())
        .onHover { hovering in
            appState.isHoveringDewa19Sticker = hovering
        }
        .onTapGesture {
            openDewa19()
        }
        .contextMenu {
            Button("Putar Dewa 19 di Spotify") {
                openDewa19()
            }
            Divider()
            Button("Separuh Nafas") {
                openDewa19(query: "Dewa 19 Separuh Nafas")
            }
            Button("Kangen") {
                openDewa19(query: "Dewa 19 Kangen")
            }
            Button("Pupus") {
                openDewa19(query: "Dewa 19 Pupus")
            }
            Button("Roman Picisan") {
                openDewa19(query: "Dewa 19 Roman Picisan")
            }
            Button("Kamulah Satu-Satunya") {
                openDewa19(query: "Dewa 19 Kamulah Satu Satunya")
            }
            Divider()
            Button("Cari di YouTube") {
                openYouTube()
            }
        }
        .help("Stiker Dewa 19: Klik untuk memutar lagu di Spotify")
    }
}
