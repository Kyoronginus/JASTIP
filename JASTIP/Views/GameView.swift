//
//  GameView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 21/10/26.
//


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
    @State private var nfcManager = NFCReaderManager()
    var onOpenCamera: () -> Void
    
    @State private var isShowingScanner = false
    @State private var isShowingLeaderboard = false
    @State private var isShowingRevealedWeights = false
    @State private var lastScannedPiece: PieceModel? = nil
    
    @State private var nfcDetectedPiece: PieceModel? = nil
    @State private var nfcConfirmedWeight: Int? = nil
    @State private var isShowingNFCPopup = false
    @State private var isShowingHowTo = false
    
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
                        HStack() {
                            Spacer()
                            Button("", systemImage: "questionmark.circle") {
                                isShowingHowTo = true
                            }
                            .font(.title3)
                            
                            Button("", systemImage: "person.2.fill") {
                                viewModel.broadcastMyStatus()
                                isShowingLeaderboard = true
                            }
                            .font(.title3)
                        }
                        .sheet(isPresented: $isShowingHowTo) {
                            HowToSheets()
                                .presentationDetents([.medium, .large])
                        }
                        .sheet(isPresented: $isShowingLeaderboard) {
                            LeaderboardCard(
                                isModal: true,
                                players: viewModel.leaderboardPlayers,
                                onBoard: {
                                    viewModel.boardFlight()
                                }
                            )
                            .presentationDetents([.medium, .large])
                        }
                        
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
                        
                        Button("TAP NFC") {
                            nfcManager.startScan()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.currentEvent != nil || viewModel.isBoarded)
                        .onAppear {
                            nfcManager.onTagScanned = { tagContent in
                                if let piece = PieceCatalog.findPiece(by: tagContent) {
                                    let weight = viewModel.weight(for: piece.id)
                                    self.nfcDetectedPiece = piece
                                    self.nfcConfirmedWeight = weight
                                    withAnimation {
                                        self.isShowingNFCPopup = true
                                    }
                                } else {
                                    print("❌ Piece tidak ditemukan di katalog untuk ID: \(tagContent)")
                                }
                            }
                        }
                        
                        Button("SCAN QR") {
                            isShowingScanner = true
                            onOpenCamera()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.currentEvent != nil || viewModel.isBoarded)
                        
                        if viewModel.isBoarded {
                            Label("Boarded", systemImage: "checkmark.circle.fill")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }
                }
                
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
            
            if isShowingNFCPopup, let piece = nfcDetectedPiece, let weight = nfcConfirmedWeight {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isShowingNFCPopup = false }
                    }
                
                VStack(spacing: 16) {
                    Text("NFC ITEM DETECTED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(piece.shape.rawValue)
                        .font(.title2.bold())
                    
                    // Cek jika sedang ada Event Free Items (0 kg)
                    if viewModel.isZeroWeightHour {
                        VStack(spacing: 2) {
                            Text("Bobot: 0 kg")
                                .font(.title3.bold())
                                .foregroundColor(.green)
                            Text("Free Items Event! (Asli: \(weight) kg)")
                                .font(.caption2.bold())
                                .foregroundColor(.orange)
                        }
                    } else {
                        Text("Bobot: \(weight) kg")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                    }
                    
                    Text("Where do you want to put it in?")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 14) {
                        Button("Suitcase") {
                            viewModel.recordItemPlacement(piece: piece, weight: weight, isSuitcase: true)
                            withAnimation { isShowingNFCPopup = false }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        Button("Carry-On") {
                            viewModel.recordItemPlacement(piece: piece, weight: weight, isSuitcase: false)
                            withAnimation { isShowingNFCPopup = false }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                }
                .padding(20)
                .frame(maxWidth: 320)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentEvent != nil || isShowingRevealedWeights || isShowingNFCPopup)
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
            EndView(players: viewModel.leaderboardPlayers) {
                viewModel.resetToLobby()
            }
        }
    }
}

#Preview("Light") {
    let mockViewModel = GameSessionViewModel()
    mockViewModel.isBoarded = true
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
