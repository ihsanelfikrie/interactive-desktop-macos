import Foundation
import SwiftUI
import AppKit

public final class SpotifyService: ObservableObject {
    public static let shared = SpotifyService()
    
    @Published public var trackTitle: String = "Tidak Ada Lagu"
    @Published public var artistName: String = "Spotify Siap"
    @Published public var albumName: String = ""
    @Published public var isPlaying: Bool = false
    @Published public var isSpotifyRunning: Bool = false
    
    private var observer: AnyObject?
    
    private init() {
        setupDistributedObserver()
        checkStatus()
    }
    
    // MARK: - Native Event-Driven Spotify Observer (0% CPU at idle)
    private func setupDistributedObserver() {
        let notificationName = NSNotification.Name("com.spotify.client.PlaybackStateChanged")
        observer = DistributedNotificationCenter.default().addObserver(
            forName: notificationName,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let userInfo = notification.userInfo {
                self.isSpotifyRunning = true
                if let name = userInfo["Name"] as? String {
                    self.trackTitle = name
                }
                if let artist = userInfo["Artist"] as? String {
                    self.artistName = artist
                }
                if let album = userInfo["Album"] as? String {
                    self.albumName = album
                }
                if let state = userInfo["Player State"] as? String {
                    self.isPlaying = (state.lowercased() == "playing")
                }
            }
        }
    }
    
    public func startPolling() {
        // Fast status check when mini player is opened
        checkStatus()
    }
    
    public func stopPolling() {
        // Event-driven observer handles ongoing updates natively
    }
    
    public func checkStatus() {
        let scriptSource = """
        tell application "System Events"
            set isRunning to (exists (processes where name is "Spotify"))
        end tell
        if isRunning then
            tell application "Spotify"
                try
                    set currentArtist to artist of current track
                    set currentTitle to name of current track
                    set currentAlbum to album of current track
                    set playerState to player state as string
                    return currentTitle & "|||" & currentArtist & "|||" & currentAlbum & "|||" & playerState
                on error
                    return "PAUSED_OR_EMPTY"
                end try
            end tell
        else
            return "NOT_RUNNING"
        end if
        """
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            if let script = NSAppleScript(source: scriptSource) {
                let output = script.executeAndReturnError(&error).stringValue ?? ""
                DispatchQueue.main.async {
                    self.parseOutput(output)
                }
            }
        }
    }
    
    private func parseOutput(_ output: String) {
        if output == "NOT_RUNNING" {
            self.isSpotifyRunning = false
            self.trackTitle = "Spotify Tidak Aktif"
            self.artistName = "Klik untuk membuka"
            self.albumName = ""
            self.isPlaying = false
            return
        }
        
        self.isSpotifyRunning = true
        
        if output == "PAUSED_OR_EMPTY" {
            self.trackTitle = "Spotify Terbuka"
            self.artistName = "Pilih lagu untuk memutar"
            self.albumName = ""
            self.isPlaying = false
            return
        }
        
        let parts = output.components(separatedBy: "|||")
        if parts.count >= 4 {
            self.trackTitle = parts[0]
            self.artistName = parts[1]
            self.albumName = parts[2]
            self.isPlaying = (parts[3] == "playing")
        }
    }
    
    public func playPause() {
        runAppleScript("""
        try
            tell application id "com.spotify.client" to playpause
        on error
            tell application "Spotify" to playpause
        end try
        """)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.checkStatus()
        }
    }
    
    public func nextTrack() {
        runAppleScript("""
        try
            tell application id "com.spotify.client" to next track
        on error
            tell application "Spotify" to next track
        end try
        """)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.checkStatus()
        }
    }
    
    public func previousTrack() {
        runAppleScript("""
        try
            tell application id "com.spotify.client" to previous track
        on error
            tell application "Spotify" to previous track
        end try
        """)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.checkStatus()
        }
    }
    
    public func openSpotify() {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client") {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        } else if let spotifyURI = URL(string: "spotify:") {
            NSWorkspace.shared.open(spotifyURI)
        }
    }
    
    private func runAppleScript(_ command: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            if let script = NSAppleScript(source: command) {
                script.executeAndReturnError(&error)
            }
        }
    }
}
