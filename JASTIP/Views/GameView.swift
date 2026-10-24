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
    @State private var isShowingScannedItems = false
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
        onOpenCamera: @escaping () -> Void = {}
    ) {
        let initViewModel = viewModel ?? GameSessionViewModel(airlineCard: airlineCard)
        _viewModel = State(initialValue: initViewModel)
        self.onOpenCamera = onOpenCamera
    }
    
    var body: some View {
        ZStack {
            VStack{
                // Top Part
                VStack {
                    BoardingCard(
                        departureTime: viewModel.displayedAirlineCard.departureTime,
                        currentTimeString: viewModel.currentTimeString,
                        isHost: viewModel.lobbyService.lobby?.isHost == true,
                        isNextHourDisabled: viewModel.currentEvent != nil || viewModel.lobbyService.lobby?.isHost != true,
                        onNextHour: {
                            viewModel.nextHour()
                        }
                    )
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer() // Mendorong tombol ke sisi kanan (trailing)
                        
                        Button {
                            isShowingScanner = true
                            onOpenCamera()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(Color("TaxiYellow"))
                            Text("Scan Item")
                        }
                        .buttonStyle(PrimaryButtonStyle(
                            backgroundColor: Color("NavyBlack"),
                            borderColor: Color("TaxiYellow"),
                            foregroundColor: .white,
                            cornerRadius: 15,
                            paddingVertical: 12,
                            paddingHorizontal: 20
                        ))
                        .disabled(viewModel.currentEvent != nil || viewModel.isBoarded)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
                
                // Middle part
                // CAROUSEL
                ScannedItemView(pieces: viewModel.revealedPieces) {
                    isShowingScannedItems = true
                }
                .fullScreenCover(isPresented: $isShowingScannedItems) {
                    ScannedItemChildView(pieces: viewModel.revealedPieces)
                }
                .padding(.vertical,8)
                
                
                
                // Bottom Part
                Spacer()
                HStack(alignment: .bottom, spacing: 12) {
                    ProgressBar(
                        luggage: .suitcase,
                        weight: suitWeight,
                        maxWeight: maxSuitCapacity,
                        width: 155
                    )
                    VStack(spacing: 50){
                        Button("Leaderboard") {
                            viewModel.broadcastMyStatus()
                            isShowingLeaderboard = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        ProgressBar(
                            luggage: .carryOn,
                            weight: carryWeight,
                            maxWeight: maxCarryCapacity,
                            width: 120
                        )
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
                    
                }
            }
            .padding(.horizontal,20)
            
            if let event = viewModel.currentEvent, !viewModel.isGameOver {
                EventAlertView(event: event) {
                    withAnimation {
                        viewModel.dismissEvent()
                    }
                }
                .transition(.opacity)
                .zIndex(100)
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
        .appBackground()
    }
}

#Preview("Host View") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    mockViewModel.revealedPieces = [
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP1-5" }) ?? PieceCatalog.allPieces[0],
            weight: 4,
            scannedBy: "quincy"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-6" }) ?? PieceCatalog.allPieces[1],
            weight: 4,
            scannedBy: "emily"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-9" }) ?? PieceCatalog.allPieces[2],
            weight: 5,
            scannedBy: "david"
        )
    ]
    mockViewModel.suitWeight = 12
    mockViewModel.carryWeight = 4
    return GameView(viewModel: mockViewModel)
}

#Preview("Non-Host View") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    mockViewModel.revealedPieces = [
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP1-5" }) ?? PieceCatalog.allPieces[0],
            weight: 4,
            scannedBy: "quincy"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-6" }) ?? PieceCatalog.allPieces[1],
            weight: 4,
            scannedBy: "emily"
        )
    ]
    mockViewModel.suitWeight = 8
    mockViewModel.carryWeight = 3
    return GameView(viewModel: mockViewModel)
}
