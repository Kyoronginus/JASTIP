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

            VStack{
                HStack{
                    AirlineCard(data: viewModel.displayedAirlineCard)
                    
                    Spacer()
                    
                    VStack{
                        Text("Current Time")
                            .font(.title2.bold())
                        Text("\(viewModel.currentTimeString)")
                            .font(.title2.bold())
                        
                        Button("Next Hour") {
                            viewModel.nextHour()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("SCAN QR") {
                            isShowingScanner = true
                            onOpenCamera()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal,20)
                
                
                
                // CAROUSEL
                
                
                
                
                // LUGGAGES
                

            }

            if let event = viewModel.currentEvent {
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
        .fullScreenCover(isPresented: $isShowingScanner) {
            QRScannerView(session: viewModel) { piece, code, weight in
                lastScannedPiece = piece
                
                if let piece = piece, let weight = weight {
                    viewModel.recordScannedPiece(piece, weight: weight)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isGameOver) {
            ScoringView(viewModel: viewModel) {
                dismiss()
            }
        }
    }
}

#Preview("Light") {
    GameView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    GameView()
        .preferredColorScheme(.dark)
}
