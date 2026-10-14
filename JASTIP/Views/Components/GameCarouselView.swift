//
//  GameCarouselView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 14/10/26.
//

import SwiftUI

//struct CarouselItem {
//    let id = UUID()
//    let imageName: String
//    let weight: Int
//}
//
let samplePieces = [
    RevealedPiece(piece: PieceModel(id: "JASTIP1-1", shape: .single, color: .red, gridCount: 1, isAnomaly: false), weight: 3),
    RevealedPiece(piece: PieceModel(id: "JASTIP1-1", shape: .single, color: .red, gridCount: 1, isAnomaly: false), weight: 3),
    RevealedPiece(piece: PieceModel(id: "JASTIP1-1", shape: .single, color: .red, gridCount: 1, isAnomaly: false), weight: 3)
]

struct GameCarouselView: View {
    let pieces: [RevealedPiece]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack (spacing: 24){
                ForEach(pieces) { item in
                    VStack {
                        Image(systemName: "shoe.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Text("\(item.weight) kg")
                    }
                }
            }
        }
//        .background(.gray)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

#Preview {
    GameCarouselView(pieces: samplePieces)
}
