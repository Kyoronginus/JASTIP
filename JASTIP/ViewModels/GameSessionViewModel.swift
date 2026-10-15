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
    var isGameOver: Bool = false
    
    // MARK: - Private State Tracking
        private var triggeredUniqueEvents: Set<RandomEventType> = []
    
    // MARK: - Network Integration Properties
    var networkManager = NetworkSessionManager()
    var isGameStarted: Bool = false // Status untuk trigger pindah view dari StartView ke GameView
    
    var connectedPlayersCount: Int {
        return networkManager.connectedPeersCount
    }
    
    func triggerStartGame() {
        networkManager.sendStartGameTrigger(card: airlineCard)
    }
    
    // MARK: - Private State Tracking
    private var availableEvents: [RandomEventType] = RandomEventType.allCases
    private var eventCount: Int = 0
    private var lastEventHour: Int? = nil
    
    init(airlineCard: AirlineCardModel = AirlineCardCatalog.getRandomCard()) {
        self.airlineCard = airlineCard
        generateRandomizedWeights()
        
        // Setup callback ketika sinyal START_GAME diterima dari device lain
        networkManager.onStartGameReceived = { [weak self] card in
            self?.airlineCard = card
            self?.isGameStarted = true
        }

        // Setup callback ketika pemain lain memencet Next Hour
        networkManager.onNextHourPayloadReceived = { [weak self] payload in
            self?.applyRemoteNextHour(payload: payload)
        }
    }
        
        func startNewGame() {
            revealedPieces.removeAll()
            currentHour = 8
            delayHours = 0
            currentEvent = nil
            isGameOver = false
            triggeredUniqueEvents.removeAll() // Reset event unik saat game baru dimulai
            generateRandomizedWeights()
            self.airlineCard = AirlineCardCatalog.getRandomCard()
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
                return
            }
            
            currentHour += 1
            
            let event = rollForRandomEvent()
            currentEvent = event
            
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
    
    
        // gapake lagi
        private func checkForRandomEvent() {
            // 1. Kocok RNG dengan probabilitas 40%
            let roll = Int.random(in: 1...100)
            guard roll <= 40 else { return }
            
            // 2. Filter event yang belum pernah muncul (khusus .flightDelay dan .relativeCanceled)
            // Event lain yang tidak dibatasi bisa terus masuk
            let availableTypes = RandomEventType.allCases.filter { type in
                if type == .flightDelay || type == .relativeCanceled {
                    return !triggeredUniqueEvents.contains(type)
                }
                return true
            }
            
            // Jika semua event berbatas sudah habis terpanggil, ambil dari yang tersisa
            guard !availableTypes.isEmpty else { return }
            
            // 3. Ambil event dari katalog menggunakan fungsi berbobot yang sudah ada
            if let event = RandomEventCatalog.getRandomEvent(from: availableTypes) {
                
                // 4. Jika event yang keluar termasuk yang dibatasi, tandai agar tidak muncul lagi
                if event.type == .flightDelay || event.type == .relativeCanceled {
                    triggeredUniqueEvents.insert(event.type)
                }
                
                currentEvent = event
                
                // Efek khusus Flight Delay: Tambah boarding +1 jam
                if event.type == .flightDelay {
                    delayHours += 1
                }
            }
        }
    
        func resetToLobby() {
            isGameOver = false
            isGameStarted = false
            startNewGame()
        }
    }
