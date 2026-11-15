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
            consecutiveEventMisses: consecutiveEventMisses,
            turnOrder: turnOrder,
            currentTurnIndex: currentTurnIndex,
            daysToGo: daysToGo
        )
    }

    func applyCloudGameState(_ state: CloudGameState) {
        guard isGameStarted else { return }
        let previousHour = self.currentHour
        let previousDays = self.daysToGo
        
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
        consecutiveEventMisses = state.consecutiveEventMisses ?? 0
        
        // Update Turn & Kalender dari Cloud
        self.turnOrder = state.turnOrder
        self.currentTurnIndex = state.currentTurnIndex
        self.daysToGo = state.daysToGo
        
        // Jika round baru dimulai (jam maju dan belum game over), jalankan animasi End of Round + Restock
        if state.currentHour > previousHour && !state.isGameOver {
            triggerRoundTransitionAnimation(from: previousDays, to: state.daysToGo)
        }
        
        if state.isGameOver {
            broadcastMyStatus()
        }
    }

    // Dipanggil saat Host klik Start Game
    func startCloudGame() async {
        if sharedJastipOrders.isEmpty {
            sharedJastipOrders = JastipOrderCatalog.getRandomSharedOrders(count: 3)
        }
        
        // Gunakan urutan pemain dari lobby sebagai urutan giliran awal.
        if let lobbyPlayers = lobbyService.lobby?.players, !lobbyPlayers.isEmpty {
            self.turnOrder = lobbyPlayers.map { TurnPlayer(id: $0.id, name: $0.name) }
        } else {
            self.turnOrder = [TurnPlayer(id: lobbyService.currentPlayerID ?? "local", name: playerName)]
        }
        self.currentTurnIndex = 0
        self.daysToGo = max(1, boardingHour - 8)
        self.consecutiveEventMisses = 0
        
        await lobbyService.startGame(state: cloudGameState)
    }

    /// Logika perpindahan giliran saat pemain klik "End Turn"
    func endCurrentTurn() {
        // Kasus 1: Masih ada pemain berikutnya di round ini
        if !turnOrder.isEmpty && currentTurnIndex + 1 < turnOrder.count {
            currentTurnIndex += 1
        } else {
            // Kasus 2: Semua pemain di round ini sudah main!
            // Kurangi kalender hari (Days to go)
            if daysToGo > 0 {
                let previousDays = daysToGo
                // Masih ada hari tersisa (termasuk masuk ke Last Day saat 1 -> 0)
                daysToGo -= 1
                
                // Rotasi giliran: pemain pertama geser ke paling belakang
                if !turnOrder.isEmpty {
                    var newOrder = turnOrder
                    let previousFirst = newOrder.removeFirst()
                    newOrder.append(previousFirst)
                    self.turnOrder = newOrder
                }
                // Pemain kedua (yang sekarang jadi index 0) mulai duluan di round baru
                self.currentTurnIndex = 0
                
                // Majukan jam game & roll event
                nextHour()
                
                if !isGameOver {
                    triggerRoundTransitionAnimation(from: previousDays, to: daysToGo)
                }
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
            isBoarded: isBoarded || isGameOver,
            income: calculatedIncome,
            penalty: calculatedPenalty,
            isScoreSubmitted: isScoreSubmitted
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
