//
//  ScannedItemTrayView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 24/10/26.
//

import SwiftUI

struct ScannedItemTrayView: View {
    let item: RevealedPiece
    var traySize: CGFloat = 135
    
    // Cek piece lurus yang perlu di-tilt 45 derajat
    private var isLinearPiece: Bool {
        switch item.piece.shape {
        case .domino, .triominoI, .tetrominoI:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        ZStack {
            // 1. Background Baki
            Image("tray")
                .resizable()
                .scaledToFit()
                .frame(width: traySize, height: traySize)
            
            // 2. Konten Cekungan Baki (Piece di atas, Teks di bawah)
            VStack(spacing: 0) {
                // Area Piece (bagian atas cekungan)
                ZStack {
                    if let uiImage = UIImage(named: item.piece.assetName) {
                        let scale = traySize / 1000
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(
                                width: uiImage.size.width * scale,
                                height: uiImage.size.height * scale
                            )
                            .rotationEffect(isLinearPiece ? .degrees(-45) : .zero)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .padding(.top, -30)
                    } else {
                        Image(item.piece.assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: traySize * 0.38, height: traySize * 0.38)
                            .rotationEffect(isLinearPiece ? .degrees(-45) : .zero)
                            .padding(.top, -30)
                    }
                }
                .frame(width: traySize * 0.7, height: traySize * 0.42)
                
                // Area Label di dalam baki (bagian bawah cekungan)
                VStack() {
                    Text("\(item.piece.color.categoryName): \(item.weight)kg")
                        .font(.spaceGrotesk(8, .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    if !item.scannedBy.isEmpty {
                        Text(item.scannedBy)
                            .font(.spaceGrotesk(10, .regular))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                }
                .frame(width: traySize * 0.7, height: traySize * 0.22)
                .padding(.top, -35)
            }

        }
        .frame(width: traySize, height: traySize)
    }
}

#Preview {
    HStack(spacing: 16) {
        ScannedItemTrayView(
            item: RevealedPiece(
                piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-5" }) ?? PieceCatalog.allPieces[0],
                weight: 4,
                scannedBy: "quincy"
            )
        )

        ScannedItemTrayView(
            item: RevealedPiece(
                piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-6" }) ?? PieceCatalog.allPieces[1],
                weight: 4,
                scannedBy: "quincy"
            )
        )
    }
    .padding()
}
