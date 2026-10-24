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
    // MARK: - Game Flow & Clock
    var currentHour: Int = 8
    var delayHours: Int = 0
    var isGameOver: Bool = false
    var isGameStarted: Bool = false
    var hasProceededToGame: Bool = false // <-- TAMBAHKAN INI
    var lockHostToggle: Bool = false
    
    var currentTimeString: String {
        String(format: "%02d:00", currentHour)
    }
    
    // MARK: - Airline & Flight
    var airlineCard: AirlineCardModel
    
    var boardingHour: Int {
        let clean = airlineCard.departureTime.replacingOccurrences(of: ".", with: ":")
        let hourStr = clean.split(separator: ":").first ?? "15"
        return (Int(hourStr) ?? 15) + delayHours
    }
    
    var displayedAirlineCard: AirlineCardModel {
        guard delayHours > 0 else { return airlineCard }
        return AirlineCardModel(
            id: airlineCard.id,
            airlineName: airlineCard.airlineName,
            maxCapacityKg: airlineCard.maxCapacityKg,
            maxCarryOnKg: airlineCard.maxCarryOnKg,
            departureTime: String(format: "%02d:00", boardingHour)
        )
    }
    
    // MARK: - Luggage & Items
    var suitWeight: Int = 0
    var carryWeight: Int = 0
    var pieceWeights: [String: Int] = [:]
    var revealedPieces: [RevealedPiece] = []
    
    // MARK: - Player & Leaderboard
    var playerName: String = UIDevice.current.name
    var isBoarded: Bool = false
    var remotePlayers: [String: PlayerSyncPayload] = [:]
    
    // MARK: - Random Events State
    var currentEvent: RandomEventModel? = nil
    var activeHourEvent: RandomEventModel? = nil
    var triggeredUniqueEvents: Set<RandomEventType> = []
    var lastRoundEventType: RandomEventType?
    
    // MARK: - Networking
    var networkManager = NetworkSessionManager()
    
    var connectedPlayersCount: Int {
        networkManager.connectedPeersCount
    }
    
    // MARK: - Initialization
    init(airlineCard: AirlineCardModel = AirlineCardCatalog.getRandomCard()) {
        self.airlineCard = airlineCard
        generateRandomizedWeights()
        setupNetworkCallbacks()
    }
    
    // MARK: - Game Lifecycle
    func startNewGame() {
        revealedPieces.removeAll()
        remotePlayers.removeAll()
        currentHour = 8
        delayHours = 0
        currentEvent = nil
        activeHourEvent = nil
        isGameOver = false
        isBoarded = false
        hasProceededToGame = false // <-- TAMBAHKAN INI
        triggeredUniqueEvents.removeAll()
        lastRoundEventType = nil
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
    
    func generateRandomizedWeights() {
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
    
    // mencatat revealed pieces beserta dengan weights
    func recordScannedPiece(_ piece: PieceModel, weight: Int) {
        pieceWeights[piece.id] = weight
        if !revealedPieces.contains(where: { $0.id == piece.id }) {
            revealedPieces.append(RevealedPiece(piece: piece, weight: weight))
        }
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
}
