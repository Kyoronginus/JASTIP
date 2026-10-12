//
//  GameView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GameSessionViewModel
    var onOpenCamera: () -> Void

    @State private var isShowingScanner = false
    @State private var isShowingRevealedWeights = false
    @State private var lastScannedPiece: PieceModel? = nil

    init(
        airlineCard: AirlineCardModel = AirlineCardCatalog.dummy,
        onOpenCamera: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: GameSessionViewModel(airlineCard: airlineCard))
        self.onOpenCamera = onOpenCamera
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            HStack {
                AirlineCard(data: viewModel.displayedAirlineCard)

                Spacer()

                VStack(spacing: 12) {
                    Spacer()

                    Text("TIME: \(viewModel.currentTimeString)")
                        .font(.title2.bold())

                    Spacer()
                    
                    Button("SCAN QR") {
                        isShowingScanner = true
                        onOpenCamera()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Next Hour") {
                        viewModel.nextHour()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("DAFTAR BOBOT") {
                        withAnimation {
                            isShowingRevealedWeights = true
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    
                    // TODO: Temporary Button - Hapus sebelum rilis
                    Button("TEST EVENT") {
                        viewModel.currentEvent = RandomEventModel(
                            title: "Toko Buku Tutup!",
                            message: "Toko Buku sedang istirahat. Tidak ada item yang bisa diambil di jam ini."
                        )
                    }
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    
                    Button("OPEN SHAPES") {
                        isShowingRevealedSheet = true
                    }
                    .font(.caption2.bold())
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Spacer()

                    Text("TIME: \(viewModel.currentTimeString)")
                        .font(.title2.bold())
                        .rotationEffect(.degrees(180))

                    Spacer()
                }

                Spacer()

                AirlineCard(data: viewModel.displayedAirlineCard)
                    .rotationEffect(.degrees(180))
            }
            .padding(.horizontal, 24)

            if let event = viewModel.currentEvent {
                // Backdrop redup
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.dismissEvent()
                    }

                EventAlertView(event: event) {
                    withAnimation {
                        viewModel.dismissEvent()
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            if isShowingRevealedWeights {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowingRevealedWeights = false
                        }
                    }
                
                RevealedPiecesListView(pieces: viewModel.revealedPieces) {
                    withAnimation {
                        isShowingRevealedWeights = false
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentEvent != nil || isShowingRevealedWeights)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingRevealedSheet) {
               RevealedSheetsView()
                   .presentationDetents([.medium, .large])
           }
        .fullScreenCover(isPresented: $isShowingScanner) {
            QRScannerView(session: viewModel) { piece, code, weight in
                lastScannedPiece = piece
                
                if let piece = piece, let weight = weight {
                    viewModel.recordScannedPiece(piece, weight: weight)
                }
            }
        }
        .onChange(of: viewModel.isGameOver) { _, isOver in
            if isOver {
                dismiss()
            }
        }
    }
}

#Preview("Light", traits: .landscapeRight) {
    GameView()
        .preferredColorScheme(.light)
}

#Preview("Dark", traits: .landscapeRight) {
    GameView()
        .preferredColorScheme(.dark)
}
