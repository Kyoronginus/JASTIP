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
            if let imageName = event.type.imageName,
               UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                proceduralCardFront
            }
        }
    }
    
    // Procedural Fallback Card (e.g. Free Items / zeroWeight)
    private var proceduralCardFront: some View {
        VStack(spacing: 0) {
            // Ivory illustration section
            ZStack {
                Color(red: 247/255, green: 244/255, blue: 235/255)
                
                VStack(spacing: 10) {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color("TaxiYellow"))
                    
                    Text("0 KG")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color("NavyBlack"))
                }
            }
            .frame(height: height * 0.496)
            
            // Bottom banner section
            ZStack {
                Color("TaxiYellow")
                
                VStack(spacing: 10) {
                    Text(event.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("NavyBlack"))
                        .multilineTextAlignment(.center)
                    
                    Text(event.message)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("NavyBlack").opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
            .frame(maxHeight: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Back Side
    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("NavyBlack"))
            
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color("TaxiYellow"), lineWidth: 2.5)
                .padding(10)
            
            // Corner asterisks
            VStack {
                HStack {
                    Image("AsteriskYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .opacity(0.85)
                    Spacer()
                    Image("AsteriskYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .opacity(0.85)
                }
                Spacer()
                HStack {
                    Image("AsteriskYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .opacity(0.85)
                    Spacer()
                    Image("AsteriskYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .opacity(0.85)
                }
            }
            .padding(22)
            
            // Center JASTIP logo & label
            VStack(spacing: 12) {
                Image("JASTIP")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                
                Text("EVENT CARD")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2.5)
                    .foregroundStyle(Color("TaxiYellow"))
            }
        }
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

#Preview("Free Items (Procedural)") {
    EventCard(
        event: RandomEventCatalog.createEvent(for: .zeroWeight),
        isFaceUp: true
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}
