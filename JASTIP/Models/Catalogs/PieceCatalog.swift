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
        PieceModel(id: "JASTIP2-1", shape: .single, color: .yellow, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP3-1", shape: .single, color: .green, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP4-1", shape: .single, color: .blue, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP5-1", shape: .single, color: .pink, gridCount: 1, isAnomaly: false),
        
        // xx
        PieceModel(id: "JASTIP1-2", shape: .domino, color: .red, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP2-2", shape: .domino, color: .yellow, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP3-2", shape: .domino, color: .green, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP4-2", shape: .domino, color: .blue, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP5-2", shape: .domino, color: .pink, gridCount: 2, isAnomaly: false),
        
        // x
        // xx
        PieceModel(id: "JASTIP1-3", shape: .smallL, color: .red, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP2-3", shape: .smallL, color: .yellow, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP3-3", shape: .smallL, color: .green, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP4-3", shape: .smallL, color: .blue, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP5-3", shape: .smallL, color: .pink, gridCount: 3, isAnomaly: false),
        
        // xxx
        PieceModel(id: "JASTIP1-4", shape: .triominoI, color: .red, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP2-4", shape: .triominoI, color: .yellow, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP3-4", shape: .triominoI, color: .green, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP4-4", shape: .triominoI, color: .blue, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP5-4", shape: .triominoI, color: .pink, gridCount: 3, isAnomaly: false),
        
        // x
        // xxx
        PieceModel(id: "JASTIP1-5", shape: .tetrominoL, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-5", shape: .tetrominoL, color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-5", shape: .tetrominoL, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-5", shape: .tetrominoL, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-5", shape: .tetrominoL, color: .pink, gridCount: 4, isAnomaly: false),
        
        //  x
        // xxx
        PieceModel(id: "JASTIP1-6", shape: .tetrominoT, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-6", shape: .tetrominoT, color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-6", shape: .tetrominoT, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-6", shape: .tetrominoT, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-6", shape: .tetrominoT, color: .pink, gridCount: 4, isAnomaly: false),
        
        // xxxx
        PieceModel(id: "JASTIP1-7", shape: .tetrominoI, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-7", shape: .tetrominoI, color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-7", shape: .tetrominoI, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-7", shape: .tetrominoI, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-7", shape: .tetrominoI, color: .pink, gridCount: 4, isAnomaly: false),
        
        // xx
        // xx
        PieceModel(id: "JASTIP1-8", shape: .square, color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-8", shape: .square, color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-8", shape: .square, color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-8", shape: .square, color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-8", shape: .square, color: .pink, gridCount: 4, isAnomaly: false),
        
        // unique pieces
        // lupa, ntar ditambah
        // xx
        //  xx
        //   x
        PieceModel(id: "JASTIP1-9", shape:.unique, color: .red, gridCount: 5, isAnomaly: true),
        
        // x x
        // xxx
        PieceModel(id: "JASTIP2-9", shape:.unique, color: .yellow, gridCount: 5, isAnomaly: true),
        
        //  x
        // xxxx
        // x
        PieceModel(id: "JASTIP3-9", shape:.unique, color: .green, gridCount: 6, isAnomaly: true),
        
        // xx
        // xxxx
        // xx
        PieceModel(id: "JASTIP4-9", shape:.unique, color: .blue, gridCount: 8, isAnomaly: true),
        
        // xxxx
        //  x x
        PieceModel(id: "JASTIP5-9", shape:.unique, color: .pink, gridCount: 6, isAnomaly: true),
    ]
    
    static func findPiece(by id: String) -> PieceModel? {
        allPieces.first { $0.id == id }
    }
}
