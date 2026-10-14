import SwiftUI

public struct ThemeBackgroundView: View {
    let theme: RoomTheme
    let isNightMode: Bool
    
    public init(theme: RoomTheme, isNightMode: Bool = false) {
        self.theme = theme
        self.isNightMode = isNightMode
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                // Official Pixel-art background if available
                if let nsImg = AssetLoader.image(named: theme.backgroundImageName) {
                    Image(nsImage: nsImg)
                        .resizable()
                        .interpolation(.none) // Preserve crisp pixel-art look
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipped()
                } else {
                    proceduralBackground(width: width, height: height)
                }
            }
        }
    }
    
    private var wallColorPrimary: Color {
        switch theme {
        case .library: return Color(red: 0.16, green: 0.32, blue: 0.30)
        case .kos: return Color(red: 0.78, green: 0.90, blue: 0.88)
        case .garden: return Color(red: 0.65, green: 0.84, blue: 0.95)
        }
    }
    
    private var wallColorSecondary: Color {
        switch theme {
        case .library: return Color(red: 0.12, green: 0.25, blue: 0.23)
        case .kos: return Color(red: 0.72, green: 0.86, blue: 0.84)
        case .garden: return Color(red: 0.55, green: 0.78, blue: 0.92)
        }
    }
    
    private var floorColor: Color {
        switch theme {
        case .library: return Color(red: 0.24, green: 0.15, blue: 0.10)
        case .kos: return Color(red: 0.92, green: 0.93, blue: 0.94)
        case .garden: return Color(red: 0.30, green: 0.58, blue: 0.25)
        }
    }
    
    private var woodColor: Color {
        switch theme {
        case .library: return Color(red: 0.38, green: 0.23, blue: 0.14)
        case .kos: return Color(red: 0.85, green: 0.74, blue: 0.60)
        case .garden: return Color(red: 0.45, green: 0.30, blue: 0.18)
        }
    }

    @ViewBuilder
    private func proceduralBackground(width: CGFloat, height: CGFloat) -> some View {
        let wallHeight = height * 0.72
        let floorHeight = height * 0.28
        
        ZStack(alignment: .top) {
            // MARK: - Upper Wall Section
            ZStack(alignment: .bottom) {
                wallColorPrimary
                
                switch theme {
                case .library:
                    HStack(spacing: 0) {
                        ForEach(0..<Int(width / 36) + 2, id: \.self) { i in
                            Rectangle()
                                .fill(i % 2 == 0 ? wallColorSecondary.opacity(0.4) : Color.clear)
                                .frame(width: 36)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(woodColor.opacity(0.95))
                            .frame(height: 14)
                            .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
                        
                        ZStack {
                            woodColor
                            HStack(spacing: 24) {
                                ForEach(0..<Int(width / 160) + 1, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.black.opacity(0.25), lineWidth: 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(woodColor.opacity(0.85))
                                        )
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(height: wallHeight * 0.36)
                    }
                    
                case .kos:
                    VStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(Color(red: 0.88, green: 0.90, blue: 0.92))
                            .frame(height: 24)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                case .garden:
                    ZStack {
                        LinearGradient(
                            colors: [Color(red: 0.45, green: 0.72, blue: 0.94), Color(red: 0.82, green: 0.92, blue: 0.98)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                ForEach(0..<Int(width / 70) + 2, id: \.self) { _ in
                                    Circle()
                                        .fill(Color(red: 0.22, green: 0.52, blue: 0.25))
                                        .frame(width: 90, height: 90)
                                        .offset(y: 35)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: width, height: wallHeight)
            
            // MARK: - Floor Section
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 3)
                
                ZStack {
                    floorColor
                    
                    switch theme {
                    case .library:
                        VStack(spacing: 28) {
                            ForEach(0..<Int(floorHeight / 28) + 1, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.black.opacity(0.18))
                                    .frame(height: 1.5)
                            }
                        }
                    case .kos:
                        ZStack {
                            VStack(spacing: 48) {
                                ForEach(0..<Int(floorHeight / 48) + 1, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.25))
                                        .frame(height: 1.5)
                                }
                            }
                            HStack(spacing: 48) {
                                ForEach(0..<Int(width / 48) + 1, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.25))
                                        .frame(width: 1.5)
                                }
                            }
                        }
                    case .garden:
                        LinearGradient(
                            colors: [Color(red: 0.28, green: 0.62, blue: 0.22), Color(red: 0.22, green: 0.50, blue: 0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            }
            .frame(width: width, height: floorHeight)
            .offset(y: wallHeight)
        }
    }
}
