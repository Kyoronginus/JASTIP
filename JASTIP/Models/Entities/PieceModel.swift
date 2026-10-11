//
//  PieceModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import Foundation

enum PieceShape: String {
    case single = "Single"
    case domino = "Domino"
    case smallL = "Small L"
    case triominoI = "Triomino I"
    case tetrominoL = "Tetromino L"
    case tetrominoT = "Tetromino T"
    case tetrominoI = "Tetromino I"
    case square = "Square"
    case unique = "Unique"
}

enum PieceColor: Int {
    case red = 1
    case yellow = 2
    case green = 3
    case blue = 4
    case pink = 5
}

struct PieceModel: Identifiable {
    let id: String
    let shape: PieceShape
    let color: PieceColor
    let gridCount: Int
    let isAnomaly: Bool
}

