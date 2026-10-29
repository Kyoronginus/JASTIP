//
//  QRScannerViewModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI
import AVFoundation

@Observable
class QRScannerViewModel {
    let scanner = QRScannerManager()
    
    var scannedCode: String? = nil
    var detectedPiece: PieceModel? = nil
    var confirmedWeight: Int? = nil
    
    var session: GameSessionViewModel
    var onScanned: ((PieceModel?, String, Int?) -> Void)? = nil
    var audioPlayer: AVAudioPlayer?
    
    var headerTitle: String {
        confirmedWeight != nil ? "PIECE TERKONFIRMASI" : "QR TERDETEKSI"
    }
    
    var isShowingPopup: Bool {
        scannedCode != nil
    }
    
    init(session: GameSessionViewModel, onScanned: ((PieceModel?, String, Int?) -> Void)? = nil) {
        self.session = session
        self.onScanned = onScanned
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
        self.scannedCode = code
        self.detectedPiece = PieceCatalog.findPiece(by: code)
        self.confirmedWeight = nil
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
    
    func finishScan() {
        guard let code = scannedCode else { return }
        onScanned?(detectedPiece, code, confirmedWeight)
    }
    
    // Fungsi baru untuk menangani pilihan tempat penyimpanan item
    func selectDestination(isSuitcase: Bool) {
        guard let code = scannedCode, let weight = confirmedWeight, let piece = detectedPiece else { return }
        
        // Catat ke session (carousel & weight tracker)
        session.recordItemPlacement(piece: piece, weight: weight, isSuitcase: isSuitcase)
        
        // Selesaikan scan dan tutup popup/scanner
        onScanned?(piece, code, weight)
    }
    
    func flipCamera() {
        scanner.flipCamera()
    }
    
    func playBeep() {
        guard let data = NSDataAsset(name: "cashier-beep")?.data else { return }
        audioPlayer = try? AVAudioPlayer(data: data)
        audioPlayer?.play()
    }
}
