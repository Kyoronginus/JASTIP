//
//  GridCoordinateModel.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

import Foundation

struct GridCoordinate: Hashable, Codable, Equatable {
    var x: Int
    var y: Int
}

enum LuggageRotation: Int, CaseIterable, Codable {
    case deg0 = 0
    case deg90 = 90
    case deg180 = 180
    case deg270 = 270
    var next: LuggageRotation {
        switch self {
        case .deg0: return .deg90
        case .deg90: return .deg180
        case .deg180: return .deg270
        case .deg270: return .deg0
        }
    }
}
