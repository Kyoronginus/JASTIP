//
//  LeaderboardCard.swift
//  JASTIP
//
//  Created by Feivel Qutby on 20/10/26.
//

import SwiftUI

// MARK: - Color Palette per Urutan Player
enum PlayerCardColor {
    case red, yellow, orange, blue, lightBlue
    
    var background: Color {
        switch self {
        case .red: return Color("FragileRed")
        case .yellow: return Color("TaxiYellow")
        case .orange: return Color("TransitTangerine")
        case .blue: return Color("PassportBlue")
        case .lightBlue: return Color("PassportBlue150")
        }
    }
    
    var foreground: Color {
        switch self {
        case .red: return Color("FragileRed150")
        case .yellow: return Color("TaxiYellow850")
        case .orange: return Color("TransitTangerine150")
        case .blue: return Color("PassportBlue150")
        case .lightBlue: return Color("PassportBlue")
        }
    }
    
    var border: Color {
        switch self {
        case .red: return Color("FragileRed150")
        case .yellow: return Color("TaxiYellow850")
        case .orange: return Color("TransitTangerine150")
        case .blue: return Color("PassportBlue150")
        case .lightBlue: return Color("PassportBlue")
        }
    }
    
    static func forIndex(_ index: Int) -> PlayerCardColor {
        let colors: [PlayerCardColor] = [.red, .yellow, .orange, .blue, .lightBlue]
        return colors[index % colors.count]
    }
}

// MARK: - Main Leaderboard Card / View
struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    var isModal: Bool = false
    var players: [PlayerStatusModel] = []
    var onBoard: (() -> Void)? = nil
    
    private var currentPlayer: PlayerStatusModel? {
        players.first(where: { $0.isCurrentDevice })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header Bar
                HStack {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                }
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: .black,
                    borderColor: Color("TaxiYellow"),
                    foregroundColor: Color("TaxiYellow"),
                    cornerRadius: 14,
                    paddingVertical: 14,
                    paddingHorizontal: 15
                ))
                .padding(.trailing, 10)
                
                // Title Banner
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                LeaderboardPlayerCardList(players: players)

                if let currentPlayer {
                    LeaderboardProgressFooter(
                        suitcaseWeight: currentPlayer.suitcaseWeight,
                        suitcaseMax: currentPlayer.suitcaseMax,
                        carryOnWeight: currentPlayer.carryOnWeight,
                        carryOnMax: currentPlayer.carryOnMax
                    )
                }
            }
            .appBackground()
        }
    }
}

struct LeaderboardPlayerCardList: View {
    let players: [PlayerStatusModel]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                    PlayerStatusCard(player: player, index: index)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct LeaderboardProgressFooter: View {
    let suitcaseWeight: Int
    let suitcaseMax: Int
    let carryOnWeight: Int
    let carryOnMax: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 32) {
            ProgressBar(
                luggage: .suitcase,
                weight: suitcaseWeight,
                maxWeight: suitcaseMax,
                width: 155
            )

            ProgressBar(
                luggage: .carryOn,
                weight: carryOnWeight,
                maxWeight: carryOnMax,
                width: 120
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

// MARK: - Color-Coded Player Status Card
struct PlayerStatusCard: View {
    let player: PlayerStatusModel
    var index: Int = 0
    
    private var colorScheme: PlayerCardColor {
        PlayerCardColor.forIndex(index)
    }
    
    var body: some View {
        ZStack{
            HStack(spacing: 8) {
                // 1. Kolom Nama Pemain
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                    
                    Text(player.name)
                        .font(.spaceGrotesk(16, .bold))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 5) {
                    Image(systemName: "suitcase.rolling.fill")
                        .font(.system(size: 20))
                        .opacity(0.85)
                    
                    weightFraction(current: player.suitcaseWeight, max: player.suitcaseMax)
                }
                .frame(minWidth: 80, alignment: .center)
                
                HStack(spacing: 5) {
                    Image(systemName: "suitcase.fill")
                        .font(.system(size: 20))
                        .opacity(0.85)
                    
                    weightFraction(current: player.carryOnWeight, max: player.carryOnMax)
                }
                .frame(minWidth: 72, alignment: .trailing)
            }
            .foregroundStyle(colorScheme.foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme.border, lineWidth: colorScheme.border == .clear ? 0 : 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    
    @ViewBuilder
    private func weightFraction(current: Int, max: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 1) {
            Text("\(current)")
                .font(.plusJakarta(15, .bold))
            Text("/\(max) kg")
                .font(.plusJakarta(11, .semibold))
                .opacity(0.9)
        }
    }
}

#Preview("Leaderboard") {
    LeaderboardView(
        isModal: true,
        players: [
            PlayerStatusModel(id: "1", name: "Denzel", isCurrentDevice: true, suitcaseWeight: 10, suitcaseMax: 20, carryOnWeight: 8, carryOnMax: 7, isBoarded: false),
            PlayerStatusModel(id: "2", name: "Feivel", isCurrentDevice: false, suitcaseWeight: 16, suitcaseMax: 20, carryOnWeight: 3, carryOnMax: 7, isBoarded: false),
            PlayerStatusModel(id: "3", name: "Tohru", isCurrentDevice: false, suitcaseWeight: 8, suitcaseMax: 20, carryOnWeight: 4, carryOnMax: 7, isBoarded: false),
            PlayerStatusModel(id: "4", name: "Priska", isCurrentDevice: false, suitcaseWeight: 19, suitcaseMax: 20, carryOnWeight: 5, carryOnMax: 7, isBoarded: false),
            PlayerStatusModel(id: "5", name: "Indiana", isCurrentDevice: false, suitcaseWeight: 12, suitcaseMax: 20, carryOnWeight: 7, carryOnMax: 7, isBoarded: false)
        ]
    )
}
