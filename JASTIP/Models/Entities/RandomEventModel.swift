//
//  GameEventType.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

// Random Events
enum RandomEventType: String, CaseIterable, Codable {
    case flightDelay
    case zeroWeight
    case relativeCanceled
    case storesClosed
    case reshuffleStore
    case mindYourManners
    case reverseMadness
    case customsIssue
    
    var imageName: String? {
        switch self {
        case .flightDelay: return "FlightDelayed"
        case .relativeCanceled: return "OrderCancelled"
        case .storesClosed: return "StoresClosed"
        case .reshuffleStore: return "RestockStore"
        case .mindYourManners: return "MindYourManners"
        case .reverseMadness: return "ReverseMadness"
        case .customsIssue: return "CustomsIssue"
        case .zeroWeight: return nil
        }
    }
}

struct RandomEventModel: Identifiable, Equatable, Codable {
    var id: String = UUID().uuidString
    var type: RandomEventType = .storesClosed
    let title: String
    let message: String
}

struct NextHourPayload: Codable {
    let newHour: Int
    let delayHour: Int
    let event: RandomEventModel?
    let isGameOver: Bool
}
