//
//  PieceCatalog.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import Foundation

struct PieceCatalog {
    static let allPieces: [PieceModel] = [
        // id = JASTIP[color]-[shape]
        
        // x
        PieceModel(id: "JASTIP1-1", shape: .single, color: .red, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP2-1", shape: .single, color: .orange, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP3-1", shape: .single, color: .blue, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP4-1", shape: .single, color: .green, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP5-1", shape: .single, color: .purple, gridCount: 1, isAnomaly: false),
        
        // xx
        PieceModel(id: "JASTIP1-2", shape: .domino, color: .red, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP2-2", shape: .domino, color: .orange, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP3-2", shape: .domino, color: .blue, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP4-2", shape: .domino, color: .green, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP5-2", shape: .domino, color: .purple, gridCount: 2, isAnomaly: false),
        
        // x
        // xx
        PieceModel(id: "JASTIP1-3", shape: .smallL, color: .red, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP2-3", shape: .smallL, color: .orange, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP3-3", shape: .smallL, color: .blue, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP4-3", shape: .smallL, color: .green, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP5-3", shape: .smallL, color: .purple, gridCount: 3, isAnomaly: false),
        
        // xxx
        PieceModel(id: "JASTIP1-4", shape: .triominoI, color: .red, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP2-4", shape: .triominoI, color: .orange, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP3-4", shape: .triominoI, color: .blue, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP4-4", shape: .triominoI, color: .green, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP5-4", shape: .triominoI, color: .purple, gridCount: 3, isAnomaly: false),
        
        // x
        // xxx
        PieceModel(id: "JASTIP1-5", shape: .tetrominoL, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-5", shape: .tetrominoL, color: .orange, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-5", shape: .tetrominoL, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-5", shape: .tetrominoL, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-5", shape: .tetrominoL, color: .purple, gridCount: 4, isAnomaly: false),
        
        //  x
        // xxx
        PieceModel(id: "JASTIP1-6", shape: .tetrominoT, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-6", shape: .tetrominoT, color: .orange, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-6", shape: .tetrominoT, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-6", shape: .tetrominoT, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-6", shape: .tetrominoT, color: .purple, gridCount: 4, isAnomaly: false),
        
        // xxxx
        PieceModel(id: "JASTIP1-7", shape: .tetrominoI, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-7", shape: .tetrominoI, color: .orange, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-7", shape: .tetrominoI, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-7", shape: .tetrominoI, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-7", shape: .tetrominoI, color: .purple, gridCount: 4, isAnomaly: false),
        
        // xx
        // xx
        PieceModel(id: "JASTIP1-8", shape: .square, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-8", shape: .square, color: .orange, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-8", shape: .square, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-8", shape: .square, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-8", shape: .square, color: .purple, gridCount: 4, isAnomaly: false),
        
        // unique pieces
        // lupa, ntar ditambah
        // xx
        //  xx
        //   x
        PieceModel(id: "JASTIP5-9", shape:.unique, color: .red, gridCount: 3, isAnomaly: true),
        
        // x x
        // xxx
        PieceModel(id: "JASTIP2-9", shape:.unique, color: .orange, gridCount: 3, isAnomaly: true),
        
        //  x
        // xxxx
        // x
        PieceModel(id: "JASTIP4-9", shape:.unique, color: .blue, gridCount: 3, isAnomaly: true),
        
        // xx
        // xxxx
        // xx
        PieceModel(id: "JASTIP3-9", shape:.unique, color: .green, gridCount: 5, isAnomaly: true),
        
        // xxxx
        //  x x
        PieceModel(id: "JASTIP1-9", shape:.unique, color: .purple, gridCount: 3, isAnomaly: true),
    ]
    
    static func findPiece(by id: String) -> PieceModel? {
            allPieces.first { $0.id == id }
        }
        
        
    // MARK: - Shape Coordinates & Rotation
    static func baseCoordinates(for shape: PieceShape, pieceId: String? = nil) -> [GridCoordinate] {
        switch shape {
        case .single:
            return [GridCoordinate(x: 0, y: 0)]
        case .domino:
            return [GridCoordinate(x: 0, y: 0), GridCoordinate(x: 1, y: 0)]
        case .smallL:
            return [GridCoordinate(x: 0, y: 0), GridCoordinate(x: 0, y: 1), GridCoordinate(x: 1, y: 1)]
        case .triominoI:
            return [GridCoordinate(x: 0, y: 0), GridCoordinate(x: 1, y: 0), GridCoordinate(x: 2, y: 0)]
        case .tetrominoL:
            return [GridCoordinate(x: 0, y: 0), GridCoordinate(x: 0, y: 1), GridCoordinate(x: 1, y: 1), GridCoordinate(x: 2, y: 1)]
        case .tetrominoT:
            return [GridCoordinate(x: 1, y: 0), GridCoordinate(x: 0, y: 1), GridCoordinate(x: 1, y: 1), GridCoordinate(x: 2, y: 1)]
        case .tetrominoI:
            return [GridCoordinate(x: 0, y: 0), GridCoordinate(x: 1, y: 0), GridCoordinate(x: 2, y: 0), GridCoordinate(x: 3, y: 0)]
        case .square:
            return [GridCoordinate(x: 0, y: 0), GridCoordinate(x: 1, y: 0), GridCoordinate(x: 0, y: 1), GridCoordinate(x: 1, y: 1)]
        case .unique:
            return anomalyCoordinates(for: pieceId)
        }
    }
    
    private static func anomalyCoordinates(for pieceId: String?) -> [GridCoordinate] {
        guard let id = pieceId else { return [GridCoordinate(x: 0, y: 0)] }
        switch id {
        case "JASTIP1-9":
            return [GridCoordinate(x: 0, y: 0),
                    GridCoordinate(x: 1, y: 0),
                    GridCoordinate(x: 1, y: 1),
                    GridCoordinate(x: 2, y: 1),
                    GridCoordinate(x: 2, y: 2)]
        case "JASTIP2-9":
            return [GridCoordinate(x: 0, y: 0),
                    GridCoordinate(x: 2, y: 0),
                    GridCoordinate(x: 0, y: 1),
                    GridCoordinate(x: 1, y: 1),
                    GridCoordinate(x: 2, y: 1)]
        case "JASTIP3-9":
            return [GridCoordinate(x: 1, y: 0),
                    GridCoordinate(x: 0, y: 1),
                    GridCoordinate(x: 1, y: 1),
                    GridCoordinate(x: 2, y: 1),
                    GridCoordinate(x: 3, y: 1),
                    GridCoordinate(x: 0, y: 2)]
        case "JASTIP4-9":
            return [GridCoordinate(x: 0, y: 0),
                    GridCoordinate(x: 1, y: 0),
                    GridCoordinate(x: 0, y: 1),
                    GridCoordinate(x: 1, y: 1),
                    GridCoordinate(x: 2, y: 1),
                    GridCoordinate(x: 3, y: 1),
                    GridCoordinate(x: 0, y: 2),
                    GridCoordinate(x: 1, y: 2)]
        case "JASTIP5-9":
            return [GridCoordinate(x: 0, y: 0),
                    GridCoordinate(x: 1, y: 0),
                    GridCoordinate(x: 2, y: 0),
                    GridCoordinate(x: 3, y: 0),
                    GridCoordinate(x: 1, y: 1),
                    GridCoordinate(x: 3, y: 1)]
        default:
            return [GridCoordinate(x: 0, y: 0)]
        }
    }
}
