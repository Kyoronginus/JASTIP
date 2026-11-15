//
//  GameView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 21/10/26.
//


//
//  GameView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

extension LuggageType: Identifiable {
    var id: String { rawValue }
}

struct GameView: View {
    @Bindable private var viewModel: GameSessionViewModel
    var onOpenCamera: () -> Void
    var onOpenObjective: () -> Void
    
    // Properti UI Turn & Kalender (Siap disambungkan oleh dev yang mengerjakan logic turn/kalender)
    var currentTurnPlayerName: String? = nil
    var daysToGo: Int? = nil
    var onEndTurn: (() -> Void)? = nil
    
    private var displayedTurnPlayerName: String {
        currentTurnPlayerName ?? viewModel.currentTurnPlayerName
    }
    
    private var displayedDaysToGo: Int {
        if case let .calendarTear(oldDay, _) = viewModel.roundAnimationPhase {
            return oldDay
        }
        return daysToGo ?? viewModel.daysToGo
    }
    
    @State private var isShowingScanner = false
    @State private var draggingStagingItem: StagedItem? = nil
    @State private var draggingPlacedPiece: PlacedPiece? = nil
    @State private var dragLocation: CGPoint = .zero
    @State private var hoverOrigin: GridCoordinate? = nil
    @State private var hoverLuggage: LuggageType? = nil
    @State private var isHoverValid = false
    @State private var suitcaseGridFrame: CGRect = .zero
    @State private var carryOnGridFrame: CGRect = .zero
    @State private var lastHapticCoord: GridCoordinate? = nil
    @State private var cellSize: CGFloat = 46

    private let cellSpacing: CGFloat = 2
    private let cellCornerRadius: CGFloat = 3
    private let snapFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    init(
        viewModel: GameSessionViewModel? = nil,
        airlineCard: AirlineCardModel = AirlineCardCatalog.dummy,
        currentTurnPlayerName: String? = nil,
        daysToGo: Int? = nil,
        onEndTurn: (() -> Void)? = nil,
        onOpenCamera: @escaping () -> Void = {},
        onOpenObjective: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel ?? GameSessionViewModel(airlineCard: airlineCard)
        self.currentTurnPlayerName = currentTurnPlayerName
        self.daysToGo = daysToGo
        self.onEndTurn = onEndTurn
        self.onOpenCamera = onOpenCamera
        self.onOpenObjective = onOpenObjective
    }
    
    var body: some View {
        GeometryReader { geometry in
            let fittedCellSize = min(
                46,
                max(26, min((geometry.size.width - 80) / 7.15, (geometry.size.height - 450) / 6.25))
            )

            ZStack {
                VStack(spacing: 0) {
                    topHeaderSection
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    Spacer(minLength: 8)

                    luggagePairSection(cellSize: fittedCellSize)
                        .padding(.horizontal, 20)

                    StagingSectionView(
                        items: viewModel.stagedItems,
                        draggingItemId: draggingStagingItem?.id,
                        onRotateItem: { item in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                                viewModel.rotateStagedItem(id: item.id)
                            }
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        },
                        onDragItemChanged: { item, value in
                            draggingStagingItem = item
                            dragLocation = value.location
                            updateHover(
                                at: value.location,
                                for: item.piece,
                                rotation: item.rotation,
                                ignoringPieceId: nil,
                                lockedLuggage: item.lockedLuggage
                            )
                        },
                        onDragItemEnded: { item, _ in
                            handleDropStagedItem(item)
                        },
                        height: geometry.size.height < 700 ? 88 : 108
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    ZStack {
                        scanButton
                            .frame(width: 158)

                        HStack {
                            Spacer()

                            Button(action: onOpenObjective) {
                                Image(systemName: "bubble.left.fill")
                                    .frame(width: 22, height: 22)
                            }
                            .buttonStyle(
                                PrimaryButtonStyle(
                                    backgroundColor: .white,
//                                    shadowColor: Color("NavyBlack"),
                                    foregroundColor: .black,
                                    font: .system(size: 19, weight: .bold),
                                    cornerRadius: 9,
                                    paddingVertical: 9,
                                    paddingHorizontal: 9
                                )
                            )
                            .accessibilityLabel("Open chat orders")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Spacer(minLength: geometry.size.height < 700 ? 48 : 90)
                }
                
                if let (draggedPiece, draggedRotation) = activeDraggedPieceAndRotation {
                    PieceShapeView(
                        piece: draggedPiece,
                        rotation: draggedRotation,
                        blockSize: fittedCellSize,
                        spacing: cellSpacing,
                        cornerRadius: cellCornerRadius
                    )
                    .shadow(color: .black.opacity(0.45), radius: 12, y: 6)
                    .position(floatingPiecePosition)
                    .animation(.interactiveSpring(response: 0.16, dampingFraction: 0.75), value: hoverOrigin)
                    .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: "LUGGAGE_CANVAS")
            .onAppear {
                cellSize = fittedCellSize
            }
            .onChange(of: fittedCellSize) { _, newValue in
                cellSize = newValue
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("OpenSuitCaseViewBackground")
                .resizable()
                .scaledToFill()
                .overlay {
                    Color.black.opacity(0.4)
                }
                .ignoresSafeArea()
        )

        .animation(.easeInOut(duration: 0.2), value: viewModel.currentEvent != nil)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isShowingScanner) {
            QRScannerView(session: viewModel, allowsEitherLuggage: true) { piece, _, weight, _ in
                if let piece, let weight {
                    viewModel.stageScannedPiece(piece, weight: weight)
                }
            }
        }
    }

    // MARK: - Subview: Top Header (Turn Info, End Turn Button, & Calendar)
    private var topHeaderSection: some View {
        HStack(alignment: .top) {
            // Kiri: Who's Turn + Tombol End Turn
            ZStack {
                Image("TurnTag")
                    .resizable()
                    .scaledToFit()
                
                VStack(alignment: .leading, spacing: 4) {
                    // 1. NAMA PEMAIN AKTIF (OTOMATIS BERUBAH)
                    Text("\(displayedTurnPlayerName)'s turn")
                        .font(.shantellSans(18, .bold))
                        .foregroundStyle(.black)
                    
                    // 2. TOMBOL END TURN (Hanya aktif jika giliran HP ini)
                    Button {
                        if let onEndTurn {
                            onEndTurn()
                        } else {
                            viewModel.endCurrentTurn()
                        }
                    } label: {
                        Text(!viewModel.isMyTurn ? "Waiting..." : (viewModel.isDraftingObjective ? "Drafting..." : "End Turn"))
                            .font(.shantellSans(14, .bold))
                    }
                    .disabled(!viewModel.isMyTurn)
                    .opacity(viewModel.isMyTurn ? 1.0 : 0.6)
                    .disabled(!viewModel.canEndTurn)
                    .opacity(viewModel.canEndTurn ? 1.0 : 0.6)
                    .buttonStyle(
                        PrimaryButtonStyle(
                            backgroundColor: viewModel.isMyTurn ? Color("EndTurn") : Color.gray,
                            borderColor: Color("EndTurn"),
                            shadowColor: Color("EndTurn").opacity(0.65),
                            foregroundColor: .white,
                            cornerRadius: 8,
                            borderWidth: 1.5,
                            yShadowOffset: 4,
                            xShadowOffset: 2,
                            paddingVertical: 8,
                            paddingHorizontal: 16
                        )
                    )
                }
                .offset(x: -30)
            }
            .rotationEffect(.degrees(-3))
            
            Spacer()
            
            // 3. KANAN: KALENDER OTOMATIS BERKURANG TIAP ROUND
            CalendarCountdownView(daysToGo: displayedDaysToGo)
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: displayedDaysToGo)
        }
    }
    
    // MARK: - Subview: Suitcase & Carry-On di Atas Kasur
    private func luggagePairSection(cellSize: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 8) {

            VStack(spacing: 4) {
                interactiveGrid(for: .suitcase, cellSize: cellSize)
                LuggageWeightLabel(
                    currentWeight: viewModel.suitWeight,
                    maxWeight: viewModel.displayedAirlineCard.maxCapacityKg
                )
            }

            VStack(spacing: 4) {
                interactiveGrid(for: .carryOn, cellSize: cellSize)
                LuggageWeightLabel(
                    currentWeight: viewModel.carryWeight,
                    maxWeight: viewModel.displayedAirlineCard.maxCarryOnKg
                )
            }
        }
    }

    private func interactiveGrid(for luggage: LuggageType, cellSize: CGFloat) -> some View {
        LuggageGridView(
            grid: luggage == .suitcase ? viewModel.suitcaseGrid : viewModel.carryOnGrid,
            cellSize: cellSize,
            cellSpacing: cellSpacing,
            cellCornerRadius: cellCornerRadius,
            isInteractive: true,
            hoverCoords: hoverLuggage == luggage ? hoverCoordinates : nil,
            isHoverValid: isHoverValid,
            draggingPieceId: draggingPlacedPiece?.id,
            onGridFrameChange: { frame in
                if luggage == .suitcase {
                    suitcaseGridFrame = frame
                } else {
                    carryOnGridFrame = frame
                }
            },
            onRotatePiece: { placed in
                if viewModel.rotatePlacedPiece(placed) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            },
            onDragPieceChanged: { placed, value in
                draggingPlacedPiece = placed
                dragLocation = value.location
                updateHover(
                    at: value.location,
                    for: placed.piece,
                    rotation: placed.rotation,
                    ignoringPieceId: placed.id,
                    lockedLuggage: nil
                )
            },
            onDragPieceEnded: { placed, value in
                handleDropPlacedPiece(placed, at: value.location)
            }
        )
        .disabled(viewModel.currentEvent != nil || viewModel.isBoarded)
    }

    private var scanButton: some View {
        let canScanItem = viewModel.stagedItems.isEmpty
        let isEnabled = viewModel.isMyTurn && canScanItem && viewModel.currentEvent == nil && !viewModel.isBoarded

        return Button {
            isShowingScanner = true
        } label: {
            Text("Scan Item")
                .frame(maxWidth: .infinity)
        }
        .disabled(!isEnabled)
        .buttonStyle(
            PrimaryButtonStyle(
                backgroundColor: isEnabled ? Color("ScanItem") : Color.gray,
                borderColor: Color("ScanItem"),                foregroundColor: Color("SuitcaseFrame"),
                font: .shantellSans(13, .bold),
                cornerRadius: 12,
                borderWidth: 1.5,
                yShadowOffset: canScanItem ? 4 : 2,
                xShadowOffset: canScanItem ? 2 : 1,
                paddingVertical: 10,
                paddingHorizontal: 10
            )
        )
    }

    private var activeDraggedPieceAndRotation: (PieceModel, LuggageRotation)? {
        if let staged = draggingStagingItem {
            return (staged.piece, staged.rotation)
        }
        if let placed = draggingPlacedPiece {
            return (placed.piece, placed.rotation)
        }
        return nil
    }

    private var hoverCoordinates: [GridCoordinate]? {
        guard let origin = hoverOrigin,
              let (piece, rotation) = activeDraggedPieceAndRotation else {
            return nil
        }
        return LuggagePlacementEngine.absoluteCoordinates(for: piece, at: origin, rotation: rotation)
    }

    private var floatingPiecePosition: CGPoint {
        if let origin = hoverOrigin,
           let luggage = hoverLuggage,
           let (piece, rotation) = activeDraggedPieceAndRotation {
            let base = PieceCatalog.baseCoordinates(for: piece.shape, pieceId: piece.id)
            let rotated = LuggagePlacementEngine.rotate(coordinates: base, by: rotation)
            let cols = (rotated.map(\.x).max() ?? 0) + 1
            let rows = (rotated.map(\.y).max() ?? 0) + 1
            let step = cellSize + cellSpacing
            let pieceWidth = CGFloat(cols) * cellSize + CGFloat(cols - 1) * cellSpacing
            let pieceHeight = CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellSpacing
            let gridFrame = gridFrame(for: luggage)

            return CGPoint(
                x: gridFrame.minX + CGFloat(origin.x) * step + pieceWidth / 2,
                y: gridFrame.minY + CGFloat(origin.y) * step + pieceHeight / 2
            )
        }

        return dragLocation
    }

    private func gridFrame(for luggage: LuggageType) -> CGRect {
        luggage == .suitcase ? suitcaseGridFrame : carryOnGridFrame
    }

    private func grid(for luggage: LuggageType) -> LuggageGridModel {
        luggage == .suitcase ? viewModel.suitcaseGrid : viewModel.carryOnGrid
    }

    private func luggage(at location: CGPoint, preferred: LuggageType?) -> LuggageType? {
        let expansion = cellSize * 0.6
        if let preferred,
           gridFrame(for: preferred)
            .insetBy(dx: -expansion, dy: -expansion)
            .contains(location) {
            return preferred
        }
        if suitcaseGridFrame.insetBy(dx: -expansion, dy: -expansion).contains(location) {
            return .suitcase
        }
        if carryOnGridFrame.insetBy(dx: -expansion, dy: -expansion).contains(location) {
            return .carryOn
        }
        return nil
    }

    private func updateHover(
        at location: CGPoint,
        for piece: PieceModel,
        rotation: LuggageRotation,
        ignoringPieceId: UUID?,
        lockedLuggage: LuggageType?
    ) {
        guard let targetLuggage = luggage(at: location, preferred: lockedLuggage) else {
            resetHover()
            return
        }

        let targetGrid = grid(for: targetLuggage)
        let targetFrame = gridFrame(for: targetLuggage)
        let base = PieceCatalog.baseCoordinates(for: piece.shape, pieceId: piece.id)
        let rotated = LuggagePlacementEngine.rotate(coordinates: base, by: rotation)
        let cols = (rotated.map(\.x).max() ?? 0) + 1
        let rows = (rotated.map(\.y).max() ?? 0) + 1
        let step = cellSize + cellSpacing
        let pieceWidth = CGFloat(cols) * cellSize + CGFloat(cols - 1) * cellSpacing
        let pieceHeight = CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellSpacing

        let pieceTopLeftX = location.x - pieceWidth / 2
        let pieceTopLeftY = location.y - pieceHeight / 2
        let estimatedX = Int(round((pieceTopLeftX - targetFrame.minX) / step))
        let estimatedY = Int(round((pieceTopLeftY - targetFrame.minY) / step))
        let targetOrigin = GridCoordinate(x: estimatedX, y: estimatedY)

        if targetLuggage != hoverLuggage || targetOrigin != lastHapticCoord {
            lastHapticCoord = targetOrigin
            snapFeedback.impactOccurred()
        }

        hoverLuggage = targetLuggage
        hoverOrigin = targetOrigin
        isHoverValid = lockedLuggage.map { $0 == targetLuggage } ?? true
        if isHoverValid {
            isHoverValid = LuggagePlacementEngine.canPlace(
                piece: piece,
                at: targetOrigin,
                rotation: rotation,
                in: targetGrid,
                ignoringPieceId: ignoringPieceId
            )
        }
    }

    private func handleDropStagedItem(_ item: StagedItem) {
        if let origin = hoverOrigin, let luggage = hoverLuggage, isHoverValid {
            viewModel.placeStagedItem(id: item.id, at: origin, into: luggage)
        }
        finishDragging()
    }

    private func handleDropPlacedPiece(_ placed: PlacedPiece, at location: CGPoint) {
        if let origin = hoverOrigin, let targetLuggage = hoverLuggage, isHoverValid {
            if targetLuggage == placed.assignedLuggage {
                viewModel.movePlacedPiece(placed, to: origin, rotation: placed.rotation)
            } else {
                viewModel.transferPlacedPiece(placed, to: targetLuggage, at: origin)
            }
        } else if luggage(at: location, preferred: nil) == nil {
            viewModel.removePlacedPieceToStaging(placed)
        }
        finishDragging()
    }

    private func finishDragging() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            draggingStagingItem = nil
            draggingPlacedPiece = nil
            hoverOrigin = nil
            hoverLuggage = nil
            isHoverValid = false
            lastHapticCoord = nil
        }
    }

    private func resetHover() {
        hoverOrigin = nil
        hoverLuggage = nil
        isHoverValid = false
        lastHapticCoord = nil
    }
}

// MARK: - Subview: Kalender Countdown (ZStack Image + Angka)
struct CalendarCountdownView: View {
    let daysToGo: Int
    
    // Memilih nama asset otomatis: "Calendar-7", "Calendar-6", dst.
    private var calendarImageName: String {
        let clamped = max(0, min(10, daysToGo))
        return "Calendar-\(clamped)"
    }
    
    var body: some View {
        Image(calendarImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 148)
            .id(daysToGo) // Memicu re-render & animasi saat harinya berkurang
            .transition(.scale.combined(with: .opacity))
    }
}
// MARK: - Subview: Weight label for baggages
struct LuggageWeightLabel: View {
    let currentWeight: Int
    let maxWeight: Int
    
    private var isOverweight: Bool {
        currentWeight > maxWeight
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(currentWeight)")
                .foregroundStyle(isOverweight ? Color.red : Color.black)
            Text("/ \(maxWeight) kg")
                .foregroundStyle(Color.black)
        }
        .font(.shantellSans(16, .bold))
    }
}

// MARK: - Overlay: End of Round Calendar Tear & Restock Animation
struct RoundTransitionOverlayView: View {
    let phase: RoundAnimationPhase
    let onCalendarTearFinished: () -> Void
    let onContinueTapped: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed background di atas koper/kasur
            Color.black.opacity(0.42)
                .ignoresSafeArea()
            
            switch phase {
            case .none:
                EmptyView()
            case let .calendarTear(oldDay, newDay):
                CalendarTearAnimationView(
                    oldDay: oldDay,
                    newDay: newDay,
                    onFinished: onCalendarTearFinished
                )
            case .restock:
                RestockStoreAnimationView(onContinue: onContinueTapped)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 1. Animasi Geser Sobek Kalender (Pure Slide ke Kanan)
private struct CalendarTearAnimationView: View {
    let oldDay: Int
    let newDay: Int
    let onFinished: () -> Void
    private let tearHaptic = UIImpactFeedbackGenerator(style: .medium)
//    private let finishHaptic = UIImpactFeedbackGenerator(style: .light)
    
    @State private var isSlidAway: Bool = false
    
    private var clampedOldDay: Int {
        max(0, min(10, oldDay))
    }
    
    private var clampedNewDay: Int {
        max(0, min(10, newDay))
    }
    
    var body: some View {
        ZStack {
            // Layer Belakang: Kalender utuh hari baru
            Image("Calendar-\(clampedNewDay)")
                .resizable()
                .scaledToFit()
                .frame(width: 236, height: 318)
            
            // Layer Depan: Lembaran angka hari lama yang meluncur ke kanan
            Image("CalendarNumber-\(clampedOldDay)")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 226)
                .offset(x: isSlidAway ? 380 : -4, y: 40)
                .opacity(isSlidAway ? 0.3 : 1.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .offset(y: -20)
        .task(id: "\(oldDay)->\(newDay)") {
            isSlidAway = false
            tearHaptic.prepare()
            
            // 1. Tahan sebentar sebelum kertas sobek
            try? await Task.sleep(nanoseconds: 120_000_000)
            guard !Task.isCancelled else { return }
            
            // 2. Picu suara dan haptic hentakan awal tepat saat animasi geser dimulai
            tearHaptic.impactOccurred()
            AudioManager.shared.play("paper-tear") // Mainkan SFX (jika aset sudah dimasukkan)
            
            withAnimation(.easeInOut(duration: 0.42)) {
                isSlidAway = true
            }
            
            // 3. Tunggu durasi animasi geser selesai (420ms)
            try? await Task.sleep(nanoseconds: 420_000_000)
            guard !Task.isCancelled else { return }
            
//            // 4. Haptic ringan saat lembaran lama lepas penuh dan angka hari baru terlihat
//            finishHaptic.impactOccurred()
//            
            // 5. Beri jeda sisa (230ms) agar pemain sempat melihat hari baru sebelum pindah ke Restock
            try? await Task.sleep(nanoseconds: 930_000_000)
            guard !Task.isCancelled else { return }
            onFinished()
        }
    }
}

// MARK: - 2. Stop-Motion Animasi Restock ("Time to shift the store items", 100ms per frame)
private struct RestockStoreAnimationView: View {
    let onContinue: () -> Void
    
    @State private var currentFrame: Int = 1
    private let totalFrames: Int = 20
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Time to shift the store items")
                .font(.shantellSans(18, .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
                .padding(.bottom, -36)
                .zIndex(2)
            
            Image("CardV4-\(currentFrame)")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)
                .allowsHitTesting(false)
                .offset(y: -55)
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: Color("ScanItem"),
                    borderColor: Color("ScanItem"),
                    shadowColor: Color("SuitcaseFrame").opacity(0.65),
                    foregroundColor: .black,
                    font: .shantellSans(20, .bold),
                    cornerRadius: 16,
                    borderWidth: 1.5,
                    yShadowOffset: 4,
                    xShadowOffset: 2,
                    paddingVertical: 14,
                    paddingHorizontal: 24
                )
            )
            .padding(.horizontal, 28)
            .padding(.top, -18)
        }
        .offset(y: -10)
        .task {
            currentFrame = 1
            while !Task.isCancelled {
                for frame in 1...totalFrames {
                    currentFrame = frame
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    if Task.isCancelled { return }
                }
                // Jeda singkat di akhir siklus sebelum mengulang
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
        }
    }
}

#Preview("PersonalView (OpenSuitcaseView)") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    return GameView(
        viewModel: mockViewModel,
        currentTurnPlayerName: "maxwell",
        daysToGo: 7
    )
}

#Preview("1. End of Round - Calendar Tear -> Restock") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    mockViewModel.daysToGo = 6
    mockViewModel.triggerRoundTransitionAnimation(from: 7, to: 6)
    return GameView(
        viewModel: mockViewModel,
        currentTurnPlayerName: "maxwell"
    )
}

#Preview("2. Restock Animation Only") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    mockViewModel.daysToGo = 7
    mockViewModel.roundAnimationPhase = .restock
    return GameView(
        viewModel: mockViewModel,
        currentTurnPlayerName: "maxwell"
    )
}
