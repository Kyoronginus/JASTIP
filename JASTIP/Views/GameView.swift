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
    
    private var suitWeight: Int {
        viewModel.suitWeight
    }
    
    private var carryWeight: Int {
        viewModel.carryWeight
    }
    
    private var maxSuitCapacity: Int {
        viewModel.displayedAirlineCard.maxCapacityKg
    }
    
    private var maxCarryCapacity: Int {
        viewModel.displayedAirlineCard.maxCarryOnKg
    }
    
    // Progress otomatis dihitung dari (berat / kapasitas)
    private var suitProgress: Double {
        guard maxSuitCapacity > 0 else { return 0 }
        return Double(suitWeight) / Double(maxSuitCapacity)
    }
    
    private var carryProgress: Double {
        guard maxCarryCapacity > 0 else { return 0 }
        return Double(carryWeight) / Double(maxCarryCapacity)
    }
    
    @State private var lastScannedWeight: Int? = nil
    
    init(
        viewModel: GameSessionViewModel? = nil,
        airlineCard: AirlineCardModel = AirlineCardCatalog.dummy,
        onOpenCamera: @escaping () -> Void = {},
        lockHostToggle: Bool
    ) {
        let initViewModel = viewModel ?? GameSessionViewModel(airlineCard: airlineCard)
        _viewModel = State(initialValue: initViewModel)
        self.onOpenCamera = onOpenCamera
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack{
                // Top Part
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
                        .disabled(viewModel.currentEvent != nil)
                        .disabled(!viewModel.lockHostToggle)
                        
                        Button("SCAN QR") {
                            isShowingScanner = true
                            onOpenCamera()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.currentEvent != nil)
                    }
                }
                // Middle Part
                
                
                // CAROUSEL
                Text("Revealed Pieces")
                    .padding(8)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                GameCarouselView(pieces: viewModel.revealedPieces)
                    .padding(.vertical,8)

                
                
                // Bottom Part
                Spacer()
                VStack(spacing: 20) {
                    HStack(alignment: .bottom, spacing: 24) {
                        ProgressBar(progress: suitProgress, x: 180, y: 220)
                            .overlay {
                                VStack(spacing: 8) {
                                    Text("Suitcase")
                                        .font(.headline.bold())
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    // Teks Berat yang Sync
                                    Text("\(suitWeight) / \(maxSuitCapacity) kg")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(uiColor: .systemBackground).opacity(0.85))
                                        .clipShape(Capsule())
                                }
                                .padding(.vertical, 16)
                            }
                        
                        ProgressBar(progress: carryProgress, x: 140, y: 140)
                            .overlay {
                                VStack(spacing: 8) {
                                    Text("Carry-on")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(carryWeight) / \(maxCarryCapacity) kg")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(uiColor: .systemBackground).opacity(0.85))
                                        .clipShape(Capsule())
                                }
                                .padding(.vertical, 14)
                            }
                    }
                }
            }
            .padding(.horizontal,20)
            
            if let event = viewModel.currentEvent, !viewModel.isGameOver {
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
                if let weight = weight {
                    lastScannedWeight = weight
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isGameOver) {
            EndView {
                viewModel.resetToLobby()
            }
        }
    }
}

#Preview("Light") {
    let mockViewModel = GameSessionViewModel()
    mockViewModel.revealedPieces = [
        RevealedPiece(piece: PieceCatalog.allPieces[0], weight: 3),
        RevealedPiece(piece: PieceCatalog.allPieces[1], weight: 4),
        RevealedPiece(piece: PieceCatalog.allPieces[0], weight: 3),
        RevealedPiece(piece: PieceCatalog.allPieces[1], weight: 4),
        RevealedPiece(piece: PieceCatalog.allPieces[0], weight: 3),
        RevealedPiece(piece: PieceCatalog.allPieces[1], weight: 4),
        RevealedPiece(piece: PieceCatalog.allPieces[1], weight: 4)
    ]
    
    return GameView(viewModel: mockViewModel, lockHostToggle: false)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let mockViewModel = GameSessionViewModel()
    mockViewModel.revealedPieces = [
    ]
    
    return GameView(viewModel: mockViewModel, lockHostToggle: false)
        .preferredColorScheme(.dark)
}
