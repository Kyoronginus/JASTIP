//
//  ScannedItemView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 14/10/26.
//

import SwiftUI

struct ScannedItemView: View {
    let pieces: [RevealedPiece]
    var onViewAll: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background Conveyor Belt
            Image("conveyor")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 223)
                .clipped()
            
            // Carousel
            if pieces.isEmpty {
                VStack() {
                    Text("There is no revealed piece")
                        .font(.spaceGrotesk(14, .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() {
                        ForEach(pieces) { item in
                            ScannedItemTrayView(item: item, traySize: 195)
                        }
                    }
//                    .padding(.bottom, 30) // Ruang agar tidak tertutup tombol View All
                }
            }
            
            // View All
            if !pieces.isEmpty {
                Button(action: onViewAll) {
                    HStack() {
                        Text("View All")
                            .font(.spaceGrotesk(12, .regular))
                        Image(systemName: "chevron.left.2")
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundStyle(.white)
                    .font(.plusJakarta(16, .regular))
                    .padding(.vertical, 6)
                }
                .padding(.trailing, 12)
                .padding(.bottom, 6)
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    let sample = [
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP3-9" }) ?? PieceCatalog.allPieces[0],
            weight: 4,
            scannedBy: "quincy"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-6" }) ?? PieceCatalog.allPieces[1],
            weight: 4,
            scannedBy: "emily"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-9" }) ?? PieceCatalog.allPieces[2],
            weight: 5,
            scannedBy: "david"
        )
    ]
    
    ScannedItemView(pieces: sample)
}
