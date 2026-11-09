//
//  PieceModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import Foundation
import SwiftUI

enum PieceShape: String, Codable, Equatable {
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

enum PieceColor: String, CaseIterable, Codable, Equatable {
    case purple = "Purple"
    case orange = "Orange"
    case blue = "Blue"
    case green = "Green"
    case red = "Red"
    
    var displayColor: Color {
        switch self {
        case .purple: return .purple
        case .orange: return .orange
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        }
    }
    
    var categoryName: String {
        switch self {
        case .purple: return "Wellness"
        case .orange: return "Delicacy"
        case .blue: return "Boutique"
        case .green: return "Antique"
        case .red: return "Toys"
        }
    }
}

struct PieceModel: Codable, Identifiable, Equatable {
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

struct RevealedPiece: Codable, Identifiable, Equatable {
    let piece: PieceModel
    let weight: Int
    var scannedBy: String = ""
    
    var id: String { piece.id }
    
    var displayText: String {
        "\(piece.color.rawValue)-\(piece.shape.rawValue) = \(weight) kg"
    }
}


