import Foundation

extension GameSessionViewModel {
    var cloudGameState: CloudGameState {
        CloudGameState(
            card: airlineCard,
            pieceWeights: pieceWeights,
            currentHour: currentHour,
            delayHours: delayHours,
            isGameOver: isGameOver,
            currentEvent: currentEvent,
            activeHourEvent: activeHourEvent,
            triggeredUniqueEvents: triggeredUniqueEvents,
            lastRoundEventType: lastRoundEventType
        )
    }

    func applyCloudGameState(_ state: CloudGameState) {
        guard isGameStarted else { return }
        airlineCard = state.card
        pieceWeights = state.pieceWeights
        currentHour = state.currentHour
        delayHours = state.delayHours
        isGameOver = state.isGameOver
        currentEvent = state.currentEvent
        activeHourEvent = state.activeHourEvent
        triggeredUniqueEvents = state.triggeredUniqueEvents
        lastRoundEventType = state.lastRoundEventType
        if state.isGameOver {
            broadcastMyStatus()
        }
    }

    func startCloudGame() async {
        await lobbyService.startGame(state: cloudGameState)
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
