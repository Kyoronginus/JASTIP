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
    
    let airlineCard: AirlineCardModel
    var currentHour: Int = 8
    var delayHours: Int = 0
    var currentEvent: RandomEventModel? = nil
    var isGameOver: Bool = false
    
    // MARK: - Network Integration Properties
    var networkManager = NetworkSessionManager()
    var isGameStarted: Bool = false // Status untuk trigger pindah view dari StartView ke GameView
    
    var connectedPlayersCount: Int {
        return networkManager.connectedPeersCount
    }
    
    func triggerStartGame() {
        networkManager.sendStartGameTrigger()
    }
    
    // MARK: - Private State Tracking
    private var availableEvents: [RandomEventType] = RandomEventType.allCases
    private var eventCount: Int = 0
    private var lastEventHour: Int? = nil
    
    init(airlineCard: AirlineCardModel = AirlineCardCatalog.dummy) {
        self.airlineCard = airlineCard
        generateRandomizedWeights()
        
        // Setup callback ketika sinyal START_GAME diterima dari device lain
        networkManager.onStartGameReceived = { [weak self] in
            self?.isGameStarted = true
        }
    }
        
        func startNewGame() {
            revealedPieces.removeAll()
            currentHour = 8
            delayHours = 0
            currentEvent = nil
            isGameOver = false
            availableEvents = RandomEventType.allCases
            eventCount = 0
            lastEventHour = nil
            generateRandomizedWeights()
        }
        
        func weight(for pieceId: String) -> Int {
            return pieceWeights[pieceId] ?? PieceCatalog.findPiece(by: pieceId)?.gridCount ?? 1
        }
        
        func recordScannedPiece(_ piece: PieceModel, weight: Int) {
            if !revealedPieces.contains(where: { $0.id == piece.id }) {
                revealedPieces.append(RevealedPiece(piece: piece, weight: weight))
            }
        }
        
        private func generateRandomizedWeights() {
            var weights: [String: Int] = [:]
            let deltas = [-2, -1, 1, 2]
            
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
        
        // MARK: - Computed Presentation Properties
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
            if currentHour >= boardingHour {
                isGameOver = true
            } else {
                currentHour += 1
                checkForRandomEvent()
            }
        }
        
        func dismissEvent() {
            currentEvent = nil
        }
        
        private func checkForRandomEvent() {
            // 1. Maksimal 2 event per game
            guard eventCount < 2 else { return }
            
            // 2. Tidak boleh di 2 ronde terakhir
            guard currentHour <= (boardingHour - 2) else { return }
            
            // 3. Cooldown: Tidak boleh 2 jam berturut-turut kena event
            if let last = lastEventHour, currentHour <= (last + 1) {
                return
            }
            
            // 4. Kocok RNG 30%
            let roll = Int.random(in: 1...100)
            guard roll <= 30 else { return }
            
            // 5. Ambil event dari katalog
            if let event = RandomEventCatalog.getRandomEvent(from: availableEvents) {
                currentEvent = event
                availableEvents.removeAll { $0 == event.type }
                eventCount += 1
                lastEventHour = currentHour
                
                // Efek khusus Flight Delay: Tambah boarding +1 jam
                if event.type == .flightDelay {
                    delayHours += 1
                }
            }
        }
    }
