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
    let allowsEitherLuggage: Bool
    var onDismissOverride: (() -> Void)? = nil
    @State private var viewModel: QRScannerViewModel
    
    init(
        session: GameSessionViewModel,
        isSuitcase: Bool = true,
        allowsEitherLuggage: Bool = false,
        onDismissOverride: (() -> Void)? = nil,
        onScanned: ((PieceModel?, String, Int?, Bool) -> Void)? = nil
    ) {
        self.isSuitcase = isSuitcase
        self.allowsEitherLuggage = allowsEitherLuggage
        self.onDismissOverride = onDismissOverride
        _viewModel = State(
            initialValue: QRScannerViewModel(
                session: session,
                isSuitcase: isSuitcase,
                allowsEitherLuggage: allowsEitherLuggage,
                onScanned: onScanned
            )
        )
    }
    
    var body: some View {
        ZStack {
            // 1. Live Camera Preview
            CameraPreviewView(
                session: viewModel.scanner.session,
                cameraPosition: viewModel.scanner.currentPosition
            )
            .blur(radius: viewModel.scanner.isSwitchingCamera ? 6 : 0)
            .animation(.easeInOut(duration: 0.15), value: viewModel.scanner.isSwitchingCamera)
            .ignoresSafeArea()
            
            // 2. Viewfinder Target & Header Bar (Hanya saat mencari QR)
            VStack {
                // MARK: - Header Bar
                HStack {
                    // Back Button
                    Button {
                        closeScanner()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .buttonStyle(PrimaryButtonStyle(
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
                                    .foregroundColor(Color("TaxiYellow"))
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
                            .stroke(viewModel.closedStoreWarning == nil ? Color.yellow : Color("FragileRed"), lineWidth: 3)
                            .frame(width: 180, height: 180)
                            .background(Color.black.opacity(0.15))

                        if let warning = viewModel.closedStoreWarning {
                            Label(warning, systemImage: "exclamationmark.triangle.fill")
                                .font(.spaceGrotesk(14, .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color("FragileRed"))
                                .clipShape(Capsule())
                                .transition(.opacity)
                        } else {
                            Text("Point camera at QR...")
                                .font(.subheadline)
                                .foregroundColor(.white)

//                            if let closedStores = viewModel.session.closedStoresLabel {
//                                Label("Closed today: \(closedStores)", systemImage: "storefront")
//                                    .font(.spaceGrotesk(12, .semibold))
//                                    .foregroundStyle(.white.opacity(0.9))
//                                    .padding(.horizontal, 12)
//                                    .padding(.vertical, 6)
//                                    .background(Color.black.opacity(0.6))
//                                    .clipShape(Capsule())
//                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.closedStoreWarning)
                }
                
                Spacer()
            }
            
            // 3. Popup Konfirmasi (Tampil di tengah saat QR terdeteksi)
            if let piece = viewModel.detectedPiece, viewModel.scannedCode != nil {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image(piece.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(20)
                    
                    if !viewModel.hasConfirmedDetectedItem {
                        VStack(spacing: 12) {
                            Text("Is this the item that you want to scan?")
                                .font(.spaceGrotesk(20, .bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)

                            HStack(spacing: 12) {
                                Button("No") {
                                    viewModel.resetScan()
                                }
                                .buttonStyle(PrimaryButtonStyle())

                                Button("Yes") {
                                    viewModel.confirmDetectedItem()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                    } else if let weight = viewModel.confirmedWeight {
                        VStack(spacing: 12) {
                            if viewModel.session.isZeroWeightHour {
                                VStack {
                                    Text("Weight: 0 kg")
                                        .font(.spaceGrotesk(32, .bold))
                                        .foregroundColor(.primary)
                                    Text("Free Items Event! (Original: \(weight) kg)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.orange)
                                }
                            } else {
                                Text("\(weight) KG")
                                    .font(.spaceGrotesk(32, .bold))
                                    .foregroundColor(.primary)
                            }

                            Text(allowsEitherLuggage ? "Adding to Staging Area" : (isSuitcase ? "Adding to Suitcase" : "Adding to Carry-On"))
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)

                            Button("Continue") {
                                viewModel.confirmAndContinue(isSuitcase: isSuitcase)
                                closeScanner()
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
            viewModel.allowsEitherLuggage = allowsEitherLuggage
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }

    private func closeScanner() {
        if let onDismissOverride {
            onDismissOverride()
        } else {
            dismiss()
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
