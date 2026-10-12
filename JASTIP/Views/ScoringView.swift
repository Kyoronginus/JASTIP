//
//  ScoringView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 12/10/26.
//

import SwiftUI

struct ScoringView: View {
    let viewModel: GameSessionViewModel
    var onFinishGame: () -> Void = {}
    
    @State private var selectedColor: PieceColor = .red
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    private var piecesForSelectedColor: [PieceModel] {
        PieceCatalog.allPieces.filter { $0.color == selectedColor }
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BOARDING TIME")
                            .font(.caption.bold())
                            .tracking(2)
                            .foregroundStyle(.secondary)
                        Text("HASIL BOBOT AKHIR")
                            .font(.title3.bold())
                    }
                    
                    Spacer()
                    
                    Button("SELESAI MAIN") {
                        onFinishGame()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                
                // Konten Utama: Sisi Kiri (Airline Card), Sisi Kanan (Bobot Pieces)
                HStack(alignment: .top, spacing: 20) {
                    // Sisi Kiri: Airline Card
                    VStack {
                        AirlineCard(data: viewModel.displayedAirlineCard)
                            .scaleEffect(0.9)
                            .frame(width: 180, height: 270)
                    }
                    
                    // Sisi Kanan: Segmented Control Warna & Grid Pieces
                    VStack(spacing: 10) {
                        Picker("Warna", selection: $selectedColor) {
                            ForEach(PieceColor.allCases, id: \.self) { color in
                                Text(color.rawValue).tag(color)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(piecesForSelectedColor) { piece in
                                    let finalWeight = viewModel.weight(for: piece.id)
                                    let delta = finalWeight - piece.gridCount
                                    let wasScanned = viewModel.revealedPieces.contains(where: { $0.id == piece.id })
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(piece.shape.rawValue)
                                                .font(.caption.bold())
                                                .lineLimit(1)
                                            Spacer()
                                            if wasScanned {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        
                                        HStack(alignment: .firstTextBaseline) {
                                            Text("\(finalWeight) kg")
                                                .font(.headline.bold())
                                                .foregroundColor(piece.color.displayColor)
                                            
                                            Spacer()
                                            
                                            if piece.isAnomaly {
                                                Text("Anomaly")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(Color.purple.opacity(0.15))
                                                    .foregroundColor(.purple)
                                                    .cornerRadius(4)
                                            } else if delta != 0 {
                                                Text(delta > 0 ? "+\(delta)" : "\(delta)")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background((delta > 0 ? Color.red : Color.green).opacity(0.15))
                                                    .foregroundColor(delta > 0 ? .red : .green)
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        Text("Base: \(piece.gridCount) kg")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(8)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(piece.color.displayColor.opacity(0.35), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Light", traits: .landscapeRight) {
    ScoringView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark", traits: .landscapeRight) {
    ScoringView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.dark)
}
