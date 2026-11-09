//
//  GameEventType.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

// Random Events
enum RandomEventType: String, CaseIterable, Codable {
    case customsIssue
    case energyBoost
    case mindYourManners // Etiquette
    case evacuation
    case flightDelay
    case zeroWeight // Free Items
    case relativeCanceled // Order Cancelled
    case reshuffleStore // Restock Store
    case reverseMadness
    case silentAirport
    case storesClosed
    
    var imageName: String? {
        switch self {
        case .customsIssue: return "CustomsIssue"
        case .energyBoost: return "EnergyBoost"
        case .mindYourManners: return "Etiquette"
        case .evacuation: return "Evacuation"
        case .flightDelay: return "FlightDelayed"
        case .zeroWeight: return "FreeItems"
        case .relativeCanceled: return "OrderCancelled"
        case .reshuffleStore: return "RestockStore-Wellness"
        case .reverseMadness: return "ReverseMadness"
        case .silentAirport: return "SilentAirport"
        case .storesClosed: return "StoresClosed-Boutique"
        }
    }
}

struct RandomEventModel: Identifiable, Equatable, Codable {
    var id: String = UUID().uuidString
    var type: RandomEventType = .storesClosed
    var imageName: String? = nil
    
    var resolvedImageName: String? {
        imageName ?? type.imageName
    }
}
