//
//  GameSession.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI




@Observable
class GameSessionViewModel {
    var pieceWeights: [String: Int] = [:]
    var revealedPieces: [RevealedPiece] = []
    
    init() {
        generateRandomizedWeights()
    }
    
    func startNewGame() {
        revealedPieces.removeAll()
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
}
