//
//  EventCard.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 24/10/26.
//

import SwiftUI

struct EventCard: View {
    let event: RandomEventModel
    var isFaceUp: Bool = true
    var width: CGFloat = 270
    var height: CGFloat = 393
    
    var body: some View {
        Group {
            if isFaceUp {
                cardFront
            } else {
                cardBack
            }
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Front Side
    private var cardFront: some View {
        Group {
            if let imageName = event.resolvedImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("NavyBlack"))
            }
        }
    }
    
    // MARK: - Back Side
    private var cardBack: some View {
        Image("CardBack")
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview("Card Back") {
    EventCard(
        event: RandomEventCatalog.createEvent(for: .flightDelay),
        isFaceUp: false
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("Flight Delayed (Front)") {
    EventCard(
        event: RandomEventCatalog.createEvent(for: .flightDelay),
        isFaceUp: true
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("Stores Closed (Front)") {
    EventCard(
        event: RandomEventCatalog.createEvent(for: .storesClosed),
        isFaceUp: true
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("Free Items") {
    EventCard(
        event: RandomEventCatalog.createEvent(for: .zeroWeight),
        isFaceUp: true
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}
