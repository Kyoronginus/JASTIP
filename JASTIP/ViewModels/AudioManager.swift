import AVFoundation
import UIKit

@MainActor
final class AudioManager {
    static let shared = AudioManager()
    private var players: [String: AVAudioPlayer] = [:]

func play(_ name: String, startTime: TimeInterval = 0) {
        if players[name] == nil {
            guard let data = NSDataAsset(name: name)?.data else {
                print("AudioManager: Aset '\(name)' tidak ditemukan di Assets.xcassets")
                return
            }
            players[name] = try? AVAudioPlayer(data: data)
        }
        guard let player = players[name] else { return }
        player.currentTime = startTime
        player.play()
    }

    func stopAll() {
        players.values.forEach { $0.stop() }
    }
}
