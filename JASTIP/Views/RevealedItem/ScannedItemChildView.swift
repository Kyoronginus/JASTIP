//
//  ScannedItemChildView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 24/10/26.
//

import SwiftUI

struct ScannedItemChildView: View {
    let pieces: [RevealedPiece]
    @Environment(\.dismiss) private var dismiss
    
    // Grid 2 kolom fleksibel
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            // MARK: - Header Bar
            HStack {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                }
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: .black,
                    borderColor: Color("TaxiYellow"),
                    foregroundColor: Color("TaxiYellow"),
                    cornerRadius: 14,
                    paddingVertical: 14,
                    paddingHorizontal: 15
                ))
                .padding(.trailing, 10)
                
                // Title Banner
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.black)
                    
                    // Watermark Asterisk
                    Image("AsteriskYellow")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.white.opacity(0.12))
                        .scaledToFit()
                        .frame(width: 155, height: 155)
                        .offset(x: 52, y: 27)
                    
                    HStack {
                        Text("Scanned Items")
                            .font(.spaceGrotesk(18, .bold))
                            .foregroundStyle(Color("TaxiYellow"))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // MARK: - Grid Content
            if pieces.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("Belum ada item yang discan")
                        .font(.spaceGrotesk(16, .medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns) {
                        ForEach(pieces) { item in
                            ScannedItemTrayChildView(item: item, traySize: 200)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .appBackground()
    }
}

#Preview {
    let sample = [
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP1-5" }) ?? PieceCatalog.allPieces[0],
            weight: 4,
            scannedBy: "quincy"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-6" }) ?? PieceCatalog.allPieces[1],
            weight: 4,
            scannedBy: "emily"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP2-8" }) ?? PieceCatalog.allPieces[2],
            weight: 5,
            scannedBy: "david"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP5-5" }) ?? PieceCatalog.allPieces[3],
            weight: 6,
            scannedBy: "hannah"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-9" }) ?? PieceCatalog.allPieces[4],
            weight: 5,
            scannedBy: "emily"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP3-8" }) ?? PieceCatalog.allPieces[5],
            weight: 3,
            scannedBy: "david"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-5" }) ?? PieceCatalog.allPieces[4],
            weight: 5,
            scannedBy: "emily"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP3-9" }) ?? PieceCatalog.allPieces[5],
            weight: 3,
            scannedBy: "david"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP4-9" }) ?? PieceCatalog.allPieces[4],
            weight: 5,
            scannedBy: "emily"
        ),
        RevealedPiece(
            piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP3-7" }) ?? PieceCatalog.allPieces[5],
            weight: 3,
            scannedBy: "david"
        )
    ]
    
    ScannedItemChildView(pieces: sample)
}
