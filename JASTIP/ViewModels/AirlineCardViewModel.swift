//
//  AirlineCardViewModel.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 24/10/26.
//

import SwiftUI
import Observation
import UIKit
import CoreHaptics

@Observable
class AirlineCardViewModel {
    // MARK: - Model & Callback
    let airlineCard: AirlineCardModel
    var onProceedToGame: () -> Void
    
    // MARK: - State Animasi 3D Flip
    var isFlipped: Bool = false
    var rotationDegrees: Double = 0
    var showButton: Bool = false
    
    @ObservationIgnored private var flipHapticEngine: CHHapticEngine?
    @ObservationIgnored private var flipHapticPlayer: CHHapticPatternPlayer?

    private func playFlipHaptic(duration: TimeInterval) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            let engine = try CHHapticEngine()
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
                ],
                relativeTime: 0,
                duration: duration
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)

            try engine.start()
            try player.start(atTime: 0)

            flipHapticEngine = engine
            flipHapticPlayer = player
        } catch {
            print("Could not play airline-card flip haptic: \(error)")
        }
    }
    
    // MARK: - Hitung Total Ronde
    var totalRounds: Int {
        let clean = airlineCard.departureTime.replacingOccurrences(of: ".", with: ":")
        let hour = Int(clean.split(separator: ":").first ?? "15") ?? 15
        return max(hour - 8, 1)
    }
    
    // MARK: - Initialization
    init(airlineCard: AirlineCardModel, onProceedToGame: @escaping () -> Void = {}) {
        self.airlineCard = airlineCard
        self.onProceedToGame = onProceedToGame
    }
    
    // MARK: - Animasi (SAMA PERSIS DENGAN KODE LU)
    func triggerFlipAnimation() {
        // Mulai animasi flip setelah 1.0 detik
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.playFlipHaptic(duration: 0.7)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                self.rotationDegrees = 180
            }
            // Ganti ke sisi depan tepat saat kartu vertikal (90 derajat)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isFlipped = true
            }
            // Tampilkan tombol setelah flip selesai
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showButton = true
            }
        }
    }
    
    func proceed() {
        onProceedToGame()
    }
}
