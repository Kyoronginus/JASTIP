//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    var viewModel: GameSessionViewModel
    
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
        TabView {
            Tab("Baggages", systemImage: "suitcase.rolling") {
                GameView(viewModel: viewModel)
            }
            Tab("Order", systemImage: "scroll") {
                ObjectiveView()
            }
            Tab("Stats", systemImage: "chart.bar") {
                StatsView()
            }
            Tab("Items", systemImage: "robotic.vacuum") {
                // Placeholder
                ScannedItemChildView(pieces: sample)

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
