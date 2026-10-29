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
            CameraPreviewView(
                session: viewModel.scanner.session,
                cameraPosition: viewModel.scanner.currentPosition
            )
            .ignoresSafeArea()
            
            // 2. Viewfinder Target & Header Bar (Hanya saat mencari QR)
            VStack {
                // MARK: - Header Bar
                HStack {
                    // Back Button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: .black,
                        borderColor: Color("TaxiYellow"),
                        foregroundColor: Color("TaxiYellow"),
                        cornerRadius: 14,
                        paddingVertical: 14,
                        paddingHorizontal: 15
                    ))
                    .padding(.trailing, 10)
                    
                    // Title Banner
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.black)
                        
                        // Watermark Asterisk
                        Image("AsteriskYellow")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.white.opacity(0.12))
                            .scaledToFit()
                            .frame(width: 155, height: 155)
                            .offset(x: 52, y: 27)
                        
                        HStack {
                            Text("Scan QR")
                                .font(.spaceGrotesk(18, .bold))
                                .foregroundStyle(Color("TaxiYellow"))
                            Spacer()
                            
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
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
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
            if let piece = viewModel.detectedPiece, let weight = viewModel.confirmedWeight {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    
                    Image(piece.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(20)
                    
                    // Tombol & Teks Pilihan
                    if let weight = viewModel.confirmedWeight {
                        VStack(spacing: 12) {
                            if viewModel.session.isZeroWeightHour {
                                VStack {
                                    Text("Bobot: 0 kg")
                                        .font(.spaceGrotesk(32, .bold))
                                        .foregroundColor(.primary)
                                    Text("Free Items Event! (Asli: \(weight) kg)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.orange)
                                }
                            } else {
                                Text("\(weight) KG")
                                    .font(.spaceGrotesk(32, .bold))
                                    .foregroundColor(.primary)
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
