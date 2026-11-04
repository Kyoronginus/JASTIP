//
//  EndView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 12/10/26.
//

import SwiftUI

struct EndView: View {
    var players: [PlayerStatusModel] = []
    var onFinishGame: () -> Void = {}
    
    // MARK: - Manual Inputs State
    @State private var suitcaseGridFilled: Int = 0
    @State private var carryOnGridFilled: Int = 0
    @State private var jastipCardPoints: Int = 0
    @State private var isPerfectShape: Bool = false
    @State private var isFirstToBoard: Bool = false
    @State private var droppedBlockKg: Int = 0
    
    // MARK: - Current Player Data (Dari App)
    private var currentPlayer: PlayerStatusModel? {
        players.first(where: { $0.isCurrentDevice }) ?? players.first
    }
    
    private var suitcaseWeight: Int { currentPlayer?.suitcaseWeight ?? 0 }
    private var suitcaseMax: Int { currentPlayer?.suitcaseMax ?? 20 }
    private var carryWeight: Int { currentPlayer?.carryOnWeight ?? 0 }
    private var carryMax: Int { currentPlayer?.carryOnMax ?? 7 }
    
    // MARK: - Automated Logic
    // Overweight Penalty: -1 pt per kg kelebihan
    private var suitcaseOverweight: Int { max(0, suitcaseWeight - suitcaseMax) }
    private var carryOnOverweight: Int { max(0, carryWeight - carryMax) }
    private var totalOverweightPenalty: Int { suitcaseOverweight + carryOnOverweight }
    
    // Perfect Weight Combo: Pas di batas maksimal tanpa overweight (+5 pts)
    private var isPerfectWeight: Bool {
        guard suitcaseMax > 0 && carryMax > 0 else { return false }
        let totalCurrent = suitcaseWeight + carryWeight
        let totalMax = suitcaseMax + carryMax
        return totalCurrent == totalMax && totalOverweightPenalty == 0
    }
    
    // MARK: - Final Score Calculation
    private var totalScore: Int {
        let gridPoints = suitcaseGridFilled + carryOnGridFilled
        let cardPoints = jastipCardPoints
        let bonusPoints = (isPerfectWeight ? 5 : 0) + (isPerfectShape ? 2 : 0) + (isFirstToBoard ? 2 : 0)
        let penalties = droppedBlockKg + totalOverweightPenalty
        
        return gridPoints + cardPoints + bonusPoints - penalties
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header Bar
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
                    Text("Scoring Calculator")
                        .font(.spaceGrotesk(18, .bold))
                        .foregroundStyle(Color("TaxiYellow"))
                    Spacer()
                    
                    if let name = currentPlayer?.name {
                        Text(name.uppercased())
                            .font(.plusJakarta(12, .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            
            
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Live Total Score Hero Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TOTAL FINAL SCORE")
                                .font(.plusJakarta(12, .bold))
                                .foregroundStyle(.secondary)
                            Text("\(totalScore) Points")
                                .font(.spaceGrotesk(32, .bold))
                                .foregroundStyle(totalScore >= 0 ? Color("PassportBlue850") : Color("FragileRed"))
                        }
                        Spacer()
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(Color("TaxiYellow"))
                    }
                    .padding(18)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                    
                    // MARK: - 1. Grid Points Section
                    sectionCard(title: "GRID FILLED POINTS") {
                        stepperRow(label: "Suitcase Grid", value: $suitcaseGridFilled, range: 0...15)
                        Divider()
                        stepperRow(label: "Carry-On Grid", value: $carryOnGridFilled, range: 0...4)
                    }
                    
                    // MARK: - 2. Jastip Cards Section
                    sectionCard(title: "PRIVATE JASTIP CARDS") {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total Card Points")
                                    .font(.plusJakarta(15, .semibold))
                            }
                            Spacer()
                            
                            HStack(spacing: 4) {
                                TextField("0", value: $jastipCardPoints, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .font(.spaceGrotesk(18, .bold))
                                    .frame(width: 50)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(Color(uiColor: .systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Text("pts")
                                    .font(.plusJakarta(13, .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // MARK: - 3. Bonus Combos Section
                    sectionCard(title: "BONUS COMBOS") {
                        // Perfect Weight (Automated)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Perfect Weight")
                                        .font(.plusJakarta(15, .semibold))
                                    Text("AUTO")
                                        .font(.plusJakarta(10, .bold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(.gray)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            Spacer()
                            
                            if isPerfectWeight {
                                Text("+5 pts")
                                    .font(.spaceGrotesk(15, .bold))
                                    .foregroundStyle(.green)
                            } else {
                                Text("0 pts")
                                    .font(.spaceGrotesk(14, .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Perfect Shape Fill Toggle
                        Toggle(isOn: $isPerfectShape) {
                            Text("Perfect Shape Fill")
                                .font(.plusJakarta(15, .semibold))
                        }
                        .tint(.blue)
                        
                        Divider()
                        
                        // First to Board Toggle
                        Toggle(isOn: $isFirstToBoard) {
                            Text("First to Board")
                                .font(.plusJakarta(15, .semibold))
                        }
                        .tint(.blue)
                    }
                    
                    // MARK: - 4. Penalties Section
                    sectionCard(title: "PENALTIES") {
                        // Dropped Block Stepper
                        stepperRow(
                            label: "Dropped Block (-1 pt / kg)",
                            value: $droppedBlockKg,
                            range: 0...30,
                            isNegative: true
                        )
                        
                        Divider()
                        
                        // Overweight Penalty (Automated)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Overweight Bag")
                                        .font(.plusJakarta(15, .semibold))
                                    Text("AUTO")
                                        .font(.plusJakarta(10, .bold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(.gray)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                                Text("Overweight: \(totalOverweightPenalty) kg (-1 pt / kg)")
                                    .font(.plusJakarta(12, .regular))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            
                            if totalOverweightPenalty > 0 {
                                Text("-\(totalOverweightPenalty) pts")
                                    .font(.spaceGrotesk(15, .bold))
                                    .foregroundStyle(Color("FragileRed"))
                            } else {
                                Text("0 pts")
                                    .font(.spaceGrotesk(14, .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // MARK: - Finish Action Button
                    Button("FINISHED PLAYING") {
                        onFinishGame()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
            }
        }
        .appBackground()
    }
    
    // MARK: - Subviews & Helpers
    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.spaceGrotesk(13, .bold))
                .foregroundStyle(.secondary)
            VStack(spacing: 12) {
                content()
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private func stepperRow(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        isNegative: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(.plusJakarta(15, .semibold))
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Text("\(value.wrappedValue)")
                    .font(.spaceGrotesk(17, .bold))
                    .frame(minWidth: 28)
                    .foregroundStyle(isNegative && value.wrappedValue > 0 ? Color("FragileRed") : .primary)
                
                Button {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Previews
#Preview("Light") {
    EndView(
        players: [
            PlayerStatusModel(
                id: "1",
                name: "Feivel",
                isCurrentDevice: true,
                suitcaseWeight: 22,
                suitcaseMax: 20,
                carryOnWeight: 8,
                carryOnMax: 7,
                isBoarded: true
            )
        ]
    )
    .preferredColorScheme(.light)
}

#Preview("Perfect Weight Scenario") {
    EndView(
        players: [
            PlayerStatusModel(
                id: "1",
                name: "Qutby",
                isCurrentDevice: true,
                suitcaseWeight: 20,
                suitcaseMax: 20,
                carryOnWeight: 7,
                carryOnMax: 7,
                isBoarded: true
            )
        ]
    )
    .preferredColorScheme(.light)
}
