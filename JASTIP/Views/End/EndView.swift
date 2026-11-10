//
//  EndView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 12/10/26.
//

import SwiftUI

struct EndView: View {
    var viewModel: GameSessionViewModel
    var onFinishGame: () -> Void = {}
    
    // MARK: - Manual Penalty State (Sesuai request, dropped block tetap stepper)
    @State private var droppedBlockKg: Int = 0
    
    // MARK: - Automated Data dari ViewModel
    private var currentPlayer: PlayerStatusModel {
        viewModel.currentPlayerStatus
    }
    
    private var suitcaseFilled: Int { viewModel.suitcaseFilledCells }
    private var carryOnFilled: Int { viewModel.carryOnFilledCells }
    private var gridPoints: Int { viewModel.totalGridPoints }
    
    private var completedOrders: [JastipOrderModel] { viewModel.completedJastipOrders }
    private var jastipCardPoints: Int { viewModel.totalCompletedJastipPoints }
    
    // MARK: - Overweight Penalty (-1 pt per kg)
    private var suitcaseOverweight: Int { max(0, currentPlayer.suitcaseWeight - currentPlayer.suitcaseMax) }
    private var carryOnOverweight: Int { max(0, currentPlayer.carryOnWeight - currentPlayer.carryOnMax) }
    private var totalOverweightPenalty: Int { suitcaseOverweight + carryOnOverweight }
    
    // MARK: - Automated Combos
    private var isPerfectWeight: Bool {
        guard currentPlayer.suitcaseMax > 0 && currentPlayer.carryOnMax > 0 else { return false }
        let totalCurrent = currentPlayer.suitcaseWeight + currentPlayer.carryOnWeight
        let totalMax = currentPlayer.suitcaseMax + currentPlayer.carryOnMax
        return totalCurrent == totalMax && totalOverweightPenalty == 0
    }
    
    private var isPerfectShape: Bool {
        viewModel.isPerfectShapeFill
    }
    
    // First to board: pemain yang pertama kali menyelesaikan boarding
    private var isFirstToBoard: Bool {
        let boardedPlayers = viewModel.leaderboardPlayers.filter { $0.isBoarded }
        return boardedPlayers.first?.id == currentPlayer.id
    }
    
    // MARK: - Final Score Calculation
    private var totalScore: Int {
        let bonuses = (isPerfectWeight ? 5 : 0) + (isPerfectShape ? 2 : 0) + (isFirstToBoard ? 2 : 0)
        let penalties = droppedBlockKg + totalOverweightPenalty
        
        return gridPoints + jastipCardPoints + bonuses - penalties
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
                    Text("Scoring Summary")
                        .font(.spaceGrotesk(18, .bold))
                        .foregroundStyle(Color("TaxiYellow"))
                    Spacer()
                    
                    Text(currentPlayer.name.uppercased())
                        .font(.plusJakarta(12, .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
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
                    
                    // MARK: - 1. Grid Points Section (AUTO)
                    sectionCard(title: "GRID FILLED POINTS (AUTO)") {
                        autoScoreRow(
                            label: "Suitcase Grid",
                            detail: "\(suitcaseFilled) / 15 slots",
                            scoreText: "+\(suitcaseFilled) pts"
                        )
                        Divider()
                        autoScoreRow(
                            label: "Carry-On Grid",
                            detail: "\(carryOnFilled) / 4 slots",
                            scoreText: "+\(carryOnFilled) pts"
                        )
                    }
                    
                    // MARK: - 2. Jastip Completed Cards Section (AUTO)
                    sectionCard(title: "COMPLETED JASTIP ORDERS (AUTO)") {
                        if completedOrders.isEmpty {
                            HStack {
                                Text("No orders completed")
                                    .font(.plusJakarta(14, .regular))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("0 pts")
                                    .font(.spaceGrotesk(14, .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ForEach(completedOrders) { order in
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text(order.customerName)
                                            .font(.plusJakarta(15, .semibold))
                                    }
                                    Spacer()
                                    Text("+\(order.points) pts")
                                        .font(.spaceGrotesk(15, .bold))
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                    
                    // MARK: - 3. Bonus Combos Section (AUTO)
                    sectionCard(title: "BONUS COMBOS (AUTO)") {
                        // Perfect Weight
                        autoBonusRow(
                            label: "Perfect Weight",
                            isAchieved: isPerfectWeight,
                            rewardText: "+5 pts"
                        )
                        
                        Divider()
                        
                        // Perfect Shape Fill
                        autoBonusRow(
                            label: "Perfect Shape Fill (19/19 slots)",
                            isAchieved: isPerfectShape,
                            rewardText: "+2 pts"
                        )
                        
                        Divider()
                        
                        // First to Board
                        autoBonusRow(
                            label: "First to Board",
                            isAchieved: isFirstToBoard,
                            rewardText: "+2 pts"
                        )
                    }
                    
                    // MARK: - 4. Penalties Section
                    sectionCard(title: "PENALTIES") {
                        // Dropped Block (MANUAL STEPPER)
                        stepperRow(
                            label: "Dropped Block (-1 pt / kg)",
                            value: $droppedBlockKg,
                            range: 0...30,
                            isNegative: true
                        )
                        
                        Divider()
                        
                        // Overweight Penalty (AUTO)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Overweight Bag")
                                        .font(.plusJakarta(15, .semibold))
                                    autoBadge
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
    private var autoBadge: some View {
        Text("AUTO")
            .font(.plusJakarta(10, .bold))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func autoScoreRow(label: String, detail: String, scoreText: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(label)
                        .font(.plusJakarta(15, .semibold))
                    autoBadge
                }
                Text(detail)
                    .font(.plusJakarta(12, .regular))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(scoreText)
                .font(.spaceGrotesk(15, .bold))
                .foregroundStyle(Color("PassportBlue850"))
        }
    }
    
    @ViewBuilder
    private func autoBonusRow(label: String, isAchieved: Bool, rewardText: String) -> some View {
        HStack {
            HStack(spacing: 6) {
                Text(label)
                    .font(.plusJakarta(15, .semibold))
                autoBadge
            }
            Spacer()
            if isAchieved {
                Text(rewardText)
                    .font(.spaceGrotesk(15, .bold))
                    .foregroundStyle(.green)
            } else {
                Text("0 pts")
                    .font(.spaceGrotesk(14, .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
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
