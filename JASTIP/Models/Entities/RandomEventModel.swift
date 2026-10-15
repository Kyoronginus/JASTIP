//
//  GameEventType.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

// Random Events
enum RandomEventType: String, CaseIterable {
    case flightDelay
//    case zeroWeight
    case relativeCanceled
    case storesClosed
    case reshuffleStore
}

struct RandomEventModel: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var type: RandomEventType = .storesClosed
    let title: String
    let message: String
}
