//
//  LuggageGridModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

struct LuggageGridModel: Codable, Equatable {
    let type: LuggageType
    let width: Int     // Suitcase = 3, Carry-On = 2
    let height: Int    // Suitcase = 5, Carry-On = 2
    var placedPieces: [PlacedPiece] = []
    
    // Preset initializer
    static var suitcase: LuggageGridModel {
        LuggageGridModel(type: .suitcase, width: 3, height: 5)
    }
    
    static var carryOn: LuggageGridModel {
        LuggageGridModel(type: .carryOn, width: 2, height: 2)
    }
    
    var totalCells: Int {
        width * height
    }
}
