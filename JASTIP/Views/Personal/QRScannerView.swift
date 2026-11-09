//
//  QRScannerView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss

    let isSuitcase: Bool
    @State private var viewModel: QRScannerViewModel
    
    init(session: GameSessionViewModel, isSuitcase: Bool = true, onScanned: ((PieceModel?, String, Int?, Bool) -> Void)? = nil) {
        self.isSuitcase = isSuitcase
        _viewModel = State(initialValue: QRScannerViewModel(session: session, isSuitcase: isSuitcase, onScanned: onScanned))
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
                    VStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow, lineWidth: 3)
                            .frame(width: 180, height: 180)
                            .background(Color.black.opacity(0.15))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.scanner.refocusCenter()
                            }
                        
                        Text("Arahkan ke QR... (Tap kotak untuk fokus ulang)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                if !viewModel.isShowingPopup {
                    cameraAdjustmentControls
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
            }
            
            // 3. Popup Penolakan (Jika barang tidak muat di koper target)
            if let piece = viewModel.detectedPiece, let rejection = viewModel.rejectionMessage {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 14) {
                    Image(piece.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(12)
                    
                    Text("TIDAK MUAT!")
                        .font(.spaceGrotesk(24, .bold))
                        .foregroundStyle(Color("FragileRed"))
                    
                    Text(rejection)
                        .font(.spaceGrotesk(14, .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    
                    Button("Scan Barang Lain") {
                        viewModel.resetScan()
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                    .padding(.horizontal, 16)
                    
                    Button("Kembali") {
                        dismiss()
                    }
                    .font(.spaceGrotesk(14, .bold))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: 320)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
            }
            
            // 4. Popup Konfirmasi (Tampil di tengah saat QR terdeteksi)
            if let piece = viewModel.detectedPiece, let _ = viewModel.confirmedWeight {
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
                            
                            Text(isSuitcase ? "Adding to Suitcase" : "Adding to Carry-On")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)

                            Button("Continue") {
                                viewModel.confirmAndContinue(isSuitcase: isSuitcase)
                                dismiss()
                            }
                            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
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
            viewModel.targetIsSuitcase = isSuitcase
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
    
    // MARK: - Zoom & Focus Adjustment Controls
    private var cameraAdjustmentControls: some View {
        VStack(spacing: 10) {
            // 1. Zoom Presets & Slider
            HStack(spacing: 10) {
                Image(systemName: "plus.magnifyingglass")
                    .foregroundStyle(Color("TaxiYellow"))
                    .frame(width: 22)
                
                Text(String(format: "%.1fx", viewModel.scanner.zoomMultiplier))
                    .font(.spaceGrotesk(13, .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, alignment: .leading)
                
                Slider(
                    value: Binding(
                        get: { viewModel.scanner.zoomMultiplier },
                        set: { viewModel.scanner.setZoom(multiplier: $0) }
                    ),
                    in: 1.0...3.0,
                    step: 0.1
                )
                .tint(Color("TaxiYellow"))
            }
            
            // 2. Focus Mode & Manual Lens Position Slider
            if viewModel.scanner.supportsManualFocus {
                HStack(spacing: 10) {
                    Button {
                        if viewModel.scanner.isManualFocus {
                            viewModel.scanner.setAutoFocus()
                        } else {
                            viewModel.scanner.setManualFocus(position: viewModel.scanner.lensPosition)
                        }
                    } label: {
                        Text(viewModel.scanner.isManualFocus ? "MANUAL" : "AUTO")
                            .font(.spaceGrotesk(11, .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(viewModel.scanner.isManualFocus ? Color("TaxiYellow") : Color.white.opacity(0.2))
                            .foregroundStyle(viewModel.scanner.isManualFocus ? .black : .white)
                            .clipShape(Capsule())
                    }
                    
                    Image(systemName: "camera.macro")
                        .font(.caption)
                        .foregroundStyle(Color("TaxiYellow"))
                    
                    Slider(
                        value: Binding(
                            get: { viewModel.scanner.lensPosition },
                            set: { viewModel.scanner.setManualFocus(position: $0) }
                        ),
                        in: 0.0...1.0
                    )
                    .tint(Color("TaxiYellow"))
                    
                    Image(systemName: "mountain.2.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
