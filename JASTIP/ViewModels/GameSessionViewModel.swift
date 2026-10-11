//
//  GameSessionViewModel.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI
import Observation

@Observable
final class GameSessionViewModel {
    // MARK: - State Properties
    let airlineCard: AirlineCardModel
    var currentHour: Int = 8
    var delayHours: Int = 0
    var currentEvent: RandomEventModel? = nil
    var isGameOver: Bool = false

    // MARK: - Private State Tracking
    private var availableEvents: [RandomEventType] = RandomEventType.allCases
    private var eventCount: Int = 0
    private var lastEventHour: Int? = nil

    // MARK: - Initializer
    init(airlineCard: AirlineCardModel = AirlineCardCatalog.dummy) {
        self.airlineCard = airlineCard
    }

    // MARK: - Computed Presentation Properties
    var currentTimeString: String {
        String(format: "%02d:00", currentHour)
    }

    var boardingHour: Int {
        let clean = airlineCard.departureTime.replacingOccurrences(of: ".", with: ":")
        let hourStr = clean.split(separator: ":").first ?? "15"
        return (Int(hourStr) ?? 15) + delayHours
    }

    var displayedAirlineCard: AirlineCardModel {
        if delayHours == 0 {
            return airlineCard
        } else {
            return AirlineCardModel(
                id: airlineCard.id,
                airlineName: airlineCard.airlineName,
                maxCapacityKg: airlineCard.maxCapacityKg,
                maxCarryOnKg: airlineCard.maxCarryOnKg,
                departureTime: String(format: "%02d:00", boardingHour)
            )
        }
    }

    // MARK: - Business Logic Methods
    func nextHour() {
        if currentHour >= boardingHour {
            isGameOver = true
        } else {
            currentHour += 1
            checkForRandomEvent()
        }
    }

    func dismissEvent() {
        currentEvent = nil
    }

    private func checkForRandomEvent() {
        // 1. Maksimal 2 event per game
        guard eventCount < 2 else { return }

        // 2. Tidak boleh di 2 ronde terakhir
        guard currentHour <= (boardingHour - 2) else { return }

        // 3. Cooldown: Tidak boleh 2 jam berturut-turut kena event
        if let last = lastEventHour, currentHour <= (last + 1) {
            return
        }

        // 4. Kocok RNG 30%
        let roll = Int.random(in: 1...100)
        guard roll <= 30 else { return }

        // 5. Ambil event dari katalog
        if let event = RandomEventCatalog.getRandomEvent(from: availableEvents) {
            currentEvent = event
            availableEvents.removeAll { $0 == event.type }
            eventCount += 1
            lastEventHour = currentHour

            // Efek khusus Flight Delay: Tambah boarding +1 jam
            if event.type == .flightDelay {
                delayHours += 1
            }
        }
    }
}
