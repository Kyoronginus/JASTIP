//
//  GameSessionViewModel+Events.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 22/10/26.
//

import Foundation

extension GameSessionViewModel {
    
    // MARK: - Event Computed Properties
    var isZeroWeightHour: Bool {
        activeHourEvent?.type == .zeroWeight
    }
    
    // MARK: - Business Logic Methods
    func nextHour() {
        if currentHour > boardingHour {
            isGameOver = true
            return
        }
        
        currentHour += 1
        
        let event = rollForRandomEvent()
            lastRoundEventType = event?.type
        currentEvent = event
        activeHourEvent = event
        
        if event?.type == .flightDelay {
            delayHours += 1
        }
        
        let gameOverStatus = currentHour >= boardingHour
        self.isGameOver = gameOverStatus
        
        // kirim payload ke pemain lain
        let payload = NextHourPayload(
            newHour: currentHour, delayHour: delayHours, event: event, isGameOver: gameOverStatus
        )
        networkManager.sendNextHourTrigger(payload: payload)
    }
    
    func dismissEvent() {
        currentEvent = nil
    }
    
    // MARK: - Random Event Generation
    func rollForRandomEvent() -> RandomEventModel? {
        let roll = Int.random(in: 1...100)
        guard roll <= 40 else { return nil }

        let nonConsecutiveEvents: Set<RandomEventType> = [
            .zeroWeight,
            .mindYourManners,
            .reverseMadness
        ]

        let availableTypes = RandomEventType.allCases.filter { type in
            if type == .flightDelay || type == .relativeCanceled {
                guard !triggeredUniqueEvents.contains(type) else {
                    return false
                }
            }

            if nonConsecutiveEvents.contains(type), lastRoundEventType == type {
                return false
            }

            return true
        }

        guard let event = RandomEventCatalog.getRandomEvent(from: availableTypes) else {
            return nil
        }

        if event.type == .flightDelay || event.type == .relativeCanceled {
            triggeredUniqueEvents.insert(event.type)
        }

        return event
    }
    
    
}
