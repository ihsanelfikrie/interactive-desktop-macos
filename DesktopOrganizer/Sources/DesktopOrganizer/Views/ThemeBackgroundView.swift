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
            let wallHeight = height * 0.72
            let floorHeight = height * 0.28
            
            ZStack(alignment: .top) {
                // MARK: - Upper Wall Section
                ZStack(alignment: .bottom) {
                    // Base wall color
                    theme.wallColorPrimary
                    
                    // Wall patterns based on theme
                    switch theme {
                    case .library:
                        // Vertical wallpaper stripes
                        HStack(spacing: 0) {
                            ForEach(0..<Int(width / 36) + 2, id: \.self) { i in
                                Rectangle()
                                    .fill(i % 2 == 0 ? theme.wallColorSecondary.opacity(0.4) : Color.clear)
                                    .frame(width: 36)
                            }
                        }
                        
                        // Wainscoting / Wood paneling lower wall
                        VStack(spacing: 0) {
                            // Chair rail molding line
                            Rectangle()
                                .fill(theme.woodColor.opacity(0.95))
                                .frame(height: 14)
                                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
                            
                            // Lower wooden wainscot panels
                            ZStack {
                                theme.woodColor
                                HStack(spacing: 24) {
                                    ForEach(0..<Int(width / 160) + 1, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.black.opacity(0.25), lineWidth: 3)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(theme.woodColor.opacity(0.85))
                                            )
                                            .padding(.vertical, 14)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .frame(height: wallHeight * 0.36)
                        }
                        
                    case .kosKosan:
                        // Indonesian boarding room style
                        VStack(spacing: 0) {
                            Spacer()
                            // White/Grey ceramic wall skirting
                            Rectangle()
                                .fill(Color(red: 0.88, green: 0.90, blue: 0.92))
                                .frame(height: 24)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                    case .taman:
                        // Outdoor sky with clouds
                        ZStack {
                            LinearGradient(
                                colors: [Color(red: 0.45, green: 0.72, blue: 0.94), Color(red: 0.82, green: 0.92, blue: 0.98)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Distant trees/hedges
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
                    // Baseboard molding shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 3)
                    
                    ZStack {
                        theme.floorColor
                        
                        switch theme {
                        case .library:
                            // Wood plank lines
                            VStack(spacing: 28) {
                                ForEach(0..<Int(floorHeight / 28) + 1, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.18))
                                        .frame(height: 1.5)
                                }
                            }
                        case .kosKosan:
                            // Tile grid pattern
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
                        case .taman:
                            // Grass texture dots / speckles
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
}
