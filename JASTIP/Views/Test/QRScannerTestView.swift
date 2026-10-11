//
//  QRScannerTestView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import SwiftUI

struct QRScannerTestView: View {
    @State private var scanner = QRScannerManager()
    @State private var lastScannedCode: String = "Belum ada QR terdeteksi"
    @State private var mockWeight: Int? = nil
    
    var body: some View {
        ZStack {
            // 1. Live Camra Preview
            CameraPreviewView(session: scanner.session)
                .ignoresSafeArea()
            
            // 2. Overlay Kotak Target Scanner
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: 220, height: 220)
                    .background(Color.black.opacity(0.1))
                Spacer()
            }
            
            // 3. Card Hasil Scan di Bawah
            VStack {
                Spacer()
                VStack(spacing: 8) {
                    Text("HASIL SCAN")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text(lastScannedCode)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let weight = mockWeight {
                        Text("Simulasi Bobot: \(weight) kg")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    Button("Scan Ulang") {
                        lastScannedCode = "Arahkan ke QR..."
                        mockWeight = nil
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
        .onAppear {
            scanner.startScanning()
            scanner.onCodeDetected = { code in
                self.lastScannedCode = code
                // Simulasi acak n ± 2 kg untuk test
                self.mockWeight = Int.random(in: 2...6)
            }
        }
        .onDisappear {
            scanner.stopScanning()
        }
    }
}

#Preview {
    QRScannerTestView()
}
