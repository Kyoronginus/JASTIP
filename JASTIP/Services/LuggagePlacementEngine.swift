//
//  LuggagePlacementEngine.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

import Foundation

struct LuggagePlacementEngine {
    
    // MARK: - Geometric Transformation
    /// Memutar koordinat relatif sebesar rotasi tertentu searah jarum jam dan menormalisasi ke origin (0, 0)
    static func rotate(
        coordinates: [GridCoordinate],
        by rotation: LuggageRotation
    ) -> [GridCoordinate] {
        guard rotation != .deg0 else { return coordinates }
        
        let steps = rotation.rawValue / 90
        var current = coordinates
        
        for _ in 0..<steps {
            // Rumus rotasi 90 derajat searah jarum jam pada screen coordinates (Y ke bawah): (x, y) -> (-y, x)
            current = current.map { GridCoordinate(x: -$0.y, y: $0.x) }
            
            // Normalisasi agar bounding box pojok kiri-atas selalu mulai dari (0, 0)
            let minX = current.map(\.x).min() ?? 0
            let minY = current.map(\.y).min() ?? 0
            current = current.map { GridCoordinate(x: $0.x - minX, y: $0.y - minY) }
        }
        
        return current
    }
    
    // MARK: - Absolute Coordinates Calculation
    /// Menghitung koordinat absolut di dalam koper berdasarkan origin dan rotasi
    static func absoluteCoordinates(
        for piece: PieceModel,
        at origin: GridCoordinate,
        rotation: LuggageRotation
    ) -> [GridCoordinate] {
        let base = PieceCatalog.baseCoordinates(for: piece.shape, pieceId: piece.id)
        let rotated = rotate(coordinates: base, by: rotation)
        return rotated.map { GridCoordinate(x: origin.x + $0.x, y: origin.y + $0.y) }
    }
    
    /// Mengambil seluruh koordinat sel yang sudah terisi di dalam koper
    static func occupiedCoordinates(
        in grid: LuggageGridModel,
        excludingPieceId: UUID? = nil
    ) -> Set<GridCoordinate> {
        var occupied = Set<GridCoordinate>()
        for placed in grid.placedPieces {
            if let excludingId = excludingPieceId, placed.id == excludingId {
                continue // Lewati kepingan yang sedang dipindahkan
            }
            let coords = absoluteCoordinates(for: placed.piece, at: placed.origin, rotation: placed.rotation)
            occupied.formUnion(coords)
        }
        return occupied
    }
    
    // MARK: - Placement Validation
    /// Validasi apakah kepingan muat di dalam koper pada origin dan rotasi yang dituju
    static func canPlace(
        piece: PieceModel,
        at origin: GridCoordinate,
        rotation: LuggageRotation,
        in grid: LuggageGridModel,
        ignoringPieceId: UUID? = nil
    ) -> Bool {
        let targetCoords = absoluteCoordinates(for: piece, at: origin, rotation: rotation)
        let occupied = occupiedCoordinates(in: grid, excludingPieceId: ignoringPieceId)
        
        for coord in targetCoords {
            // 1. Boundary Check: Harus di dalam batas koper (width x height)
            guard coord.x >= 0 && coord.x < grid.width &&
                  coord.y >= 0 && coord.y < grid.height else {
                return false
            }
            
            // 2. Collision Check: Tidak boleh menimpa kepingan yang sudah ada
            if occupied.contains(coord) {
                return false
            }
        }
        
        return true
    }
    
    /// Cek apakah kepingan yang sudah terpasang bisa diputar di koper (termasuk wall-kick jika di tepi)
    static func findRotatedOrigin(
        for placedPiece: PlacedPiece,
        in grid: LuggageGridModel
    ) -> GridCoordinate? {
        let nextRotation = placedPiece.rotation.next
        let kickOffsets: [(Int, Int)] = [
            (0, 0),
            (-1, 0), (0, -1), (1, 0), (0, 1),
            (-1, -1), (1, -1), (-1, 1), (1, 1),
            (-2, 0), (0, -2), (2, 0), (0, 2)
        ]
        
        for (dx, dy) in kickOffsets {
            let candidate = GridCoordinate(x: placedPiece.origin.x + dx, y: placedPiece.origin.y + dy)
            if canPlace(
                piece: placedPiece.piece,
                at: candidate,
                rotation: nextRotation,
                in: grid,
                ignoringPieceId: placedPiece.id
            ) {
                return candidate
            }
        }
        return nil
    }
    
    static func canRotate(
        placedPiece: PlacedPiece,
        in grid: LuggageGridModel
    ) -> Bool {
        findRotatedOrigin(for: placedPiece, in: grid) != nil
    }
    
    /// Cek apakah kepingan bisa ditaruh di posisi & rotasi manapun pada kondisi grid saat ini
    static func canPlaceAnywhere(
        piece: PieceModel,
        in grid: LuggageGridModel,
        ignoringPieceId: UUID? = nil
    ) -> Bool {
        for rotation in LuggageRotation.allCases {
            for y in 0..<grid.height {
                for x in 0..<grid.width {
                    let origin = GridCoordinate(x: x, y: y)
                    if canPlace(
                        piece: piece,
                        at: origin,
                        rotation: rotation,
                        in: grid,
                        ignoringPieceId: ignoringPieceId
                    ) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // MARK: - Scanner Fit Check
    /// Cek apakah kepingan muat di koper target (baik langsung maupun dengan menata ulang isi koper)
    static func canFit(
        piece: PieceModel,
        in grid: LuggageGridModel
    ) -> Bool {
        // 1. Cek jumlah sel kosong
        let occupiedCount = occupiedCoordinates(in: grid).count
        let remainingCells = grid.totalCells - occupiedCount
        guard remainingCells >= piece.gridCount else { return false }
        
        // 2. Cek apakah secara dimensi muat di koper kosong (misal 1x3 tidak akan pernah muat di Carry-On 2x2)
        let emptyGrid = LuggageGridModel(type: grid.type, width: grid.width, height: grid.height, placedPieces: [])
        guard canPlaceAnywhere(piece: piece, in: emptyGrid) else { return false }
        
        // 3. Fast-path: langsung muat tanpa perlu geser barang lain
        if canPlaceAnywhere(piece: piece, in: grid) {
            return true
        }
        
        // 4. Cek apakah muat jika barang-barang yang sudah ada di koper ditata ulang
        var allPieces = grid.placedPieces.map(\.piece)
        allPieces.append(piece)
        allPieces.sort { $0.gridCount > $1.gridCount }
        
        return canPackAll(pieces: allPieces, index: 0, occupied: [], width: grid.width, height: grid.height)
    }
    
    private static func canPackAll(
        pieces: [PieceModel],
        index: Int,
        occupied: Set<GridCoordinate>,
        width: Int,
        height: Int
    ) -> Bool {
        if index >= pieces.count {
            return true
        }
        
        let currentPiece = pieces[index]
        let base = PieceCatalog.baseCoordinates(for: currentPiece.shape, pieceId: currentPiece.id)
        
        // Deduplikasi bentuk rotasi yang simetris agar pencarian cepat
        var uniqueRotations: [[GridCoordinate]] = []
        for rotation in LuggageRotation.allCases {
            let rotated = rotate(coordinates: base, by: rotation).sorted {
                $0.y == $1.y ? $0.x < $1.x : $0.y < $1.y
            }
            if !uniqueRotations.contains(rotated) {
                uniqueRotations.append(rotated)
            }
        }
        
        for shapeCoords in uniqueRotations {
            let maxX = shapeCoords.map(\.x).max() ?? 0
            let maxY = shapeCoords.map(\.y).max() ?? 0
            
            guard maxX < width && maxY < height else { continue }
            
            for y in 0..<(height - maxY) {
                for x in 0..<(width - maxX) {
                    let absCoords = shapeCoords.map { GridCoordinate(x: x + $0.x, y: y + $0.y) }
                    if absCoords.allSatisfy({ !occupied.contains($0) }) {
                        var nextOccupied = occupied
                        nextOccupied.formUnion(absCoords)
                        if canPackAll(
                            pieces: pieces,
                            index: index + 1,
                            occupied: nextOccupied,
                            width: width,
                            height: height
                        ) {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    /// Cek apakah masih ada ruang yang memungkinkan di salah satu koper
    static func canScan(
        piece: PieceModel,
        suitcase: LuggageGridModel,
        carryOn: LuggageGridModel
    ) -> Bool {
        canFit(piece: piece, in: suitcase) || canFit(piece: piece, in: carryOn)
    }
}
