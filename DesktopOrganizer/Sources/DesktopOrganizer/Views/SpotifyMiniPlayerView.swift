import SwiftUI
import AppKit

public struct SpotifyMiniPlayerView: View {
    @ObservedObject var spotify = SpotifyService.shared
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Liquid Glass Body Card
            VStack(spacing: 12) {
                // Header (Spotify branding & Close)
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "music.note")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.84, blue: 0.38))
                        Text("Spotify")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        spotify.stopPolling()
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.primary.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                }
                
                // Song details & status
                VStack(spacing: 4) {
                    // Playback status badge
                    HStack(spacing: 5) {
                        Circle()
                            .fill(spotify.isPlaying ? Color(red: 0.11, green: 0.84, blue: 0.38) : Color.secondary.opacity(0.5))
                            .frame(width: 6, height: 6)
                        Text(spotify.isPlaying ? "Sedang Memutar" : (spotify.isSpotifyRunning ? "Jeda" : "Spotify Siap"))
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundColor(spotify.isPlaying ? Color(red: 0.11, green: 0.84, blue: 0.38) : .secondary)
                    }
                    
                    Text(spotify.trackTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                    
                    Text(spotify.artistName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if !spotify.albumName.isEmpty && spotify.albumName != spotify.trackTitle {
                        Text(spotify.albumName)
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary.opacity(0.75))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                
                // Playback buttons: Previous, Play/Pause, Next
                HStack(spacing: 24) {
                    Button(action: {
                        spotify.previousTrack()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.primary.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .help("Lagu Sebelumnya")
                    
                    Button(action: {
                        spotify.playPause()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.11, green: 0.84, blue: 0.38))
                                .frame(width: 36, height: 36)
                                .shadow(color: Color(red: 0.11, green: 0.84, blue: 0.38).opacity(0.35), radius: 6, y: 2)
                            
                            Image(systemName: spotify.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .help(spotify.isPlaying ? "Jeda Lagu" : "Putar Lagu")
                    
                    Button(action: {
                        spotify.nextTrack()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.primary.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .help("Lagu Berikutnya")
                }
                .padding(.vertical, 2)
                
                // "Buka Spotify" button
                Button(action: {
                    spotify.openSpotify()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Buka Aplikasi Spotify")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.primary.opacity(0.07)))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(width: 255)
            .background(
                ZStack {
                    VisualEffectView(material: .popover, blendingMode: .withinWindow)
                    
                    Color(NSColor.windowBackgroundColor).opacity(0.65)
                    
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.20), radius: 24, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            
            // Pointer arrow pointing down towards radio
            DownArrowPointer()
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.85))
                .background(
                    DownArrowPointer()
                        .fill(Color.white.opacity(0.3))
                )
                .frame(width: 16, height: 8)
                .overlay(
                    DownArrowPointer()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.60), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .offset(y: -1)
        }
        .onAppear {
            spotify.startPolling()
        }
        .onDisappear {
            spotify.stopPolling()
        }
    }
}

private struct DownArrowPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
