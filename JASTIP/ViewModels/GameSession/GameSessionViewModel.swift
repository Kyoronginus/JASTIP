//
//  GameSessionViewModel.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI
import Observation

struct StagedItem: Identifiable, Equatable {
    let id: UUID
    let piece: PieceModel
    let weight: Int
    var rotation: LuggageRotation = .deg0
    let lockedLuggage: LuggageType?
    let isAlreadyCountedInWeight: Bool
}

@Observable
class GameSessionViewModel {
    // MARK: - Game Flow & Clock
    var currentHour: Int = 8
    var delayHours: Int = 0
    var isGameOver: Bool = false
    var isGameStarted: Bool = false
    var hasProceededToGame: Bool = false // <-- TAMBAHKAN INI
    
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
    
    // MARK: - Luggage Grids (3x5 Suitcase & 2x2 Carry-On)
    var suitcaseGrid: LuggageGridModel = .suitcase
    var carryOnGrid: LuggageGridModel = .carryOn
    var stagedItems: [StagedItem] = []
    var stagingWeight: Int? = nil
    
    // Snapshot untuk memulihkan posisi koper jika user membatalkan penataan
    private var snapshotSuitcaseGrid: LuggageGridModel? = nil
    private var snapshotCarryOnGrid: LuggageGridModel? = nil
    
    var stagingPiece: PieceModel? {
        get { stagedItems.first?.piece }
        set {
            if let newPiece = newValue {
                stagedItems = [
                    StagedItem(
                        id: UUID(),
                        piece: newPiece,
                        weight: stagingWeight ?? weight(for: newPiece.id),
                        rotation: .deg0,
                        lockedLuggage: nil,
                        isAlreadyCountedInWeight: false
                    )
                ]
            } else {
                stagedItems.removeAll()
            }
        }
    }
    
    // MARK: - Player & Leaderboard
    var playerName: String = UIDevice.current.name
    var isBoarded: Bool = false
    var remotePlayers: [String: PlayerSyncPayload] = [:]
    
    // MARK: - Random Events State
    var currentEvent: RandomEventModel? = nil
    var activeHourEvent: RandomEventModel? = nil
    var triggeredUniqueEvents: Set<RandomEventType> = []
    var lastRoundEventType: RandomEventType?
    
    // MARK: - Firebase Lobby
    var lobbyService = FirebaseLobbyService()
    
    // MARK: - Initialization
    init(airlineCard: AirlineCardModel = AirlineCardCatalog.getRandomCard()) {
        self.airlineCard = airlineCard
        generateRandomizedWeights()
        lobbyService.onGameStarted = { [weak self] card, weights in
            guard let self else { return }
            self.airlineCard = card
            self.pieceWeights = weights
            self.isGameStarted = true
            self.hasProceededToGame = false
            self.broadcastMyStatus()
        }
        lobbyService.onGameStateChanged = { [weak self] state in
            self?.applyCloudGameState(state)
        }
        lobbyService.onPlayerStatusesChanged = { [weak self] statuses in
            guard let self else { return }
            self.remotePlayers = statuses.filter { $0.key != self.lobbyService.currentPlayerID }
            self.checkAllPlayersBoarded()
        }
        lobbyService.onToastReceived = { [weak self] toast in
            guard let self = self else { return }
            // Cegah re-trigger animasi jika ID toast-nya sama
            if self.activeToast?.id != toast.id {
                withAnimation {
                    self.activeToast = toast
                }
            }
        }
        lobbyService.onScannedPiecesChanged = { [weak self] scans in
            guard let self else { return }
            self.revealedPieces = scans
            for scan in scans {
                self.pieceWeights[scan.piece.id] = scan.weight
            }
        }
    }
    
    // MARK: - Global Toast System
        var activeToast: ToastOptions? = nil
        
        func showToast(_ message: String, type: ToastModel = .info, duration: TimeInterval = 2.5, broadcast: Bool = true) {
            let toast = ToastOptions(id: UUID().uuidString, message: message, type: type, duration: duration)
            withAnimation {
                self.activeToast = toast
            }
            
            // Kirim ke semua device lain via Firebase
            if broadcast {
                Task {
                    await lobbyService.publishToast(toast)
                }
            }
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
        suitcaseGrid = .suitcase
        carryOnGrid = .carryOn
        stagedItems.removeAll()
        stagingWeight = nil
        snapshotSuitcaseGrid = nil
        snapshotCarryOnGrid = nil
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
        let revealedPiece = RevealedPiece(piece: piece, weight: weight, scannedBy: currentPlayerStatus.name)
        if !revealedPieces.contains(where: { $0.id == piece.id }) {
            revealedPieces.append(revealedPiece)
            Task {
                await lobbyService.publishScannedPiece(revealedPiece)
            }
        }
    }
    
    // Fungsi untuk mencatat item sekaligus memilih tempat (Suitcase / Carry-On)
    func recordItemPlacement(piece: PieceModel, weight: Int, isSuitcase: Bool) {
        guard !isBoarded && !isGameOver else { return }
        
        let revealed = RevealedPiece(piece: piece, weight: weight, scannedBy: currentPlayerStatus.name)
        
        // Simpan bobot ke dictionary agar konsisten
        pieceWeights[piece.id] = weight
        
        // 1. Masukin ke carousel HP sendiri kalau belum ada
        if !revealedPieces.contains(where: { $0.id == piece.id }) {
            revealedPieces.append(revealed)
        }
        
        Task {
            await lobbyService.publishScannedPiece(revealed)
        }
        
        // 3. Tambahin bobot HANYA ke tracker HP ini sendiri (berat suitcase/carry-on gak digabung ke HP lain)
        let effectiveWeight = isZeroWeightHour ? 0 : weight
        if isSuitcase {
            suitWeight += effectiveWeight
        } else {
            carryWeight += effectiveWeight
        }
        
        broadcastMyStatus()
    }
    
    // MARK: - Grid Placement & Rearrangement Methods
    
    /// Simpan snapshot kondisi koper sebelum user mulai menata ulang
    func captureGridSnapshotIfNeeded() {
        if snapshotSuitcaseGrid == nil {
            snapshotSuitcaseGrid = suitcaseGrid
        }
        if snapshotCarryOnGrid == nil {
            snapshotCarryOnGrid = carryOnGrid
        }
    }
    
    /// Menambahkan barang baru hasil scan ke area staging
    func stageScannedPiece(_ piece: PieceModel, weight: Int, targetLuggage: LuggageType) {
        captureGridSnapshotIfNeeded()
        stagingWeight = weight
        // Hapus barang scan lama yang belum ditaruh jika ada, pertahankan barang yang sedang ditata ulang
        stagedItems.removeAll { !$0.isAlreadyCountedInWeight }
        stagedItems.append(
            StagedItem(
                id: UUID(),
                piece: piece,
                weight: weight,
                rotation: .deg0,
                lockedLuggage: targetLuggage,
                isAlreadyCountedInWeight: false
            )
        )
    }
    
    /// Mengeluarkan kepingan yang sudah ada di dalam koper kembali ke area staging untuk ditata ulang
    func removePlacedPieceToStaging(_ placedPiece: PlacedPiece) {
        captureGridSnapshotIfNeeded()
        if placedPiece.assignedLuggage == .suitcase {
            suitcaseGrid.placedPieces.removeAll { $0.id == placedPiece.id }
        } else {
            carryOnGrid.placedPieces.removeAll { $0.id == placedPiece.id }
        }
        
        let item = StagedItem(
            id: placedPiece.id,
            piece: placedPiece.piece,
            weight: weight(for: placedPiece.piece.id),
            rotation: placedPiece.rotation,
            lockedLuggage: placedPiece.assignedLuggage,
            isAlreadyCountedInWeight: true
        )
        if !stagedItems.contains(where: { $0.id == item.id }) {
            stagedItems.append(item)
        }
    }
    
    /// Memutar kepingan yang sedang berada di area staging
    func rotateStagedItem(id: UUID) {
        guard let index = stagedItems.firstIndex(where: { $0.id == id }) else { return }
        stagedItems[index].rotation = stagedItems[index].rotation.next
    }
    
    /// Menaruh kepingan dari staging (baik hasil scan baru maupun tata ulang) ke koper
    @discardableResult
    func placeStagedItem(
        id: UUID,
        at origin: GridCoordinate,
        into luggage: LuggageType
    ) -> Bool {
        guard let index = stagedItems.firstIndex(where: { $0.id == id }) else { return false }
        let item = stagedItems[index]
        
        // Container lock: jika terikat ke koper tertentu, tidak boleh pindah ke koper lain
        if let locked = item.lockedLuggage, locked != luggage {
            return false
        }
        
        let targetGrid = (luggage == .suitcase) ? suitcaseGrid : carryOnGrid
        guard LuggagePlacementEngine.canPlace(
            piece: item.piece,
            at: origin,
            rotation: item.rotation,
            in: targetGrid
        ) else {
            return false
        }
        
        let placed = PlacedPiece(
            id: item.id,
            piece: item.piece,
            origin: origin,
            rotation: item.rotation,
            assignedLuggage: luggage
        )
        
        if luggage == .suitcase {
            suitcaseGrid.placedPieces.append(placed)
        } else {
            carryOnGrid.placedPieces.append(placed)
        }
        
        // Hanya tambahkan bobot jika barang ini baru di-scan (belum dihitung sebelumnya)
        if !item.isAlreadyCountedInWeight {
            recordItemPlacement(piece: item.piece, weight: item.weight, isSuitcase: luggage == .suitcase)
        }
        
        stagedItems.remove(at: index)
        if stagedItems.isEmpty {
            stagingWeight = nil
            snapshotSuitcaseGrid = nil
            snapshotCarryOnGrid = nil
        }
        return true
    }
    
    /// Membatalkan barang yang belum dipasang & memulihkan barang koper yang sedang dikeluarkan ke staging
    func cancelUnplacedStagingAndRestoreGrid() {
        if let savedSuitcase = snapshotSuitcaseGrid {
            suitcaseGrid = savedSuitcase
        }
        if let savedCarryOn = snapshotCarryOnGrid {
            carryOnGrid = savedCarryOn
        }
        stagedItems.removeAll()
        stagingWeight = nil
        snapshotSuitcaseGrid = nil
        snapshotCarryOnGrid = nil
    }
    
    /// Commit kondisi koper saat semua staging sudah masuk
    func commitGridSession() {
        snapshotSuitcaseGrid = nil
        snapshotCarryOnGrid = nil
    }
    
    /// Menaruh kepingan pertama dari staging ke koper tujuan (kompatibilitas)
    @discardableResult
    func placeStagingPiece(
        at origin: GridCoordinate,
        rotation: LuggageRotation,
        into luggage: LuggageType
    ) -> Bool {
        guard let first = stagedItems.first else { return false }
        stagedItems[0].rotation = rotation
        return placeStagedItem(id: first.id, at: origin, into: luggage)
    }
    
    /// Menggeser/menata ulang kepingan yang sudah ada di dalam koper yang sama
    @discardableResult
    func movePlacedPiece(
        _ placedPiece: PlacedPiece,
        to newOrigin: GridCoordinate,
        rotation: LuggageRotation? = nil
    ) -> Bool {
        let targetRotation = rotation ?? placedPiece.rotation
        let targetGrid = (placedPiece.assignedLuggage == .suitcase) ? suitcaseGrid : carryOnGrid
        
        guard LuggagePlacementEngine.canPlace(
            piece: placedPiece.piece,
            at: newOrigin,
            rotation: targetRotation,
            in: targetGrid,
            ignoringPieceId: placedPiece.id
        ) else {
            return false
        }
        
        if placedPiece.assignedLuggage == .suitcase {
            if let index = suitcaseGrid.placedPieces.firstIndex(where: { $0.id == placedPiece.id }) {
                suitcaseGrid.placedPieces[index].origin = newOrigin
                suitcaseGrid.placedPieces[index].rotation = targetRotation
            }
        } else {
            if let index = carryOnGrid.placedPieces.firstIndex(where: { $0.id == placedPiece.id }) {
                carryOnGrid.placedPieces[index].origin = newOrigin
                carryOnGrid.placedPieces[index].rotation = targetRotation
            }
        }
        
        return true
    }
    
    /// Memutar kepingan di dalam koper (melompati sudut yang mentok & wall-kick)
    @discardableResult
    func rotatePlacedPiece(_ placedPiece: PlacedPiece) -> Bool {
        let targetGrid = (placedPiece.assignedLuggage == .suitcase) ? suitcaseGrid : carryOnGrid
        guard let result = LuggagePlacementEngine.findNextValidRotation(for: placedPiece, in: targetGrid) else {
            return false
        }
        return movePlacedPiece(placedPiece, to: result.origin, rotation: result.rotation)
    }
}
