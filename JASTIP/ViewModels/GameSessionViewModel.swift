//
//  GameSessionViewModel.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI
import Observation

@Observable
class GameSessionViewModel {
    var pieceWeights: [String: Int] = [:]
    var revealedPieces: [RevealedPiece] = []
    
    var airlineCard: AirlineCardModel
    var currentHour: Int = 8
    var delayHours: Int = 0
    var currentEvent: RandomEventModel? = nil
    var activeHourEvent: RandomEventModel? = nil
    var isZeroWeightHour: Bool {
        activeHourEvent?.type == .zeroWeight
    }
    
    var isGameOver: Bool = false
    var lockHostToggle: Bool = false
    
    // MARK: - Weight Tracking Properties
    var suitWeight: Int = 0
    var carryWeight: Int = 0
    
    // MARK: - Player & Leaderboard Properties
    var playerName: String = UIDevice.current.name
    var isBoarded: Bool = false
    
    // Status real-time pemain ini (auto-sync dengan berat koper & kapasitas maskapai)
    var currentPlayerStatus: PlayerStatusModel {
        // Kalau player sengaja ngehapus sampai kosong, tetap fallback aman ke nama device
        let finalName = playerName.trimmingCharacters(in: .whitespaces).isEmpty ? UIDevice.current.name : playerName
        
        return PlayerStatusModel(
            id: "local_player",
            name: finalName,
            isCurrentDevice: true,
            suitcaseWeight: suitWeight,
            suitcaseMax: displayedAirlineCard.maxCapacityKg,
            carryOnWeight: carryWeight,
            carryOnMax: displayedAirlineCard.maxCarryOnKg,
            isBoarded: isBoarded || isGameOver
        )
    }
    
    // Dictionary untuk menampung data live dari pemain lain (Key: peerId)
    var remotePlayers: [String: PlayerSyncPayload] = [:]
    
    // List player untuk ditampilkan di Leaderboard
    var leaderboardPlayers: [PlayerStatusModel] {
        var list = [currentPlayerStatus]
        
        // Loop teman-teman yang connect via network
        for peerName in networkManager.connectedPeerNames {
            if let synced = remotePlayers[peerName] {
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
        }
        return list
    }
    
    // MARK: - Private State Tracking
    private var triggeredUniqueEvents: Set<RandomEventType> = []
    
    // MARK: - Network Integration Properties
    var networkManager = NetworkSessionManager()
    var isGameStarted: Bool = false // Status untuk trigger pindah view dari StartView ke GameView
    
    var connectedPlayersCount: Int {
        return networkManager.connectedPeersCount
    }
    
    func triggerStartGame() {
        networkManager.sendStartGameTrigger(card: airlineCard, pieceWeights: pieceWeights)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.broadcastMyStatus()
        }
    }
    
    init(airlineCard: AirlineCardModel = AirlineCardCatalog.getRandomCard()) {
        self.airlineCard = airlineCard
        generateRandomizedWeights()
        
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
    
    func startNewGame() {
        revealedPieces.removeAll()
        remotePlayers.removeAll()
        currentHour = 8
        delayHours = 0
        currentEvent = nil
        activeHourEvent = nil
        isGameOver = false
        isBoarded = false
        triggeredUniqueEvents.removeAll() // Reset event unik saat game baru dimulai
        suitWeight = 0
        carryWeight = 0
        generateRandomizedWeights()
        self.airlineCard = AirlineCardCatalog.getRandomCard()
    }
    
    
    func weight(for pieceId: String) -> Int {
        // 1. Cek apakah piece ini (atau kembarannya) sudah pernah direveal di carousel
        if let revealed = revealedPieces.first(where: { $0.id == pieceId }) {
            return revealed.weight
        }
        
        // 2. Cek apakah ada bobot terdaftar di dictionary pieceWeights
        if let weight = pieceWeights[pieceId] {
            return weight
        }
        
        // 3. Fallback konsistensi: jika ada piece dengan bentuk dan warna sama
        if let piece = PieceCatalog.findPiece(by: pieceId) {
            if let matchingRevealed = revealedPieces.first(where: { $0.piece.color == piece.color && $0.piece.shape == piece.shape }) {
                return matchingRevealed.weight
            }
            if let matchingId = pieceWeights.keys.first(where: { id in
                if let other = PieceCatalog.findPiece(by: id) {
                    return other.color == piece.color && other.shape == piece.shape
                }
                return false
            }), let matchingWeight = pieceWeights[matchingId] {
                return matchingWeight
            }
            return piece.gridCount
        }
        
        return 1
    }
    
    func recordScannedPiece(_ piece: PieceModel, weight: Int) {
        pieceWeights[piece.id] = weight
        if !revealedPieces.contains(where: { $0.id == piece.id }) {
            revealedPieces.append(RevealedPiece(piece: piece, weight: weight))
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
    
    private func generateRandomizedWeights() {
        var weights: [String: Int] = [:]
        let deltas = [1, 1, 2, 2, 3]
        
        let allColors: [PieceColor] = [.red, .yellow, .green, .blue, .pink]
        
        for color in allColors {
            let piecesOfColor = PieceCatalog.allPieces.filter { $0.color == color }
            
            let normalPieces = piecesOfColor.filter{ !$0.isAnomaly }
            let uniquePieces = piecesOfColor.filter{ $0.isAnomaly }
            
            for piece in uniquePieces {
                weights[piece.id] = piece.gridCount
            }
            
            // shuffle normal pieces
            let shuffledNormalPieces = normalPieces.shuffled()
            
            for (index, piece) in shuffledNormalPieces.enumerated() {
                if index < deltas.count {
                    let delta = deltas[index]
                    
                    // bnobot minimal 1 kg
                    let finalWeight = max(1, piece.gridCount + delta)
                    weights[piece.id] = finalWeight
                } else {
                    weights[piece.id] = piece.gridCount
                }
            }
        }
        
        self.pieceWeights = weights
    }
    
    var currentTimeString: String {
        String(format: "%02d:00", currentHour)
    }
    
    var boardingHour: Int {
        let clean = airlineCard.departureTime.replacingOccurrences(of: ".", with: ":")
        let hourStr = clean.split(separator: ":").first ?? "15"
        return (Int(hourStr) ?? 15) + delayHours
    }
    
    var displayedAirlineCard: AirlineCardModel {
        if delayHours == 0 {
            return airlineCard
        } else {
            return AirlineCardModel(
                id: airlineCard.id,
                airlineName: airlineCard.airlineName,
                maxCapacityKg: airlineCard.maxCapacityKg,
                maxCarryOnKg: airlineCard.maxCarryOnKg,
                departureTime: String(format: "%02d:00", boardingHour)
            )
        }
    }
    
    
    
    
    
    
    // MARK: - Business Logic Methods
    func nextHour() {
        if currentHour > boardingHour {
            isGameOver = true
            return
        }
        
        currentHour += 1
        
        let event = rollForRandomEvent()
        currentEvent = event
        activeHourEvent = event
        
        if event?.type == .flightDelay {
            delayHours += 1
        }
        
        let gameOverStatus = currentHour >= boardingHour
        self.isGameOver = gameOverStatus
        
        // kirim payload ke pemain lain
        let payload = NextHourPayload(
            newHour: currentHour, delayHour: delayHours, event: event, isGameOver: gameOverStatus
        )
        networkManager.sendNextHourTrigger(payload: payload)
    }
    
    func dismissEvent() {
        currentEvent = nil
    }
    
    func applyRemoteNextHour(payload: NextHourPayload) {
        self.currentHour = payload.newHour
        self.delayHours = payload.delayHour
        self.currentEvent = payload.event
        self.activeHourEvent = payload.event
        self.isGameOver = payload.isGameOver
    }
    
    
    // pengganti checkForRandomEvent()
    private func rollForRandomEvent() -> RandomEventModel? {
        let roll = Int.random(in: 1...100)
        guard roll <= 40 else { return nil }
        
        let availableTypes = RandomEventType.allCases.filter { type in
            if type == .flightDelay || type == .relativeCanceled {
                return !triggeredUniqueEvents.contains(type)
            }
            return true
        }
        guard !availableTypes.isEmpty else { return nil }
        
        if let event = RandomEventCatalog.getRandomEvent(from: availableTypes) {
            if event.type == .flightDelay || event.type == .relativeCanceled {
                triggeredUniqueEvents.insert(event.type)
            }
            return event
        }
        return nil
    }
    
    
    // Fungsi untuk mencatat item sekaligus memilih tempat (Suitcase / Carry-On)
    func recordItemPlacement(piece: PieceModel, weight: Int, isSuitcase: Bool) {
        guard !isBoarded && !isGameOver else { return }
        
        let revealed = RevealedPiece(piece: piece, weight: weight)
        
        // Simpan bobot ke dictionary agar konsisten
        pieceWeights[piece.id] = weight
        
        // 1. Masukin ke carousel HP sendiri kalau belum ada
        if !revealedPieces.contains(where: { $0.id == piece.id }) {
            revealedPieces.append(revealed)
        }
        
        // 2. Kirim datanya ke HP player lain via Multipeer
        networkManager.sendScannedItem(piece: revealed, weight: weight)
        
        // 3. Tambahin bobot HANYA ke tracker HP ini sendiri (berat suitcase/carry-on gak digabung ke HP lain)
        let effectiveWeight = isZeroWeightHour ? 0 : weight
        if isSuitcase {
            suitWeight += effectiveWeight
        } else {
            carryWeight += effectiveWeight
        }
        
        broadcastMyStatus()
    }
    
    func boardFlight() {
        guard !isBoarded && !isGameOver else { return }
        
        isBoarded = true
        broadcastMyStatus()
        
        // check if all players have boarded. if yes -> trigger game over
        checkAllPlayersBoarded()
    }
    
    private func checkAllPlayersBoarded() {
        guard isBoarded else { return }
        
        let connectedPeers = networkManager.connectedPeerNames
        if !connectedPeers.isEmpty {
            let allRemoteBoarded = connectedPeers.allSatisfy { peerName in
                remotePlayers[peerName]?.isBoarded == true
            }
            if allRemoteBoarded {
                isGameOver = true
            }
        } else {
            // Solo play
            isGameOver = true
        }
    }
    
    func resetToLobby() {
        isGameOver = false
        isGameStarted = false
        networkManager.endGame()
        startNewGame()
    }
}
