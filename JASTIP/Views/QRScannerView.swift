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
    
    var onScanned: ((PieceModel?, String, Int?) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // 1. Live Camera Preview
            CameraPreviewView(session: scanner.session)
                .ignoresSafeArea()
            
            // 2. Viewfinder Target Overlay
            VStack {
                // Header Bar dengan tombol tutup
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                            Text("Tutup")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Text("Pindai QR Piece")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Spacer penyeimbang tombol kiri
                    Color.clear
                        .frame(width: 80, height: 36)
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Kotak target viewfinder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(scannedCode != nil ? Color.green : Color.yellow, lineWidth: 3)
                        .frame(width: 200, height: 200)
                        .background(Color.black.opacity(0.15))
                    
                    if scannedCode == nil {
                        Text("Arahkan ke QR")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // 3. Bottom Card Hasil Scan
                VStack(spacing: 12) {
                    if let code = scannedCode {
                        Text(confirmedWeight != nil ? "PIECE TERKONFIRMASI" : "QR TERDETEKSI")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(code)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let piece = detectedPiece {
                            HStack(spacing: 12) {
                                Label("\(piece.gridCount) Grid", systemImage: "square.grid.2x2")
                                    .font(.subheadline)
                                
                                if piece.isAnomaly {
                                    Text("ANOMALI")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        
                        // Bobot hanya muncul setelah user menekan tombol Konfirmasi
                        if let weight = confirmedWeight {
                            HStack(spacing: 6) {
                                Image(systemName: "scalemass.fill")
                                Text("Bobot: \(weight) kg")
                            }
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 14)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Capsule())
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        HStack(spacing: 12) {
                            Button("Scan Ulang") {
                                withAnimation {
                                    resetScan()
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            if confirmedWeight == nil {
                                Button("Konfirmasi") {
                                    withAnimation {
                                        // Generate bobot saat user menekan konfirmasi
                                        confirmedWeight = Int.random(in: 2...6)
                                    }
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
                    } else {
                        Text("Mencari QR code piece...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: 420)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.bottom, 20)
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
    QRScannerView()
}
