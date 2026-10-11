//
//  QRScannerViewModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI

@Observable
class QRScannerViewModel {
    let scanner = QRScannerManager()
    
    var scannedCode: String? = nil
    var detectedPiece: PieceModel? = nil
    var confirmedWeight: Int? = nil
    
    var session: GameSessionViewModel
    var onScanned: ((PieceModel?, String, Int?) -> Void)? = nil
    
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
}
