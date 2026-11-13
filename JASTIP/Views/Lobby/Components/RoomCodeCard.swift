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
        ZStack {
            // Background Card
            Image("RoomCodeTag")
                .resizable()
                .scaledToFit()
                .frame(height: 120) // <-- ATUR TINGGI TAG DI SINI. Lebarnya akan otomatis menyesuaikan (aspect ratio terjaga).
            
            // Content
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(Array(characters.enumerated()), id: \.offset) { _, char in
                        // Gua asumsikan lu ganti FlipTile jadi Text biasa biar kayak di gambar,
                        // atau lu tetep pake FlipTile tapi ukurannya disesuaiin.
                        Text(String(char))
                            .font(.spaceGrotesk(42, .medium))
                            .foregroundColor(.black)
                    }
                }
                .offset(x: -40, y: 10) // Sesuaikan ulang X dan Y kalau tingginya diubah
            }
        }
    }
}

#Preview() {
    RoomCodeCard(code: "ABCD")
        .padding()
}
