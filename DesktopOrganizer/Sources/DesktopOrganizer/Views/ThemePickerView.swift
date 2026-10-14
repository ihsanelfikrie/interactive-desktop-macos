import SwiftUI

public struct ThemePickerView: View {
    @Binding var currentTheme: RoomTheme
    @Binding var isPresented: Bool
    
    public init(currentTheme: Binding<RoomTheme>, isPresented: Binding<Bool>) {
        self._currentTheme = currentTheme
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Pilih Tema Ruangan")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
            
            Text("Ubah gaya visual ruangan desktop sesuai mood kamu")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            
            // Theme Options Cards
            HStack(spacing: 16) {
                ForEach(RoomTheme.allCases) { theme in
                    ThemeCardView(
                        theme: theme,
                        isSelected: currentTheme == theme
                    ) {
                        currentTheme = theme
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 24)
            
            // Footer
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Text("Selesai")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(width: 640)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ThemeCardView: View {
    let theme: RoomTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Miniature Pixel-Art Preview Box
                ZStack {
                    if let img = AssetLoader.image(named: theme.backgroundImageName) {
                        Image(nsImage: img)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 100)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 100)
                    }
                }
                .cornerRadius(6)
                
                Text(theme.displayName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(theme.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(10)
            .frame(width: 180, height: 220)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}
