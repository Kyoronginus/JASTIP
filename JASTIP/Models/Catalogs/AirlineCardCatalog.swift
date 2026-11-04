//
//  AirlineCardCatalog.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/11/26.
//

import Foundation

enum AirlineCardCatalog {
    static let allCards: [AirlineCardModel] = [
        AirlineCardModel(
            airlineName: "Honu Air",
            maxCapacityKg: 17,
            maxCarryOnKg: 5,
            departureTime: "14:00"
        ),
        AirlineCardModel(
            airlineName: "Sakura Airlines",
            maxCapacityKg: 17,
            maxCarryOnKg: 6,
            departureTime: "15:00"
        ),
        AirlineCardModel(
            airlineName: "Garuda Sky",
            maxCapacityKg: 18,
            maxCarryOnKg: 6,
            departureTime: "15:00"
        ),
        AirlineCardModel(
            airlineName: "Pacific Wings",
            maxCapacityKg: 16,
            maxCarryOnKg: 5,
            departureTime: "15:00"
        ),
        AirlineCardModel(
            airlineName: "Nusantara Jet",
            maxCapacityKg: 18,
            maxCarryOnKg: 5,
            departureTime: "15:00"
        ),
        AirlineCardModel(
            airlineName: "Fuji Express",
            maxCapacityKg: 21,
            maxCarryOnKg: 6,
            departureTime: "16:00"
        ),
        AirlineCardModel(
            airlineName: "Seoul Airways",
            maxCapacityKg: 18,
            maxCarryOnKg: 7,
            departureTime: "16:00"
        ),
        AirlineCardModel(
            airlineName: "Merpati Sky",
            maxCapacityKg: 19,
            maxCarryOnKg: 6,
            departureTime: "15:00"
        ),
        AirlineCardModel(
            airlineName: "Horizon Air",
            maxCapacityKg: 19,
            maxCarryOnKg: 7,
            departureTime: "16:00"
        ),
        AirlineCardModel(
            airlineName: "Singapore Flyer",
            maxCapacityKg: 20,
            maxCarryOnKg: 6,
            departureTime: "16:00"
        ),
        AirlineCardModel(
            airlineName: "Pelican Express",
            maxCapacityKg: 20,
            maxCarryOnKg: 7,
            departureTime: "17:00"
        ),
        AirlineCardModel(
            airlineName: "Batavia Air",
            maxCapacityKg: 16,
            maxCarryOnKg: 6,
            departureTime: "14:00"
        ),
        AirlineCardModel(
            airlineName: "Kiwi Jet",
            maxCapacityKg: 16,
            maxCarryOnKg: 6,
            departureTime: "15:00"
        ),
        AirlineCardModel(
            airlineName: "Maple Wings",
            maxCapacityKg: 15,
            maxCarryOnKg: 6,
            departureTime: "14:00"
        ),
        AirlineCardModel(
            airlineName: "Sunrise Air",
            maxCapacityKg: 15,
            maxCarryOnKg: 5,
            departureTime: "13:00"
        ),
        AirlineCardModel(
            airlineName: "Nomad Jet",
            maxCapacityKg: 15,
            maxCarryOnKg: 5,
            departureTime: "12:00"
        ),
        AirlineCardModel(
            airlineName: "Stellar Airways",
            maxCapacityKg: 22,
            maxCarryOnKg: 6,
            departureTime: "16:00"
        ),
        AirlineCardModel(
            airlineName: "Sky Voyager",
            maxCapacityKg: 22,
            maxCarryOnKg: 5,
            departureTime: "15:00"
        )
    ]

    static var dummy: AirlineCardModel {
        allCards[0]
    }

    static func getRandomCard() -> AirlineCardModel {
        allCards.randomElement() ?? dummy
    }
}
