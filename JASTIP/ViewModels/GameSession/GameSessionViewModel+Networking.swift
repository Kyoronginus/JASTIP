//
//  GameSessionViewModel+Networking.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 22/10/26.
//



import Foundation

extension GameSessionViewModel {
    
    func setupNetworkCallbacks() {      
        // Setup callback ketika sinyal START_GAME diterima dari device lain
        networkManager.onStartGameReceived = { [weak self] card, weights in
            self?.airlineCard = card
            if !weights.isEmpty {
                self?.pieceWeights = weights
            }
            self?.isGameStarted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.broadcastMyStatus()
            }
        }
        
        // Setup callback ketika pemain lain memencet Next Hour
        networkManager.onNextHourPayloadReceived = { [weak self] payload in
            self?.applyRemoteNextHour(payload: payload)
        }
        
        networkManager.onScannedItemReceived = { [weak self] revealedPiece, weight in
            guard let self = self else { return }
            self.pieceWeights[revealedPiece.piece.id] = weight
            if !self.revealedPieces.contains(where: { $0.id == revealedPiece.id }) {
                self.revealedPieces.append(revealedPiece)
            }
        }
        
        // Setup snapshot untuk sinkronisasi pemain yang reconnect
        networkManager.snapshotProvider = { [weak self] in
            guard let self = self else { return nil }
            struct Snapshot: Codable {
                let card: AirlineCardModel
                let pieceWeights: [String: Int]
                let currentHour: Int
                let delayHours: Int
                let revealedPieces: [RevealedPiece]
                let isGameOver: Bool
            }
            let snapshot = Snapshot(
                card: self.airlineCard,
                pieceWeights: self.pieceWeights,
                currentHour: self.currentHour,
                delayHours: self.delayHours,
                revealedPieces: self.revealedPieces,
                isGameOver: self.isGameOver
            )
            return try? JSONEncoder().encode(snapshot)
        }
        
        // Setup listener sync data player lain
        networkManager.onPlayerSyncReceived = { [weak self] senderPeerName, payload in
            self?.remotePlayers[senderPeerName] = payload
            self?.checkAllPlayersBoarded()
        }
        
        networkManager.onSnapshotReceived = { [weak self] data in
            struct Snapshot: Codable {
                let card: AirlineCardModel
                let pieceWeights: [String: Int]
                let currentHour: Int
                let delayHours: Int
                let revealedPieces: [RevealedPiece]
                let isGameOver: Bool
            }
            guard let self = self,
                  let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
            self.airlineCard = snapshot.card
            self.pieceWeights = snapshot.pieceWeights
            self.currentHour = snapshot.currentHour
            self.delayHours = snapshot.delayHours
            self.revealedPieces = snapshot.revealedPieces
            self.isGameOver = snapshot.isGameOver
            self.isGameStarted = true
        }
    }
    

    
    func triggerStartGame() {
        networkManager.sendStartGameTrigger(card: airlineCard, pieceWeights: pieceWeights)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.broadcastMyStatus()
        }
    }
    
    func broadcastMyStatus() {
        let payload = PlayerSyncPayload(
            peerId: networkManager.myDisplayName,
            name: currentPlayerStatus.name,
            suitcaseWeight: suitWeight,
            carryOnWeight: carryWeight,
            isBoarded: isBoarded || isGameOver
        )
        networkManager.sendPlayerSync(payload: payload)
    }
    
    func applyRemoteNextHour(payload: NextHourPayload) {
        self.currentHour = payload.newHour
        self.delayHours = payload.delayHour
        self.lastRoundEventType = payload.event?.type
        self.currentEvent = payload.event
        self.activeHourEvent = payload.event
        self.isGameOver = payload.isGameOver
    }
    
    func resetToLobby() {
        isGameOver = false
        isGameStarted = false
        networkManager.endGame()
        startNewGame()
    }
    
    
}
