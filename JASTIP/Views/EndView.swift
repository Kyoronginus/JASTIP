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
            // MARK: - Header Bar
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
                    Text("Leaderboard")
                        .font(.spaceGrotesk(18, .bold))
                        .foregroundStyle(Color("TaxiYellow"))
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            LeaderboardPlayerCardList(players: players)
            
            Button("FINISHED PLAYING") {
                onFinishGame()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .appBackground()
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
