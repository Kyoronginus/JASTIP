//
//  LobbyPlayerCard.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

struct LobbyPlayerCard: View {
    let name: String
    var index: Int = 0
    var isHost: Bool = false
    var showHostActions: Bool = true
    var onKick: () -> Void = {}
    var onAddHost: () -> Void = {}
    
    // zigzag adjustment
    private let cardHeight: CGFloat = 64
    private let cardSpacing: CGFloat = 12
    private let totalPatternHeight: CGFloat = 368 // (64 * 5) + (12 * 4)
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Image(systemName: "person.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color(.black))
            
            // Nama Pemain
            Text(name)
                .font(.spaceGrotesk(18, .bold))
                .foregroundStyle(Color(.black))
            
            // Penanda Host
            if isHost {
                Image(systemName: "crown.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.black))
            }
            
            Spacer()
            
            if !isHost && showHostActions {
                HStack(spacing: 8) {
                    // Kick Button
                    Button(action: onKick) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .buttonStyle(PrimaryButtonStyle.square(color: Color("FragileRed")))
                    
                    // Crown Button
                    Button(action: onAddHost) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .buttonStyle(PrimaryButtonStyle.square(color: Color("TaxiYellow")))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: cardHeight)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0x2B / 255.0, green: 0x23 / 255.0, blue: 0x1D / 255.0), lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Offset Clipping Background (Master Zigzag Asset)
    private var cardBackground: some View {
        GeometryReader { geo in
            ZStack {
                // Warna dasar kertas kartu
                Color(.playerButton)
                Image("zigzag")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: totalPatternHeight, alignment: .top)
                    .offset(y: -130 + -CGFloat(index) * (cardHeight + cardSpacing))
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        LobbyPlayerCard(name: "quincy", index: 0, isHost: true)
        LobbyPlayerCard(name: "emily", index: 1, isHost: false, showHostActions: true)
        LobbyPlayerCard(name: "david", index: 2, isHost: false, showHostActions: true)
        LobbyPlayerCard(name: "hannah", index: 3, isHost: false, showHostActions: true)
        LobbyPlayerCard(name: "aasas", index: 4, isHost: false, showHostActions: true)
    }
    .padding()

}
