//
//  PlayerStatusModel.swift
//  JASTIP
//
//  Created by Feivel Qutby on 20/10/26.
//

import Foundation

struct PlayerStatusModel: Identifiable {
    let id: String
    let name: String
    let isCurrentDevice: Bool
    let suitcaseWeight: Int
    let suitcaseMax: Int
    let carryOnWeight: Int
    let carryOnMax: Int
    let isBoarded: Bool
    
    var isOverweight: Bool {
        suitcaseWeight > suitcaseMax || carryOnWeight > carryOnMax
    }
}

struct PlayerSyncPayload: Codable {
    let peerId: String
    let name: String
    let suitcaseWeight: Int
    let carryOnWeight: Int
    let isBoarded: Bool
}
