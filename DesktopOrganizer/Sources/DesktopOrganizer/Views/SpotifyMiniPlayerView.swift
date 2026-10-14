import SwiftUI

public struct SpotifyMiniPlayerView: View {
    @ObservedObject var spotify = SpotifyService.shared
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                    Text("Spotify")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    spotify.stopPolling()
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            
            // Song details
            VStack(spacing: 3) {
                Text(spotify.trackTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(spotify.artistName)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            
            // Playback buttons
            HStack(spacing: 20) {
                Button(action: {
                    spotify.previousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    spotify.playPause()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                        Image(systemName: spotify.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    spotify.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            
            // "Buka Spotify" button
            Button(action: {
                spotify.openSpotify()
            }) {
                Text("Buka Spotify")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.88, green: 0.88, blue: 0.82))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 230)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.16, green: 0.20, blue: 0.18).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
        )
        .onAppear {
            spotify.startPolling()
        }
        .onDisappear {
            spotify.stopPolling()
        }
    }
}
