//
//  ScoringView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 12/10/26.
//

import SwiftUI

struct EndView: View {
    var players: [PlayerStatusModel] = []
    var onFinishGame: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 20) {
            // Tampilkan leaderboard status akhir (non-modal)
            LeaderboardCard(isModal: false, players: players)
            
            Button("SELESAI MAIN") {
                onFinishGame()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}
#Preview("Light") {
    EndView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    EndView()
        .preferredColorScheme(.dark)
}
