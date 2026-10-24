//
//  GameSessionViewModel+Boarding.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 22/10/26.
//
import UIKit

extension GameSessionViewModel {
    // MARK: - Player & Leaderboard Computed Props
    
    // Status real-time pemain ini (auto-sync dengan berat koper & kapasitas maskapai)
    var currentPlayerStatus: PlayerStatusModel {
        // Kalau player sengaja ngehapus sampai kosong, tetap fallback aman ke nama device
        let finalName = playerName.trimmingCharacters(in: .whitespaces).isEmpty ? UIDevice.current.name : playerName
        
        return PlayerStatusModel(
            id: lobbyService.currentPlayerID ?? "local_player",
            name: finalName,
            isCurrentDevice: true,
            suitcaseWeight: suitWeight,
            suitcaseMax: displayedAirlineCard.maxCapacityKg,
            carryOnWeight: carryWeight,
            carryOnMax: displayedAirlineCard.maxCarryOnKg,
            isBoarded: isBoarded || isGameOver
        )
    }
    
    // List player untuk ditampilkan di Leaderboard
    var leaderboardPlayers: [PlayerStatusModel] {
        var list = [currentPlayerStatus]
        
        for synced in remotePlayers.values {
            list.append(
                PlayerStatusModel(
                    id: synced.peerId,
                    name: synced.name,
                    isCurrentDevice: false,
                    suitcaseWeight: synced.suitcaseWeight,
                    suitcaseMax: displayedAirlineCard.maxCapacityKg,
                    carryOnWeight: synced.carryOnWeight,
                    carryOnMax: displayedAirlineCard.maxCarryOnKg,
                    isBoarded: synced.isBoarded
                )
            )
        }
        return list
    }
    
    
    func boardFlight() {
        guard !isBoarded && !isGameOver else { return }
        
        isBoarded = true
        broadcastMyStatus()
        
        // check if all players have boarded. if yes -> trigger game over
        checkAllPlayersBoarded()
    }
    
    func checkAllPlayersBoarded() {
        guard isBoarded, !isGameOver else { return }
        let currentPlayerID = lobbyService.currentPlayerID
        let otherPlayers = lobbyService.lobby?.players.filter { $0.id != currentPlayerID } ?? []
        guard otherPlayers.allSatisfy({ remotePlayers[$0.id]?.isBoarded == true }) else { return }

        isGameOver = true
        broadcastMyStatus()
        if lobbyService.lobby?.isHost == true {
            Task { await publishCloudGameState() }
        }
    }
    
}
