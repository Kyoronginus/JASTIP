//
//  LeaderboardView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 20/10/26.
//


import SwiftUI

struct LeaderboardCard: View {
    @Environment(\.dismiss) private var dismiss
    var isModal: Bool = true
    var players: [PlayerStatusModel]
    var onBoard: (() -> Void)? = nil
    
    private var currentPlayer: PlayerStatusModel? {
        players.first(where: { $0.isCurrentDevice })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(players) { player in
                        PlayerStatusCard(player: player)
                    }
                    
                    // Button only appears for the current device if not yet boarded
                    if isModal, let currentPlayer, !currentPlayer.isBoarded {
                        Button {
                            onBoard?()
                        } label: {
                            HStack {
                                Text("Board Flight")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: .blue))
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Flight Boarding Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}


struct PlayerStatusCard: View {
    let player: PlayerStatusModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Nama Player & Badge Status
            HStack {
                HStack(spacing: 6) {
                    Text(player.name)
                        .font(.headline.bold())
                    
                    if player.isCurrentDevice {
                        Text("YOU")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.gray.opacity(0.15))
                            .foregroundStyle(.secondary)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                if player.isBoarded {
                    Label("BOARDED", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                } else if player.isOverweight {
                    Label("OVERWEIGHT", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                } else {
                    Label("SHOPPING", systemImage: "bag.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suitcase")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(player.suitcaseWeight)")
                            .font(.title3.bold())
                            .foregroundStyle(player.suitcaseWeight > player.suitcaseMax ? .red : .primary)
                        Text("/ \(player.suitcaseMax) kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Carry-on")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(player.carryOnWeight)")
                            .font(.title3.bold())
                            .foregroundStyle(player.carryOnWeight > player.carryOnMax ? .red : .primary)
                        Text("/ \(player.carryOnMax) kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}



#Preview("Light") {
    LeaderboardCard(
        isModal: true,
        players: [
            PlayerStatusModel(id: "1", name: "Feivel", isCurrentDevice: true, suitcaseWeight: 18, suitcaseMax: 20, carryOnWeight: 5, carryOnMax: 6, isBoarded: false),
            PlayerStatusModel(id: "2", name: "Denzel", isCurrentDevice: false, suitcaseWeight: 22, suitcaseMax: 20, carryOnWeight: 4, carryOnMax: 6, isBoarded: false),
            PlayerStatusModel(id: "3", name: "Tohru", isCurrentDevice: false, suitcaseWeight: 15, suitcaseMax: 20, carryOnWeight: 6, carryOnMax: 6, isBoarded: true)
        ]
    )
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    LeaderboardCard(
        isModal: true,
        players: [
            PlayerStatusModel(id: "1", name: "Feivel", isCurrentDevice: true, suitcaseWeight: 18, suitcaseMax: 20, carryOnWeight: 5, carryOnMax: 6, isBoarded: false),
            PlayerStatusModel(id: "2", name: "Denzel", isCurrentDevice: false, suitcaseWeight: 22, suitcaseMax: 20, carryOnWeight: 4, carryOnMax: 6, isBoarded: false),
            PlayerStatusModel(id: "3", name: "Tohru", isCurrentDevice: false, suitcaseWeight: 15, suitcaseMax: 20, carryOnWeight: 6, carryOnMax: 6, isBoarded: true)
        ]
    )
    .preferredColorScheme(.dark)
}
