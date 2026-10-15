//
//  RandomEventCatalog.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 11/10/26.
//

import Foundation

enum RandomEventCatalog {
    // 5 Toko di board game fisik
    static let allStores = ["Antique", "Delicacy", "Kids", "Books", "Fashion"]

    // Generator pesan event sesuai tipenya
    static func createEvent(for type: RandomEventType) -> RandomEventModel {
        switch type {
        case .flightDelay:
            return RandomEventModel(
                type: .flightDelay,
                title: "Flight Delayed!",
                message: "Boarding time is postponed by 1 hour. Game duration extended!"
            )
             
//        case .zeroWeight:
//            return RandomEventModel(
//                type: .zeroWeight,
//                title: "Free Items!",
//                message: "All items collected during this hour have a weight of 0 kg."
//            )
             
        case .relativeCanceled:
            return RandomEventModel(
                type: .relativeCanceled,
                title: "Relative Card Canceled!",
                message: "Shuffle the 3 Relative Cards on the physical board and draw 1 at random. That card is canceled and will no longer grant points."
            )
             
        case .storesClosed:
            // Randomize 2 stores automatically from the 5 stores
            let closedStores = allStores.shuffled().prefix(2).joined(separator: " & ")
            return RandomEventModel(
                type: .storesClosed,
                title: "Stores Closed!",
                message: "The \(closedStores) stores are closed this hour. Players cannot take items from these stores."
            )
            
        case .reshuffleStore:
            // Randomize 1 store untuk di-reshuffle
            let targetStore = allStores.randomElement() ?? "Antique"
            return RandomEventModel(
                type: .reshuffleStore,
                title: "Reshuffle Store!",
                message: "The \(targetStore) store must reshuffle its displayed pieces back into the supply and draw new ones!"
            )
        }
    }

    // Logic pemilihan event berbobot (contoh proporsi baru: Stores Closed 30%, Flight Delay 25%, Zero Weight 20%, Relative Canceled 10%, Reshuffle Store 15%)
    static func getRandomEvent(from availableEvents: [RandomEventType]) -> RandomEventModel? {
        guard !availableEvents.isEmpty else { return nil }

        func weight(for type: RandomEventType) -> Int {
            switch type {
            case .storesClosed: return 30
            case .flightDelay: return 20
//            case .zeroWeight: return 20
            case .relativeCanceled: return 10
            case .reshuffleStore: return 20
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
