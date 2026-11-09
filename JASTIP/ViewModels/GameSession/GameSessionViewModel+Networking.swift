import Foundation

extension GameSessionViewModel {
    var cloudGameState: CloudGameState {
        CloudGameState(
            card: airlineCard,
            pieceWeights: pieceWeights,
            sharedJastipOrders: sharedJastipOrders,
            currentHour: currentHour,
            delayHours: delayHours,
            isGameOver: isGameOver,
            currentEvent: currentEvent,
            activeHourEvent: activeHourEvent,
            triggeredUniqueEvents: triggeredUniqueEvents,
            lastRoundEventType: lastRoundEventType,
            turnOrder: turnOrder,
            currentTurnIndex: currentTurnIndex,
            daysToGo: daysToGo
        )
    }

    func applyCloudGameState(_ state: CloudGameState) {
        guard isGameStarted else { return }
        airlineCard = state.card
        pieceWeights = state.pieceWeights
        sharedJastipOrders = state.sharedJastipOrders
        currentHour = state.currentHour
        delayHours = state.delayHours
        isGameOver = state.isGameOver
        currentEvent = state.currentEvent
        activeHourEvent = state.activeHourEvent
        triggeredUniqueEvents = state.triggeredUniqueEvents
        lastRoundEventType = state.lastRoundEventType
        
        // Update Turn & Kalender dari Cloud
        self.turnOrder = state.turnOrder
        self.currentTurnIndex = state.currentTurnIndex
        self.daysToGo = state.daysToGo
        
        if state.isGameOver {
            broadcastMyStatus()
        }
    }

    // Dipanggil saat Host klik Start Game
    func startCloudGame() async {
        if sharedJastipOrders.isEmpty {
            sharedJastipOrders = JastipOrderCatalog.getRandomSharedOrders(count: 3)
        }
        
        // 1. Inisialisasi daftar giliran acak dari semua pemain di lobby
        if let lobbyPlayers = lobbyService.lobby?.players, !lobbyPlayers.isEmpty {
            let players = lobbyPlayers.map { TurnPlayer(id: $0.id, name: $0.name) }
            self.turnOrder = players.shuffled() // Acak urutan pertama kali!
        } else {
            self.turnOrder = [TurnPlayer(id: lobbyService.currentPlayerID ?? "local", name: playerName)]
        }
        self.currentTurnIndex = 0
        self.daysToGo = max(1, boardingHour - 8)
        
        await lobbyService.startGame(state: cloudGameState)
    }

    /// Logika perpindahan giliran saat pemain klik "End Turn"
    func endCurrentTurn() {
        guard !turnOrder.isEmpty else { return }
        
        // Kasus 1: Masih ada pemain berikutnya di round ini
        if currentTurnIndex + 1 < turnOrder.count {
            currentTurnIndex += 1
        } else {
            // Kasus 2: Semua pemain di round ini sudah main!
            // Kurangi kalender hari (Days to go)
            if daysToGo > 0 {
                // Masih ada hari tersisa (termasuk masuk ke Last Day saat 1 -> 0)
                daysToGo -= 1
                
                // Rotasi giliran: pemain pertama geser ke paling belakang
                var newOrder = turnOrder
                let previousFirst = newOrder.removeFirst()
                newOrder.append(previousFirst)
                self.turnOrder = newOrder
                // Pemain kedua (yang sekarang jadi index 0) mulai duluan di round baru
                self.currentTurnIndex = 0
                
                // Majukan jam game & roll event
                nextHour()
            } else {
                // Round "LAST DAY" sudah selesai dimainkan semua orang -> GAME OVER!
                isGameOver = true
                broadcastMyStatus()
            }
        }
        
        // Broadcast perubahan giliran ke semua device di Firebase!
        Task {
            await publishCloudGameState()
        }
    }

    func publishCloudGameState() async {
        await lobbyService.publishGameState(cloudGameState)
    }

    func broadcastMyStatus() {
        guard let playerID = lobbyService.currentPlayerID else { return }
        let payload = PlayerSyncPayload(
            peerId: playerID,
            name: currentPlayerStatus.name,
            suitcaseWeight: suitWeight,
            carryOnWeight: carryWeight,
            isBoarded: isBoarded || isGameOver
        )
        Task {
            await lobbyService.publishPlayerStatus(payload)
        }
    }

    func resetToLobby() {
        isGameOver = false
        isGameStarted = false
        hasProceededToGame = false
        Task {
            await lobbyService.leaveLobby()
        }
        startNewGame()
    }
}
