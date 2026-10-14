//
//  RevealedPiecesListView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 11/10/26.
//

import SwiftUI

struct RevealedPiecesListView: View {
    let pieces: [RevealedPiece]
    var onDismiss: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 12) {
            Text("BOBOT TERBUKA")
                .font(.caption.bold())
                .tracking(2)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            
            Divider()
            
            if pieces.isEmpty {
                Text("Belum ada piece yang discan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(height: 80)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(pieces) { item in
                            HStack {
                                Text("\(item.piece.color.rawValue) - \(item.piece.shape.rawValue)")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(item.weight) kg")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .frame(maxHeight: 140)
            }
            
            Button("TUTUP", action: onDismiss)
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: .primary,
                    foregroundColor: Color(uiColor: .systemBackground)
                ))
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

#Preview("Light") {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        RevealedPiecesListView(pieces: [
            RevealedPiece(
                piece: PieceModel(id: "JASTIP1-6", shape: .tetrominoT, color: .red, gridCount: 4, isAnomaly: false),
                weight: 4
            ),
            RevealedPiece(
                piece: PieceModel(id: "JASTIP4-2", shape: .domino, color: .blue, gridCount: 2, isAnomaly: false),
                weight: 3
            )
        ])
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        RevealedPiecesListView(pieces: [
            RevealedPiece(
                piece: PieceModel(id: "JASTIP1-6", shape: .tetrominoT, color: .red, gridCount: 4, isAnomaly: false),
                weight: 4
            ),
            RevealedPiece(
                piece: PieceModel(id: "JASTIP4-2", shape: .domino, color: .blue, gridCount: 2, isAnomaly: false),
                weight: 3
            )
        ])
    }
    .preferredColorScheme(.dark)
}
