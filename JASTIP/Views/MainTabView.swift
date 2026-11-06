//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    @Bindable var viewModel: GameSessionViewModel
    @State private var activeToast: ToastOptions? = nil
    
    let sample = [
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
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP2-8" }) ?? PieceCatalog.allPieces[2],
            weight: 5,
            scannedBy: "david"
        )
    ]
    
    var body: some View {
        ZStack{
            TabView {
                Tab("Baggages", systemImage: "suitcase.rolling") {
                    GameView(viewModel: viewModel)
                }
                Tab("Order", systemImage: "scroll") {
                    ObjectiveView(viewModel: viewModel)
                }
                Tab("Stats", systemImage: "chart.bar") {
                    StatsView(viewModel: viewModel)
                }
                Tab("Items", systemImage: "robotic.vacuum") {
                    // Placeholder
                    ScannedItemChildView(pieces: sample)
                    
                }
            }
            
            if let event = viewModel.currentEvent, !viewModel.isGameOver {
                EventAlertView(event: event) {
                    withAnimation {
                        viewModel.dismissEvent()
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .toastNotification($viewModel.activeToast)
        .fullScreenCover(isPresented: $viewModel.isGameOver) {
            EndView(players: viewModel.leaderboardPlayers) {
                viewModel.resetToLobby()
            }
        }
    }
}

#Preview("Light") {
    MainTabView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MainTabView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.dark)
}
