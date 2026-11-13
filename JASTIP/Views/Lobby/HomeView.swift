//
//  HomeView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

// MARK: - 1. Home View
struct HomeView: View {
    var onJoinGame: () -> Void
    var onCreateGame: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("JASTIP")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)

            Spacer()

            VStack(spacing: 14) {
                Button("Create Room") {
                    onCreateGame()
                }
                .buttonStyle(PrimaryButtonStyle(
                    isFullWidth: true,
                ))
                
                Button("Join Room") {
                    onJoinGame()
                }
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: Color("TaxiYellow150"),
                    foregroundColor: Color("NavyBlack"),
                    isFullWidth: true
                ))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

#Preview("Light") {
    StartView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.light)
}
