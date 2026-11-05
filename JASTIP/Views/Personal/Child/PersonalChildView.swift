//
//  PersonalChildView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

import SwiftUI

struct PersonalChildView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var session: GameSessionViewModel
    
    @State private var activeLuggage: LuggageType
    
    // State drag-and-drop (berlaku untuk drag dari staging maupun dari dalam grid)
    @State private var draggingStagingItem: StagedItem? = nil
    @State private var draggingPlacedPiece: PlacedPiece? = nil
    @State private var dragLocation: CGPoint = .zero
    @State private var hoverOrigin: GridCoordinate? = nil
    @State private var isHoverValid: Bool = false
    @State private var gridFrame: CGRect = .zero
    
    private let cellSize: CGFloat = 72
    var initialLuggage: LuggageType = .suitcase
    
    init(session: GameSessionViewModel, initialLuggage: LuggageType = .suitcase) {
        self.session = session
        self.initialLuggage = initialLuggage
        let startLuggage = session.stagedItems.first?.lockedLuggage ?? initialLuggage
        _activeLuggage = State(initialValue: startLuggage)
    }
    
    private var activeGrid: LuggageGridModel {
        activeLuggage == .suitcase ? session.suitcaseGrid : session.carryOnGrid
    }
    
    private var currentWeight: Int {
        activeLuggage == .suitcase ? session.suitWeight : session.carryWeight
    }
    
    private var maxWeight: Int {
        activeLuggage == .suitcase ? session.displayedAirlineCard.maxCapacityKg : session.displayedAirlineCard.maxCarryOnKg
    }
    
    private var isOverweight: Bool {
        currentWeight > maxWeight
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
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                headerBar
                
                Spacer()
                
                // Koper + Tombol Arrow Kiri & Kanan
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            activeLuggage = .suitcase
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(activeLuggage == .suitcase ? Color.secondary.opacity(0.3) : Color("TaxiYellow"))
                            .frame(width: 36, height: 36)
                            .background(Color("NavyBlack").opacity(activeLuggage == .suitcase ? 0.3 : 0.85))
                            .clipShape(Circle())
                    }
                    .disabled(activeLuggage == .suitcase)
                    
                    Spacer()
                    
                    LuggageGridView(
                        grid: activeGrid,
                        cellSize: cellSize,
                        hoverCoords: hoverCoordinates,
                        isHoverValid: isHoverValid,
                        draggingPieceId: draggingPlacedPiece?.id,
                        onRotatePiece: { placed in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                session.rotatePlacedPiece(placed)
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
                                lockedLuggage: placed.assignedLuggage
                            )
                        },
                        onDragPieceEnded: { placed, value in
                            handleDropPlacedPiece(placed, at: value.location)
                        }
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    gridFrame = geo.frame(in: .named("LUGGAGE_CANVAS"))
                                }
                                .onChange(of: geo.frame(in: .named("LUGGAGE_CANVAS"))) { _, newFrame in
                                    gridFrame = newFrame
                                }
                        }
                    )

                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            activeLuggage = .carryOn
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(activeLuggage == .carryOn ? Color.secondary.opacity(0.3) : Color("TaxiYellow"))
                            .frame(width: 36, height: 36)
                            .background(Color("NavyBlack").opacity(activeLuggage == .carryOn ? 0.3 : 0.85))
                            .clipShape(Circle())
                    }
                    .disabled(activeLuggage == .carryOn)
                }
                
                Spacer()
                
                // Area Bawah: Staging Kepingan
                StagingSectionView(
                    items: session.stagedItems,
                    draggingItemId: draggingStagingItem?.id,
                    onRotateItem: { item in
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                            session.rotateStagedItem(id: item.id)
                        }
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
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Floating Piece saat di-drag (membesar ke ukuran asli grid koper)
            if let (draggedPiece, draggedRotation) = activeDraggedPieceAndRotation {
                PieceShapeView(
                    piece: draggedPiece,
                    rotation: draggedRotation,
                    blockSize: cellSize,
                    spacing: 4,
                    cornerRadius: 10
                )
                .shadow(color: .black.opacity(0.45), radius: 12, y: 6)
                .position(dragLocation)
                .allowsHitTesting(false)
            }
        }
        .coordinateSpace(name: "LUGGAGE_CANVAS")
        .appBackground()
        .onAppear {
            session.captureGridSnapshotIfNeeded()
            if let locked = session.stagedItems.first?.lockedLuggage {
                activeLuggage = locked
            } else {
                activeLuggage = initialLuggage
            }
        }
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            Button {
                if session.stagedItems.isEmpty {
                    session.commitGridSession()
                } else {
                    session.cancelUnplacedStagingAndRestoreGrid()
                }
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text(session.stagedItems.isEmpty ? "Selesai" : "Batal")
                        .font(.spaceGrotesk(14, .bold))
                }
            }
            .buttonStyle(PrimaryButtonStyle(
                backgroundColor: .black,
                borderColor: Color("TaxiYellow"),
                foregroundColor: Color("TaxiYellow"),
                cornerRadius: 12,
                paddingVertical: 10,
                paddingHorizontal: 14
            ))
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(currentWeight) / \(maxWeight) KG")
                    .font(.spaceGrotesk(18, .bold))
                    .foregroundStyle(isOverweight ? Color("FragileRed") : Color("TaxiYellow"))
                if isOverweight {
                    Text("OVERWEIGHT (-1 pt/kg)")
                        .font(.spaceGrotesk(10, .bold))
                        .foregroundStyle(Color("FragileRed"))
                }
            }
        }
    }
    
    // MARK: - Drag Collision & Drop Handling
    private func updateHover(
        at location: CGPoint,
        for piece: PieceModel,
        rotation: LuggageRotation,
        ignoringPieceId: UUID?,
        lockedLuggage: LuggageType?
    ) {
        let expandedGridZone = gridFrame.insetBy(dx: -cellSize * 0.6, dy: -cellSize * 0.6)
        guard expandedGridZone.contains(location) else {
            hoverOrigin = nil
            isHoverValid = false
            return
        }
        
        let base = PieceCatalog.baseCoordinates(for: piece.shape, pieceId: piece.id)
        let rotated = LuggagePlacementEngine.rotate(coordinates: base, by: rotation)
        let cols = (rotated.map(\.x).max() ?? 0) + 1
        let rows = (rotated.map(\.y).max() ?? 0) + 1
        
        let step = cellSize + 4
        let pieceWidth = CGFloat(cols) * cellSize + CGFloat(cols - 1) * 4
        let pieceHeight = CGFloat(rows) * cellSize + CGFloat(rows - 1) * 4
        
        let pieceTopLeftX = location.x - pieceWidth / 2.0
        let pieceTopLeftY = location.y - pieceHeight / 2.0
        
        let gridOriginX = gridFrame.minX + 12
        let gridOriginY = gridFrame.minY + 12
        
        let estimatedX = Int(round((pieceTopLeftX - gridOriginX) / step))
        let estimatedY = Int(round((pieceTopLeftY - gridOriginY) / step))
        
        let targetOrigin = GridCoordinate(x: estimatedX, y: estimatedY)
        hoverOrigin = targetOrigin
        
        if let locked = lockedLuggage, locked != activeLuggage {
            isHoverValid = false
            return
        }
        
        isHoverValid = LuggagePlacementEngine.canPlace(
            piece: piece,
            at: targetOrigin,
            rotation: rotation,
            in: activeGrid,
            ignoringPieceId: ignoringPieceId
        )
    }
    
    private func handleDropStagedItem(_ item: StagedItem) {
        if let origin = hoverOrigin, isHoverValid {
            session.placeStagedItem(id: item.id, at: origin, into: activeLuggage)
        }
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            draggingStagingItem = nil
            hoverOrigin = nil
            isHoverValid = false
        }
    }
    
    private func handleDropPlacedPiece(_ placed: PlacedPiece, at location: CGPoint) {
        if let origin = hoverOrigin, isHoverValid {
            session.movePlacedPiece(placed, to: origin, rotation: placed.rotation)
        } else if !gridFrame.insetBy(dx: -16, dy: -16).contains(location) {
            // Jika ditarik keluar dari koper, pindahkan kembali ke area staging untuk ditata ulang
            session.removePlacedPieceToStaging(placed)
        }
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            draggingPlacedPiece = nil
            hoverOrigin = nil
            isHoverValid = false
        }
    }
}

// MARK: - Subview: Area Staging Kepingan
private struct StagingSectionView: View {
    let items: [StagedItem]
    let draggingItemId: UUID?
    let onRotateItem: (StagedItem) -> Void
    let onDragItemChanged: (StagedItem, DragGesture.Value) -> Void
    let onDragItemEnded: (StagedItem, DragGesture.Value) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(
                items.isEmpty
                    ? "Tarik barang di koper untuk geser / keluarkan • Double-tap untuk putar"
                    : "Double-tap untuk memutar • Tarik ke koper"
            )
            .font(.spaceGrotesk(11, .medium))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            
            if items.isEmpty {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                    .foregroundStyle(Color.secondary.opacity(0.35))
                    .frame(height: 96)
                    .overlay(
                        Text("Tarik barang ke sini untuk dikeluarkan sementara")
                            .font(.spaceGrotesk(12, .regular))
                            .foregroundStyle(.secondary.opacity(0.6))
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(items) { item in
                            PieceShapeView(
                                piece: item.piece,
                                rotation: item.rotation,
                                blockSize: 28,
                                spacing: 2,
                                cornerRadius: 5
                            )
                            .padding(8)
                            .opacity(draggingItemId == item.id ? 0.15 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 4, coordinateSpace: .named("LUGGAGE_CANVAS"))
                                    .onChanged { value in
                                        onDragItemChanged(item, value)
                                    }
                                    .onEnded { value in
                                        onDragItemEnded(item, value)
                                    }
                            )
                            .onTapGesture(count: 2) {
                                onRotateItem(item)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(minHeight: 96)
                }
                .frame(height: 104)
            }
        }
        .frame(height: 130)
    }
}

// MARK: - Subview: Bentuk Kepingan (Digunakan untuk Staging Kecil & Drag Ukuran Grid)
struct PieceShapeView: View {
    let piece: PieceModel
    let rotation: LuggageRotation
    var blockSize: CGFloat = 28
    var spacing: CGFloat = 2
    var cornerRadius: CGFloat = 5
    
    private var rotatedCoordinates: Set<GridCoordinate> {
        let base = PieceCatalog.baseCoordinates(for: piece.shape, pieceId: piece.id)
        return Set(LuggagePlacementEngine.rotate(coordinates: base, by: rotation))
    }
    
    private var columnsCount: Int {
        (rotatedCoordinates.map(\.x).max() ?? 0) + 1
    }
    
    private var rowsCount: Int {
        (rotatedCoordinates.map(\.y).max() ?? 0) + 1
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<rowsCount, id: \.self) { y in
                HStack(spacing: spacing) {
                    ForEach(0..<columnsCount, id: \.self) { x in
                        PieceBlockCellView(
                            isFilled: rotatedCoordinates.contains(GridCoordinate(x: x, y: y)),
                            color: piece.color.displayColor,
                            size: blockSize,
                            cornerRadius: cornerRadius
                        )
                    }
                }
            }
        }
    }
}

private struct PieceBlockCellView: View {
    let isFilled: Bool
    let color: Color
    let size: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(isFilled ? color.opacity(0.92) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFilled ? Color.white.opacity(0.45) : Color.clear, lineWidth: 1.5)
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview("PersonalChildView") {
    let session = GameSessionViewModel()
    session.stagingPiece = PieceCatalog.allPieces.first(where: { $0.shape == .smallL })
    session.stagingWeight = 3
    
    return PersonalChildView(session: session)
}
