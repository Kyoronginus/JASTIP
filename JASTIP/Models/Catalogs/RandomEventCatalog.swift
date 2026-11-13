//
//  RandomEventCatalog.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 11/10/26.
//

import Foundation

enum RandomEventCatalog {
    // 5 Toko di board game fisik
    static let allStores = ["Wellness", "Local Delicacy", "Boutique", "Antique", "Toys"]
    
    // 5 Kombinasi Asset Restock Store
    static let restockStoreVariants: [(store: String, assetName: String)] = [
        ("Antique", "RestockStore-Antique"),
        ("Boutique", "RestockStore-Boutique"),
        ("Local Delicacy", "RestockStore-LocalDelicacy"),
        ("Toys", "RestockStore-Toys"),
        ("Wellness", "RestockStore-Wellness")
    ]
    
    // 10 Kombinasi Asset Stores Closed
    static let storesClosedVariants: [(stores: String, assetName: String)] = [
        ("Boutique & Delicacy", "RandomEvent-BoutiqueDelicacy"),
        ("Antique & Delicacy", "StoresClosed-AntiqueDelicacy"),
        ("Antique & Wellness", "StoresClosed-AntiqueWellness"),
        ("Boutique & Antique", "StoresClosed-Boutique"),
        ("Delicacy & Toys", "StoresClosed-DelicacyToys"),
        ("Delicacy & Wellness", "StoresClosed-DelicacyWellness"),
        ("Toys & Antique", "StoresClosed-ToysAntique"),
        ("Toys & Boutique", "StoresClosed-ToysBoutique"),
        ("Wellness & Boutique", "StoresClosed-Wellness&Boutique"),
        ("Wellness & Toys", "StoresClosed-WellnessToys")
    ]

    // Generator event sesuai tipenya
    static func createEvent(for type: RandomEventType) -> RandomEventModel {
        switch type {
        case .customsIssue:
            return RandomEventModel(type: .customsIssue, imageName: "CustomsIssue") // action 2 jadi 1
            
        case .energyBoost:
            return RandomEventModel(type: .energyBoost, imageName: "EnergyBoost") // action + 1
            
        case .mindYourManners:
            return RandomEventModel(type: .mindYourManners, imageName: "Etiquette") // no pointing
            
        case .evacuation:
            return RandomEventModel(type: .evacuation, imageName: "Evacuation") // must move meeple
            
        case .flightDelay:
            return RandomEventModel(type: .flightDelay, imageName: "FlightDelayed") // delay 1 day
             
        case .zeroWeight:
            return RandomEventModel(type: .zeroWeight, imageName: "FreeItems") // zero weigt during scan
             
        case .relativeCanceled:
            return RandomEventModel(type: .relativeCanceled, imageName: "OrderCancelled") // cancel 1 order
             
        case .reshuffleStore:
            let selected = restockStoreVariants.randomElement() ?? ("Wellness", "RestockStore-Wellness") // reshuffle store random, default Wellness
            return RandomEventModel(type: .reshuffleStore, imageName: selected.assetName)
            
        case .reverseMadness:
            return RandomEventModel(type: .reverseMadness, imageName: "ReverseMadness") // reverse dominant hand
            
        case .silentAirport:
            return RandomEventModel(type: .silentAirport, imageName: "SilentAirport") // silent no speaking
             
        case .storesClosed:
            let selected = storesClosedVariants.randomElement() ?? ("Boutique & Antique", "StoresClosed-Boutique") // stores closed random, default Boutique & Antique
            return RandomEventModel(type: .storesClosed, imageName: selected.assetName)
        }
    }

    // Logic pemilihan event berbobot
    static func getRandomEvent(from availableEvents: [RandomEventType]) -> RandomEventModel? {
        guard !availableEvents.isEmpty else { return nil }

        func weight(for type: RandomEventType) -> Int {
            switch type {
            case .storesClosed:
                return 16
            case .reshuffleStore:
                return 10
            case .customsIssue:
                return 10
            case .energyBoost:
                return 10
            case .mindYourManners:
                return 8
            case .evacuation:
                return 8
            case .reverseMadness:
                return 8
            case .silentAirport:
                return 8
            case .zeroWeight:
                return 8
            case .flightDelay:
                return 24
            case .relativeCanceled:
                return 8
            }
        }

        let totalWeight = availableEvents.reduce(0) { $0 + weight(for: $1) }
        var randomValue = Int.random(in: 1...totalWeight)

        for type in availableEvents {
            randomValue -= weight(for: type)
            if randomValue <= 0 {
                return createEvent(for: type)
            }
        }

        return createEvent(for: availableEvents[0])
    }
}
