//
//  QRScannerViewModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI
import AVFoundation
import CoreHaptics
import UIKit

@Observable
class QRScannerViewModel {
    let scanner = QRScannerManager()
    
    var scannedCode: String? = nil
    var detectedPiece: PieceModel? = nil
    var confirmedWeight: Int? = nil
    
    var session: GameSessionViewModel
    var onScanned: ((PieceModel?, String, Int?, Bool) -> Void)? = nil
    var audioPlayer: AVAudioPlayer?
    private var hapticEngine: CHHapticEngine?
    
    var headerTitle: String {
        confirmedWeight != nil ? "PIECE TERKONFIRMASI" : "QR TERDETEKSI"
    }
    
    var isShowingPopup: Bool {
        scannedCode != nil
    }
    
    init(session: GameSessionViewModel, onScanned: ((PieceModel?, String, Int?, Bool) -> Void)? = nil) {
        self.session = session
        self.onScanned = onScanned
        setupAudioPlayer()
        setupHaptics()
    }
    
    func startScanning() {
        scanner.startScanning()
        scanner.onCodeDetected = { [weak self] code in
            self?.handleDetectedCode(code)
        }
    }
    
    func stopScanning() {
        scanner.stopScanning()
    }
    
    func handleDetectedCode(_ code: String) {
        guard scannedCode == nil else { return }
        playBeep()
        playScanHaptic()
        self.scannedCode = code
        self.detectedPiece = PieceCatalog.findPiece(by: code)
        self.confirmedWeight = session.weight(for: code)
    }
    
    func confirmWeight() {
        guard let code = scannedCode else { return }
        self.confirmedWeight = session.weight(for: code)
    }
    
    func resetScan() {
        self.scannedCode = nil
        self.detectedPiece = nil
        self.confirmedWeight = nil
        scanner.startScanning()
    }
    
    func finishScan(isSuitcase: Bool) {
        guard let code = scannedCode else { return }
        onScanned?(detectedPiece, code, confirmedWeight, isSuitcase)
    }
    
    // Fungsi lama: tambahkan isSuitcase di onScanned
    func selectDestination(isSuitcase: Bool) {
        guard let code = scannedCode, let weight = confirmedWeight, let piece = detectedPiece else { return }
        session.recordItemPlacement(piece: piece, weight: weight, isSuitcase: isSuitcase)
        onScanned?(piece, code, weight, isSuitcase)
    }
    
    func confirmAndContinue(isSuitcase: Bool) {
        guard let code = scannedCode, let weight = confirmedWeight, let piece = detectedPiece else { return }
        onScanned?(piece, code, weight, isSuitcase)
    }
    
    func flipCamera() {
        scanner.flipCamera()
    }
    
    // preload audio ke buffer hardware)
    private func setupAudioPlayer() {
        guard let data = NSDataAsset(name: "cashier-beep")?.data else { return }
        audioPlayer = try? AVAudioPlayer(data: data)
        audioPlayer?.currentTime = 0.27 // Langsung arahkan ke titik suara mulai
        audioPlayer?.prepareToPlay()
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            hapticEngine = nil
        }
    }

    private func playScanHaptic() {
        guard let hapticEngine else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: 0.8
        )
        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: 0.5
        )
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 0.35
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func playBeep() {
        audioPlayer?.currentTime = 0.27 // Reset ke titik suara mulai, bukan ke bagian hening
        audioPlayer?.play()
    }
}
