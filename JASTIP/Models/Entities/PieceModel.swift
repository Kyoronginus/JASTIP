//
//  PieceModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import Foundation
import SwiftUI

enum PieceShape: String, Codable {
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

enum PieceColor: String, CaseIterable, Codable {
    case red = "Red"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case pink = "Pink"
    
    var displayColor: Color {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .pink: return .pink
        }
    }
    
    var categoryName: String {
        switch self {
            case .red: return "Books"
            case .yellow: return "Delicacy"
            case .green: return "Boutique"
            case .blue: return "Antique"
            case .pink: return "Kids"
        }
    }
}

struct PieceModel: Codable, Identifiable {
    let id: String
    let shape: PieceShape
    let color: PieceColor
    let gridCount: Int
    let isAnomaly: Bool
    var imageName: String = "" //placeholder
    
    var assetName: String {
        id.replacingOccurrences(of: "JASTIP", with: "")
    }
}

struct RevealedPiece: Codable, Identifiable {
    let piece: PieceModel
    let weight: Int
    var scannedBy: String = ""
    
    var id: String { piece.id }
    
    var displayText: String {
        "\(piece.color.rawValue)-\(piece.shape.rawValue) = \(weight) kg"
    }
}
