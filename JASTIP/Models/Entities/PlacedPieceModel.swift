//
//  PlacedPiece.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

import Foundation

struct PlacedPiece: Identifiable, Codable, Equatable {
    let id: UUID
    let piece: PieceModel
    var origin: GridCoordinate        // Posisi jangkar (kiri-atas) pada grid
    var rotation: LuggageRotation       // Derajat rotasi saat ini
    let assignedLuggage: LuggageType    // Kunci koper: .suitcase atau .carryOn (tidak bisa dipindah)
}

