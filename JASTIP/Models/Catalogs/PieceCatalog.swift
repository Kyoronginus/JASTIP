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
        PieceModel(id: "JASTIP1-1", color: .red, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP2-1", color: .yellow, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP3-1", color: .green, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP4-1", color: .blue, gridCount: 1, isAnomaly: false),
        PieceModel(id: "JASTIP5-1", color: .pink, gridCount: 1, isAnomaly: false),
        
        // xx
        PieceModel(id: "JASTIP1-2", color: .red, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP2-2", color: .yellow, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP3-2", color: .green, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP4-2", color: .blue, gridCount: 2, isAnomaly: false),
        PieceModel(id: "JASTIP5-2", color: .pink, gridCount: 2, isAnomaly: false),
        
        // x
        // xx
        PieceModel(id: "JASTIP1-3", color: .red, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP2-3", color: .yellow, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP3-3", color: .green, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP4-3", color: .blue, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP5-3", color: .pink, gridCount: 3, isAnomaly: false),
        
        // xxx
        PieceModel(id: "JASTIP1-4", color: .red, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP2-4", color: .yellow, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP3-4", color: .green, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP4-4", color: .blue, gridCount: 3, isAnomaly: false),
        PieceModel(id: "JASTIP5-4", color: .pink, gridCount: 3, isAnomaly: false),
        
        // x
        // xxx
        PieceModel(id: "JASTIP1-5", color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-5", color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-5", color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-5", color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-5", color: .pink, gridCount: 4, isAnomaly: false),
        
        //  x
        // xxx
        PieceModel(id: "JASTIP1-6", color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-6", color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-6", color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-6", color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-6", color: .pink, gridCount: 4, isAnomaly: false),
        
        // xxxx
        PieceModel(id: "JASTIP1-7", color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-7", color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-7", color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-7", color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-7", color: .pink, gridCount: 4, isAnomaly: false),
        
        // xx
        // xx
        PieceModel(id: "JASTIP1-8", color: .red, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP2-8", color: .yellow, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP3-8", color: .green, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP4-8", color: .blue, gridCount: 4, isAnomaly: false),
        PieceModel(id: "JASTIP5-8", color: .pink, gridCount: 4, isAnomaly: false),
        
        // unique pieces
        // lupa, ntar ditambah
        
        PieceModel(id: "JASTIP1-9", color: .red, gridCount: 4, isAnomaly: true),
        
        // x x
        // xxx
        PieceModel(id: "JASTIP2-9", color: .yellow, gridCount: 5, isAnomaly: true),
    
        PieceModel(id: "JASTIP3-9", color: .green, gridCount: 4, isAnomaly: true),
        
        // xx
        // xxxx
        // xx
        PieceModel(id: "JASTIP4-9", color: .blue, gridCount: 8, isAnomaly: true),
        
        // xxxx
        //  x x
        PieceModel(id: "JASTIP5-9", color: .pink, gridCount: 6, isAnomaly: true),
    ]
    
    static func findPiece(by id: String) -> PieceModel? {
        allPieces.first { $0.id == id }
    }
}
