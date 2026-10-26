//
//  RoomCodeCard.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

struct RoomCodeCard: View {
    var code: String = "DIPFTR"
    
    private var characters: [Character] {
        Array(code.uppercased())
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background Card
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TileDivider"))
                .frame(height: 120)
            
            // Asterisk
            Image("AsteriskYellow")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.white.opacity(0.06))
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: 24, y: 55)
            
            // Content
            VStack(spacing: 12) {
                Text("Room Code")
                    .font(.plusJakarta(15, .bold))
                    .foregroundStyle(Color("TaxiYellow"))
                
                HStack(spacing: 6) {
                    ForEach(Array(characters.enumerated()), id: \.offset) { _, char in
                        FlipTile(
                            character: char,
                            width: 36,
                            height: 52,
                            fontSize: 30
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview() {
    RoomCodeCard(code: "ABCD")
        .padding()
}
