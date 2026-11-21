//
//  ScoringView.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 05/11/26.
//

import SwiftUI

private enum ScoreReceiptStyle {
    static let currencyMultiplier = 10
    static let positiveGreen = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255)
    static let negativeRed = Color(red: 255 / 255, green: 56 / 255, blue: 60 / 255)
    static let dividerGray = Color(red: 70 / 255, green: 68 / 255, blue: 68 / 255)

    static let miniTileSize: CGFloat = 34
    static let miniTileSpacing: CGFloat = 0.1
    static let suitcaseColumnWidth: CGFloat = miniTileSize * 3 + miniTileSpacing * 2

    static func signedDelta(_ points: Int) -> String {
        let amount = points * currencyMultiplier
        if amount > 0 { return "+\(amount) $" }
        if amount < 0 { return "-\(abs(amount)) $" }
        return "-"
    }

    static func formattedTotal(_ points: Int) -> String {
        let amount = points * currencyMultiplier
        return amount < 0 ? "-\(abs(amount))$" : "\(amount)$"
    }
}

struct ScoringView: View {
    @Bindable var viewModel: GameSessionViewModel
    var onFinishGame: () -> Void = {}
    var onDismissOverride: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    // MARK: - Derived Score State

    private var suitcaseMaxKg: Int {
        viewModel.displayedAirlineCard.maxCapacityKg
    }

    private var carryOnMaxKg: Int {
        viewModel.displayedAirlineCard.maxCarryOnKg
    }

    private var isSuitcasePerfectWeight: Bool {
        suitcaseMaxKg > 0 && viewModel.suitWeight == suitcaseMaxKg
    }

    private var isCarryOnPerfectWeight: Bool {
        carryOnMaxKg > 0 && viewModel.carryWeight == carryOnMaxKg
    }

    private var totalScore: Int {
        viewModel.calculatedIncome - viewModel.calculatedPenalty
    }


    private var occupiedSuitcaseCoords: Set<GridCoordinate> {
        LuggagePlacementEngine.occupiedCoordinates(in: viewModel.suitcaseGrid)
    }

    private var occupiedCarryOnCoords: Set<GridCoordinate> {
        LuggagePlacementEngine.occupiedCoordinates(in: viewModel.carryOnGrid)
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                headerSection
                asteriskSeparator

                luggageSection(
                    title: "Suitcase",
                    columns: viewModel.suitcaseGrid.width,
                    rows: viewModel.suitcaseGrid.height,
                    occupiedCoords: occupiedSuitcaseCoords,
                    gridAlignment: .top,
                    filledPoints: viewModel.suitcaseFilledCells,
                    perfectShapePoints: viewModel.isSuitcasePerfectShape ? 2 : 0,
                    currentWeight: viewModel.suitWeight,
                    maxWeight: suitcaseMaxKg,
                    perfectWeightPoints: isSuitcasePerfectWeight ? 3 : 0
                )

                dashedDivider

                luggageSection(
                    title: "Carry-On",
                    columns: viewModel.carryOnGrid.width,
                    rows: viewModel.carryOnGrid.height,
                    occupiedCoords: occupiedCarryOnCoords,
                    gridAlignment: .center,
                    filledPoints: viewModel.carryOnFilledCells,
                    perfectShapePoints: viewModel.isCarryOnPerfectShape ? 1 : 0,
                    currentWeight: viewModel.carryWeight,
                    maxWeight: carryOnMaxKg,
                    perfectWeightPoints: isCarryOnPerfectWeight ? 2 : 0
                )

                dashedDivider
                ordersFulfilledSection
                dashedDivider
                penaltiesSection
                dashedDivider
                grandTotalSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Header & Dividers

    private var headerSection: some View {
        ZStack {
            Text("SCORING DETAILS")
                .font(.system(size: 32, weight: .bold))
                .tracking(-0.62)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)

            if onDismissOverride != nil {
                HStack {
                    Spacer()
                    Button(action: dismissSheet) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close Scoring Details")
                }
            }
        }
    }

    private var asteriskSeparator: some View {
        HStack(spacing: 0) {
            ForEach(0..<40, id: \.self) { index in
                Text("*")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ScoreReceiptStyle.dividerGray)
                if index < 41 {
                    Spacer(minLength: 2)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private var dashedDivider: some View {
        ReceiptDashedLine()
            .stroke(
                ScoreReceiptStyle.dividerGray,
                style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
            )
            .frame(height: 2)
            .accessibilityHidden(true)
    }

    // MARK: - Luggage Sections (Suitcase & Carry-On)

    private func luggageSection(
        title: String,
        columns: Int,
        rows: Int,
        occupiedCoords: Set<GridCoordinate>,
        gridAlignment: VerticalAlignment,
        filledPoints: Int,
        perfectShapePoints: Int,
        currentWeight: Int,
        maxWeight: Int,
        perfectWeightPoints: Int
    ) -> some View {
        let isOverweight = maxWeight > 0 && currentWeight > maxWeight

        return HStack(alignment: gridAlignment, spacing: 20) {
            LuggageScoreMiniGrid(
                columns: columns,
                rows: rows,
                occupiedCoords: occupiedCoords
            )
            .frame(width: ScoreReceiptStyle.suitcaseColumnWidth)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))

                scoreDeltaRow(label: "Grids Filled:", points: filledPoints)
                scoreDeltaRow(label: "Perfect Fit:", points: perfectShapePoints)

                HStack(spacing: 6) {
                    Text("Weight:")
                        .font(.system(size: 16, weight: .regular))
                        .lineLimit(1)

                    Text("\(currentWeight)/\(maxWeight) kg")
                        .font(.system(size: 16, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(isOverweight ? ScoreReceiptStyle.negativeRed : .primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 4)

                    deltaValueText(points: perfectWeightPoints)
                }
            }
        }
    }

    // MARK: - Orders Fulfilled

    private var ordersFulfilledSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Orders Fulfilled")
                .font(.system(size: 20, weight: .bold))

            if viewModel.completedJastipOrders.isEmpty {
                HStack {
                    Text("No orders fulfilled")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                    Spacer()
                    deltaValueText(points: 0)
                }
            } else {
                ForEach(viewModel.completedJastipOrders) { order in
                    let matchedPieces = viewModel.fulfilledPieces(for: order)
                    HStack(alignment: .center, spacing: 8) {
                        Text("\(order.customerName)’s:")
                            .font(.system(size: 16, weight: .regular))
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            ForEach(Array(matchedPieces.enumerated()), id: \.offset) { _, piece in
                                PieceShapeView(
                                    piece: piece,
                                    rotation: .deg0,
                                    blockSize: 10.5,
                                    spacing: 0.5,
                                    cornerRadius: 1
                                )
                            }
                        }

                        Spacer(minLength: 8)

                        deltaValueText(points: order.points)
                    }
                    .frame(minHeight: 24)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Penalties

    private var penaltiesSection: some View {
        let droppedCount = viewModel.stagedItems.count
        let droppedPenalty = viewModel.droppedBlockKg
        let overweightKg = viewModel.totalOverweightPenalty
        let incompleteCount = viewModel.incompletePersonalJastipOrders.count
        let incompletePenalty = viewModel.totalIncompletePersonalPenalty

        return VStack(alignment: .leading, spacing: 4) {
            Text("Penalties")
                .font(.system(size: 20, weight: .bold))

            scoreDeltaRow(
                label: "Dropped Items (\(droppedCount)x)",
                points: -droppedPenalty
            )
            scoreDeltaRow(
                label: "Overweight Baggage (\(overweightKg)kg)",
                points: -overweightKg
            )
            scoreDeltaRow(
                label: "Incomplete Personal Order (\(incompleteCount)x)",
                points: -incompletePenalty
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Grand Total

    private var grandTotalSection: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Grand Total:")
                .font(.system(size: 20, weight: .bold))

            Spacer(minLength: 8)

            Text(ScoreReceiptStyle.formattedTotal(totalScore))
                .font(.shantellSans(64, .semibold))
                .foregroundStyle(Color("FragileRed"))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .rotationEffect(.degrees(-8.69))
                .padding(.trailing, 4)
                .offset(y: 10)
        }
        .padding(.vertical, 6)
        .offset(y: -40)
    }

    // MARK: - Shared Row Helpers

    private func scoreDeltaRow(label: String, points: Int) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 6)

            deltaValueText(points: points)
        }
    }

    private func deltaValueText(points: Int) -> some View {
        let color: Color = if points > 0 {
            ScoreReceiptStyle.positiveGreen
        } else if points < 0 {
            ScoreReceiptStyle.negativeRed
        } else {
            .primary
        }

        return Text(ScoreReceiptStyle.signedDelta(points))
            .font(.system(size: 16, weight: .bold))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
    }

    private func dismissSheet() {
        if let onDismissOverride {
            onDismissOverride()
        } else {
            dismiss()
        }
    }
}

// MARK: - Supporting Receipt Views

private struct LuggageScoreMiniGrid: View {
    let columns: Int
    let rows: Int
    let occupiedCoords: Set<GridCoordinate>

    var body: some View {
        VStack(spacing: ScoreReceiptStyle.miniTileSpacing) {
            ForEach(0..<rows, id: \.self) { y in
                HStack(spacing: ScoreReceiptStyle.miniTileSpacing) {
                    ForEach(0..<columns, id: \.self) { x in
                        let isOccupied = occupiedCoords.contains(GridCoordinate(x: x, y: y))
                        Image(isOccupied ? "rectangle-green" : "rectangle-gray")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: ScoreReceiptStyle.miniTileSize,
                                height: ScoreReceiptStyle.miniTileSize
                            )
                            .overlay {
                                if isOccupied {
                                    Text("+$\(ScoreReceiptStyle.currencyMultiplier)")
                                        .font(.system(size: 10, weight: .bold))
                                        .monospacedDigit()
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                        .padding(.horizontal, 2)
                                }
                            }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(occupiedCoords.count) of \(columns * rows) cells filled")
    }
}

private struct ReceiptDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

// MARK: - Previews

private struct ScoringViewPreview: View {
    private let viewModel: GameSessionViewModel

    init() {
        let card = AirlineCardCatalog.allCards.first { $0.maxCapacityKg == 20 && $0.maxCarryOnKg == 7 }
            ?? AirlineCardCatalog.allCards[2]
        let model = GameSessionViewModel(airlineCard: card)
        model.playerName = "Maxwell"
        model.suitWeight = 20
        model.carryWeight = 5

        let orangeSquare = PieceCatalog.allPieces.first { $0.id == "JASTIP2-8" }
        let orangeT = PieceCatalog.allPieces.first { $0.id == "JASTIP2-6" }
        let greenLine = PieceCatalog.allPieces.first { $0.id == "JASTIP3-4" }
        let purpleDomino = PieceCatalog.allPieces.first { $0.id == "JASTIP5-2" }
        let blueSingle = PieceCatalog.allPieces.first { $0.id == "JASTIP4-1" }
        let redSquare = PieceCatalog.allPieces.first { $0.id == "JASTIP1-8" }

        if let orangeSquare, let orangeT, let greenLine {
            model.suitcaseGrid.placedPieces = [
                PlacedPiece(
                    id: UUID(),
                    piece: orangeSquare,
                    origin: GridCoordinate(x: 0, y: 3),
                    rotation: .deg0,
                    assignedLuggage: .suitcase
                ),
                PlacedPiece(
                    id: UUID(),
                    piece: orangeT,
                    origin: GridCoordinate(x: 0, y: 0),
                    rotation: .deg0,
                    assignedLuggage: .suitcase
                ),
                PlacedPiece(
                    id: UUID(),
                    piece: greenLine,
                    origin: GridCoordinate(x: 2, y: 2),
                    rotation: .deg90,
                    assignedLuggage: .suitcase
                )
            ]
        }

        if let purpleDomino, let blueSingle {
            model.carryOnGrid.placedPieces = [
                PlacedPiece(
                    id: UUID(),
                    piece: purpleDomino,
                    origin: GridCoordinate(x: 0, y: 1),
                    rotation: .deg0,
                    assignedLuggage: .carryOn
                ),
                PlacedPiece(
                    id: UUID(),
                    piece: blueSingle,
                    origin: GridCoordinate(x: 0, y: 0),
                    rotation: .deg0,
                    assignedLuggage: .carryOn
                )
            ]
        }

        if let redSquare {
            model.stagedItems = [
                StagedItem(
                    id: UUID(),
                    piece: redSquare,
                    weight: 4,
                    rotation: .deg0,
                    lockedLuggage: nil,
                    isAlreadyCountedInWeight: false
                )
            ]
        }

        model.sharedJastipOrders = JastipOrderCatalog.allOrders.filter {
            $0.orderKey == "molly" || $0.orderKey == "kevin_straight"
        }
        model.personalJastipOrders = JastipOrderCatalog.allOrders.filter {
            $0.orderKey == "thomas"
        }

        self.viewModel = model
    }

    var body: some View {
        ScoringView(viewModel: viewModel)
    }
}

#Preview {
    ScoringViewPreview()
}
