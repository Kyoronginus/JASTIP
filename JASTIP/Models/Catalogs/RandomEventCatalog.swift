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
             
        case .zeroWeight:
            return RandomEventModel(
                type: .zeroWeight,
                title: "Free Items!",
                message: "All items collected during this hour have a weight of 0 kg."
            )
             
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
            
        case .mindYourManners:
            return RandomEventModel(
                type: .mindYourManners,
                title: "Mind Your Manners!",
                message: "No one can point their finger during this round. Anyone who does can only do 1 action in the next round."
            )

        case .reverseMadness:
            return RandomEventModel(
                type: .reverseMadness,
                title: "Reverse Madness!",
                message: "For this round, you may only interact with physical components using their non-dominant hand. If you violate this rule, you can only do 1 action in the next round."
            )

        case .customsIssue:
            return RandomEventModel(
                type: .customsIssue,
                title: "Customs Issue!",
                message: "For this round, each player may perform only 1 action instead of 2."
            )
        }
    }

    // Logic pemilihan event berbobot (contoh proporsi baru: Stores Closed 30%, Flight Delay 25%, Zero Weight 20%, Relative Canceled 10%, Reshuffle Store 15%)
    static func getRandomEvent(from availableEvents: [RandomEventType]) -> RandomEventModel? {
        guard !availableEvents.isEmpty else { return nil }

        func weight(for type: RandomEventType) -> Int {
            switch type {
            case .storesClosed:
                return 18
            case .flightDelay:
                return 8
            case .zeroWeight:
                return 12
            case .relativeCanceled:
                return 5
            case .reshuffleStore:
                return 10
            case .mindYourManners:
                return 17
            case .reverseMadness:
                return 15
            case .customsIssue:
                return 15
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
