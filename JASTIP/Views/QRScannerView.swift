//
//  QRScannerView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var scanner = QRScannerManager()
    @State private var scannedCode: String? = nil
    @State private var detectedPiece: PieceModel? = nil
    @State private var confirmedWeight: Int? = nil
    
    var session: GameSessionViewModel
    
    var onScanned: ((PieceModel?, String, Int?) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // 1. Live Camera Preview
            CameraPreviewView(session: scanner.session)
                .ignoresSafeArea()
            
            // 2. Viewfinder Target & Header Bar (Hanya saat mencari QR)
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 80, height: 32)
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                
                Spacer()
                
                if scannedCode == nil {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow, lineWidth: 3)
                            .frame(width: 180, height: 180)
                            .background(Color.black.opacity(0.15))
                        
                        Text("Arahkan ke QR...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            
            // 3. Popup Konfirmasi (Tampil di tengah saat QR terdeteksi)
            if let code = scannedCode {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Text(confirmedWeight != nil ? "PIECE TERKONFIRMASI" : "QR TERDETEKSI")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(code)
                        .font(.title3.bold())
                    
                    if let piece = detectedPiece {
                        HStack(spacing: 12) {
                            Text(piece.shape.rawValue)
                                .font(.subheadline.bold())

                            Text("\(piece.gridCount) Grid")
                                .font(.subheadline)
                            
                            if piece.isAnomaly {
                                Text("ANOMALI")
                                    .font(.caption2.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    if let weight = confirmedWeight {
                        Text("Bobot: \(weight) kg")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 12) {
                        Button("Scan Ulang") {
                            resetScan()
                        }
                        .buttonStyle(.bordered)
                        
                        if confirmedWeight == nil {
                            Button("Konfirmasi") {
                                confirmedWeight = session.weight(for: code)
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Selesai") {
                                onScanned?(detectedPiece, code, confirmedWeight)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: 320)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
            }
        }
        .onAppear {
            scanner.startScanning()
            scanner.onCodeDetected = { code in
                handleDetectedCode(code)
            }
        }
        .onDisappear {
            scanner.stopScanning()
        }
    }
    
    private func handleDetectedCode(_ code: String) {
        guard scannedCode == nil else { return }
        self.scannedCode = code
        self.detectedPiece = PieceCatalog.findPiece(by: code)
        self.confirmedWeight = nil
    }
    
    private func resetScan() {
        self.scannedCode = nil
        self.detectedPiece = nil
        self.confirmedWeight = nil
        scanner.startScanning()
    }
}

#Preview("Landscape", traits: .landscapeRight) {
    QRScannerView(session: GameSessionViewModel())
}
