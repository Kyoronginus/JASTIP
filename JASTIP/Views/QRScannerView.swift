//
//  QRScannerView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: QRScannerViewModel
    
    init(session: GameSessionViewModel, onScanned: ((PieceModel?, String, Int?) -> Void)? = nil) {
        _viewModel = State(initialValue: QRScannerViewModel(session: session, onScanned: onScanned))
    }
    
    var body: some View {
        ZStack {
            // 1. Live Camera Preview
            CameraPreviewView(session: viewModel.scanner.session)
                .ignoresSafeArea()
            
            // 2. Viewfinder Target & Header Bar (Hanya saat mencari QR)
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 80, height: 32)
                    
                    Button(action: {
                        viewModel.flipCamera()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                
                Spacer()
                
                if !viewModel.isShowingPopup {
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
            if let code = viewModel.scannedCode {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Text(viewModel.headerTitle)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(code)
                        .font(.title3.bold())
                    
                    if let piece = viewModel.detectedPiece {
                        HStack(spacing: 12) {
                            Text(piece.shape.rawValue)
                                .font(.subheadline.bold())

                            Text("\(piece.gridCount) base kg")
                                .font(.subheadline)
                            
                            if piece.isAnomaly {
                                Text("ANOMALI")
                                    .font(.caption2.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    // Tombol & Teks Pilihan
                    if let weight = viewModel.confirmedWeight {
                        VStack(spacing: 12) {
                            if viewModel.session.isZeroWeightHour {
                                VStack {
                                    Text("Bobot: 0 kg")
                                        .font(.headline.bold())
                                        .foregroundColor(.green)
                                    Text("Free Items Event! (Asli: \(weight) kg)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.orange)
                                }
                            } else {
                                Text("Bobot: \(weight) kg")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            
                            Text("Where do u want to put it in?")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                Button("Suitcase") {
                                    viewModel.selectDestination(isSuitcase: true)
                                    dismiss()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                                
                                Button("Carry-On") {
                                    viewModel.selectDestination(isSuitcase: false)
                                    dismiss()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Button("Scan Ulang") {
                                viewModel.resetScan()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Konfirmasi") {
                                viewModel.confirmWeight()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 320)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

#Preview("Light") {
    QRScannerView(session: GameSessionViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    QRScannerView(session: GameSessionViewModel())
        .preferredColorScheme(.dark)
}
