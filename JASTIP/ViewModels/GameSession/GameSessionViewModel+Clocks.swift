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
        guard lobbyService.lobby?.isHost == true else { return }

        if currentHour > boardingHour {
            isGameOver = true
            broadcastMyStatus()
            Task { await publishCloudGameState() }
            return
        }
        
        currentHour += 1
        
        let event = rollForRandomEvent()
        lastRoundEventType = event?.type
        currentEvent = event
        activeHourEvent = event
        
        if event?.type == .flightDelay {
            delayHours += 1
            daysToGo += 1
        }
        
        if event?.type == .relativeCanceled, !sharedJastipOrders.isEmpty {
            let canceledIndex = Int.random(in: 0..<sharedJastipOrders.count)
            sharedJastipOrders.remove(at: canceledIndex)
        }
        
        let gameOverStatus = currentHour > boardingHour
        self.isGameOver = gameOverStatus
        if gameOverStatus {
            broadcastMyStatus()
        }
        Task { await publishCloudGameState() }
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
            .reverseMadness,
            .silentAirport,
            .evacuation,
            .energyBoost,
            .customsIssue
        ]

        let availableTypes = RandomEventType.allCases.filter { type in
            if type == .flightDelay || type == .relativeCanceled {
                guard !triggeredUniqueEvents.contains(type) else {
                    return false
                }
            }
            
            if type == .relativeCanceled, sharedJastipOrders.isEmpty {
                return false
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
