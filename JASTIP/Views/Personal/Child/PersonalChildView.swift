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
    
    let activeLuggage: LuggageType
    
    // State Scanner
    @State private var isShowingScanner: Bool = false
    
    // State drag-and-drop (berlaku untuk drag dari staging maupun dari dalam grid)
    @State private var draggingStagingItem: StagedItem? = nil
    @State private var draggingPlacedPiece: PlacedPiece? = nil
    @State private var dragLocation: CGPoint = .zero
    @State private var hoverOrigin: GridCoordinate? = nil
    @State private var isHoverValid: Bool = false
    @State private var gridFrame: CGRect = .zero
    
    init(session: GameSessionViewModel, initialLuggage: LuggageType = .suitcase) {
        self.session = session
        self.activeLuggage = initialLuggage
    }
    
    private var cellSize: CGFloat {
        activeLuggage == .suitcase ? 82 : 114
    }
    
    private var cellSpacing: CGFloat {
        activeLuggage == .suitcase ? 5 : 6
    }
    
    private var cellCornerRadius: CGFloat {
        activeLuggage == .suitcase ? 8 : 13
    }
    
    private var activeGrid: LuggageGridModel {
        activeLuggage == .suitcase ? session.suitcaseGrid : session.carryOnGrid
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
            VStack(spacing: 14) {
                headerBar
                
                Spacer(minLength: 0)
                
                LuggageGridView(
                    grid: activeGrid,
                    cellSize: cellSize,
                    cellSpacing: cellSpacing,
                    cellCornerRadius: cellCornerRadius,
                    isInteractive: true,
                    hoverCoords: hoverCoordinates,
                    isHoverValid: isHoverValid,
                    draggingPieceId: draggingPlacedPiece?.id,
                    onGridFrameChange: { newFrame in
                        gridFrame = newFrame
                    },
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
                
                Spacer(minLength: 0)
                
                // Area Bawah: Staging Kepingan ("Drag items here to reorganize")
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
                
                // Tombol Scan Item
                Button {
                    isShowingScanner = true
                } label: {
                    Text("Scan Item")
                }
                .buttonStyle(
                    PrimaryButtonStyle(
                        backgroundColor: Color("ScanItem"),
                        borderColor: Color("ScanItem"),
                        shadowColor: Color("SuitcaseGrid"),
                        foregroundColor: Color("SuitcaseFrame"),
                        font: .shantellSans(16, .bold),
                        cornerRadius: 14,
                        borderWidth: 1.5,
                        shadowOffset: 5,
                        paddingVertical: 12,
                        paddingHorizontal: 36
                    )
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            // Floating Piece saat di-drag (membesar ke ukuran asli grid koper)
            if let (draggedPiece, draggedRotation) = activeDraggedPieceAndRotation {
                PieceShapeView(
                    piece: draggedPiece,
                    rotation: draggedRotation,
                    blockSize: cellSize,
                    spacing: cellSpacing,
                    cornerRadius: cellCornerRadius
                )
                .shadow(color: .black.opacity(0.45), radius: 12, y: 6)
                .position(dragLocation)
                .allowsHitTesting(false)
            }
        }
        .coordinateSpace(name: "LUGGAGE_CANVAS")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("OpenSuitCaseChildViewBackground")
                .resizable()
                .overlay {
                    Color.black.opacity(0.5)
                }
                .scaledToFill()
                .ignoresSafeArea()
        )
        .fullScreenCover(isPresented: $isShowingScanner) {
            QRScannerView(session: session, isSuitcase: activeLuggage == .suitcase) { piece, _, weight, _ in
                if let piece = piece, let weight = weight {
                    session.stageScannedPiece(piece, weight: weight, targetLuggage: activeLuggage)
                }
            }
        }
        .onAppear {
            session.captureGridSnapshotIfNeeded()
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
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: .white,
                    borderColor: Color("SuitcaseFrame"),
                    shadowColor: Color("SuitcaseFrame"),
                    foregroundColor: Color("SuitcaseFrame"),
                    cornerRadius: 10,
                    borderWidth: 1.5,
                    shadowOffset: 4,
                    paddingVertical: 8,
                    paddingHorizontal: 12
                )
            )
            
            Spacer()
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
        
        let step = cellSize + cellSpacing
        let pieceWidth = CGFloat(cols) * cellSize + CGFloat(cols - 1) * cellSpacing
        let pieceHeight = CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellSpacing
        
        let pieceTopLeftX = location.x - pieceWidth / 2.0
        let pieceTopLeftY = location.y - pieceHeight / 2.0
        
        let gridOriginX = gridFrame.minX
        let gridOriginY = gridFrame.minY
        
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

// MARK: - Subview: Area Staging Kepingan ("Drag items here to reorganize")
private struct StagingSectionView: View {
    let items: [StagedItem]
    let draggingItemId: UUID?
    let onRotateItem: (StagedItem) -> Void
    let onDragItemChanged: (StagedItem, DragGesture.Value) -> Void
    let onDragItemEnded: (StagedItem, DragGesture.Value) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .foregroundStyle(Color.white.opacity(0.85))
                )
            
            if items.isEmpty {
                Text("Drag items here to reorganize")
                    .font(.shantellSans(14, .regular))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
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
                    .padding(.horizontal, 16)
                }
            }
        }
        .frame(height: 112)
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
#Preview("Suitcase Child View") {
    let session = GameSessionViewModel()
    return PersonalChildView(session: session, initialLuggage: .suitcase)
}

#Preview("Carry-On Child View") {
    let session = GameSessionViewModel()
    return PersonalChildView(session: session, initialLuggage: .carryOn)
}
