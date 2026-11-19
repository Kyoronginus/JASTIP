//
//  AirlineCardViewModel.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 24/10/26.
//

import SwiftUI
import Observation
import AudioToolbox

@Observable
@MainActor
final class AirlineCardViewModel {
    private enum MessageSound {
        static let sent: SystemSoundID = 1004
    }

    // MARK: - Model & Callback
    let airlineCard: AirlineCardModel
    var onProceedToGame: () -> Void

    // MARK: - Sequential Chat Reveal State
    var visibleBubbleCount: Int = 0
    var showButton: Bool = false
    var isFadingOut: Bool = false

    @ObservationIgnored private var sequenceTask: Task<Void, Never>?

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

    // MARK: - Sequential Bubble Animation
    func startRevealSequence(reduceMotion: Bool = false) {
        sequenceTask?.cancel()
        guard visibleBubbleCount == 0, !isFadingOut else { return }

        let bubbleDelaysNs: [UInt64] = reduceMotion
            ? [250_000_000, 450_000_000, 500_000_000]
            : [350_000_000, 750_000_000, 850_000_000]
        let buttonDelayNs: UInt64 = reduceMotion ? 350_000_000 : 550_000_000

        sequenceTask = Task { [weak self] in
            guard let self else { return }

            for (index, delayNs) in bubbleDelaysNs.enumerated() {
                try? await Task.sleep(nanoseconds: delayNs)
                guard !Task.isCancelled else { return }

                let animation: Animation = reduceMotion
                    ? .easeInOut(duration: 0.25)
                    : .spring(response: 0.4, dampingFraction: 0.82)

                withAnimation(animation) {
                    self.visibleBubbleCount = index + 1
                }
                AudioServicesPlaySystemSound(MessageSound.sent)
            }

            try? await Task.sleep(nanoseconds: buttonDelayNs)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.3)) {
                self.showButton = true
            }
        }
    }

    func cancelRevealSequence() {
        sequenceTask?.cancel()
        sequenceTask = nil
    }

    func proceed(reduceMotion: Bool = false) {
        guard !isFadingOut else { return }
        sequenceTask?.cancel()

        let fadeDuration = reduceMotion ? 0.25 : 0.35
        withAnimation(.easeInOut(duration: fadeDuration)) {
            isFadingOut = true
        }

        let transitionDelayNs = UInt64((fadeDuration + 0.05) * 1_000_000_000)
        sequenceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: transitionDelayNs)
            guard !Task.isCancelled else { return }
            self?.onProceedToGame()
        }
    }
}
