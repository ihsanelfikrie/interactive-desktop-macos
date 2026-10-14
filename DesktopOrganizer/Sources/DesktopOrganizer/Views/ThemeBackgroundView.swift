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
                        .interpolation(.high) // Smooth, crisp anti-aliased rendering on Retina displays
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
        SANSColors.primaryBlue
    }
    
    private var wallColorSecondary: Color {
        SANSColors.darkIndigo
    }
    
    private var floorColor: Color {
        Color(red: 0.71, green: 0.52, blue: 0.34) // Warm honey oak hardwood
    }
    
    private var woodColor: Color {
        Color(red: 0.32, green: 0.20, blue: 0.12) // Rich walnut wainscoting
    }

    @ViewBuilder
    private func proceduralBackground(width: CGFloat, height: CGFloat) -> some View {
        let wallHeight = height * 0.72
        let floorHeight = height * 0.28
        
        ZStack(alignment: .top) {
            // MARK: - Upper Wall Section (SANS Electric Blue & Dark Indigo Stripes)
            ZStack(alignment: .bottom) {
                wallColorPrimary
                
                HStack(spacing: 0) {
                    ForEach(0..<Int(width / 36) + 2, id: \.self) { i in
                        Rectangle()
                            .fill(i % 2 == 0 ? wallColorSecondary.opacity(0.35) : Color.clear)
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
            }
            .frame(width: width, height: wallHeight)
            
            // MARK: - Floor Section
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 3)
                
                ZStack {
                    floorColor
                    VStack(spacing: 28) {
                        ForEach(0..<Int(floorHeight / 28) + 1, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.18))
                                .frame(height: 1.5)
                        }
                    }
                }
            }
            .frame(width: width, height: floorHeight)
            .offset(y: wallHeight)
        }
    }
}
