//
//  LuggageGridView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

import SwiftUI

struct LuggageGridView: View {
    let grid: LuggageGridModel
    var cellSize: CGFloat = 68
    var cellSpacing: CGFloat = 4
    var cellCornerRadius: CGFloat = 10
    var isInteractive: Bool = true
    var hoverCoords: [GridCoordinate]? = nil
    var isHoverValid: Bool = false
    var draggingPieceId: UUID? = nil
    var onGridFrameChange: ((CGRect) -> Void)? = nil
    var onRotatePiece: ((PlacedPiece) -> Void)? = nil
    var onDragPieceChanged: ((PlacedPiece, GridCoordinate, DragGesture.Value) -> Void)? = nil
    var onDragPieceEnded: ((PlacedPiece, DragGesture.Value) -> Void)? = nil
    
    // Pemetaan sel mana yang diisi oleh kepingan apa
    private var cellPieceMap: [GridCoordinate: (PlacedPiece, PieceModel)] {
        var map: [GridCoordinate: (PlacedPiece, PieceModel)] = [:]
        for placed in grid.placedPieces {
            let coords = LuggagePlacementEngine.absoluteCoordinates(
                for: placed.piece,
                at: placed.origin,
                rotation: placed.rotation
            )
            for c in coords {
                map[c] = (placed, placed.piece)
            }
        }
        return map
    }
    
    private var gridWidth: CGFloat {
        CGFloat(grid.width) * cellSize + CGFloat(grid.width - 1) * cellSpacing
    }
    
    private var gridHeight: CGFloat {
        CGFloat(grid.height) * cellSize + CGFloat(grid.height - 1) * cellSpacing
    }
    
    private var luggageImageName: String {
        grid.type == .suitcase ? "Suitcase" : "Carryon"
    }
    
    private var emptyCellColor: Color {
        grid.type == .suitcase ? Color("SuitcaseGrid") : Color("CarryonGrid")
    }
    
    private var luggageImageSize: CGSize {
        if grid.type == .suitcase {
            return CGSize(width: gridWidth / 0.76, height: gridHeight / 0.80)
        } else {
            return CGSize(width: gridWidth / 0.77, height: gridHeight / 0.74)
        }
    }
    
    private var gridCenterOffset: CGSize {
        if grid.type == .suitcase {
            return CGSize(
                width: luggageImageSize.width * -0.017,
                height: luggageImageSize.height * -0.01
            )
        } else {
            return CGSize(
                width: luggageImageSize.width * -0.017,
                height: luggageImageSize.height * 0.03
            )
        }
    }

    var body: some View {
        ZStack {
            // Layer Bawah: Aset Koper (Suitcase / Carryon)
            Image(luggageImageName)
                .resizable()
                .frame(width: luggageImageSize.width, height: luggageImageSize.height)
            
            // Layer Atas: Grid Sel dengan Inner Shadow + Image Piece Overlay + Hover Highlight
            ZStack(alignment: .topLeading) {
                VStack(spacing: cellSpacing) {
                    ForEach(0..<grid.height, id: \.self) { y in
                        HStack(spacing: cellSpacing) {
                            ForEach(0..<grid.width, id: \.self) { x in
                                let coord = GridCoordinate(x: x, y: y)
                                let occupiedEntry = cellPieceMap[coord]

                                LuggageCellView(
                                    size: cellSize,
                                    cornerRadius: cellCornerRadius,
                                    emptyColor: emptyCellColor,
                                    isInteractive: isInteractive,
                                    isOccupied: occupiedEntry != nil,
                                    onDoubleTap: {
                                        if let (placed, _) = occupiedEntry {
                                            onRotatePiece?(placed)
                                        }
                                    },
                                    onDragChanged: { value in
                                        if let (placed, _) = occupiedEntry {
                                            let grabbedCell = GridCoordinate(
                                            x: coord.x - placed.origin.x,
                                            y: coord.y - placed.origin.y
                                        )
                                        onDragPieceChanged?(placed, grabbedCell, value)
                                        }
                                    },
                                    onDragEnded: { value in
                                        if let (placed, _) = occupiedEntry {
                                            onDragPieceEnded?(placed, value)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }

                // Visual PNG Kepingan Terpasang (Hit-testing disabled agar tap/drag tetap tembus ke sel grid)
                ForEach(grid.placedPieces) { placed in
                    let base = PieceCatalog.baseCoordinates(for: placed.piece.shape, pieceId: placed.piece.id)
                    let rotated = LuggagePlacementEngine.rotate(coordinates: base, by: placed.rotation)
                    let cols = (rotated.map(\.x).max() ?? 0) + 1
                    let rows = (rotated.map(\.y).max() ?? 0) + 1
                    let step = cellSize + cellSpacing
                    let pieceWidth = CGFloat(cols) * cellSize + CGFloat(max(0, cols - 1)) * cellSpacing
                    let pieceHeight = CGFloat(rows) * cellSize + CGFloat(max(0, rows - 1)) * cellSpacing

                    PieceShapeView(
                        piece: placed.piece,
                        rotation: placed.rotation,
                        blockSize: cellSize,
                        spacing: cellSpacing,
                        cornerRadius: cellCornerRadius
                    )
                    .opacity(placed.id == draggingPieceId ? 0.15 : 1.0)
                    .position(
                        x: CGFloat(placed.origin.x) * step + pieceWidth / 2,
                        y: CGFloat(placed.origin.y) * step + pieceHeight / 2
                    )
                    .allowsHitTesting(false)
                }

                // Hover / Snapping Preview Highlight di paling atas
                if let hoverCoords {
                    let step = cellSize + cellSpacing
                    ForEach(hoverCoords, id: \.self) { coord in
                        if coord.x >= 0 && coord.x < grid.width && coord.y >= 0 && coord.y < grid.height {
                            RoundedRectangle(cornerRadius: cellCornerRadius)
                                .fill(isHoverValid ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: cellCornerRadius)
                                        .stroke(isHoverValid ? Color.green : Color.red, lineWidth: 2.5)
                                )
                                .frame(width: cellSize, height: cellSize)
                                .position(
                                    x: CGFloat(coord.x) * step + cellSize / 2,
                                    y: CGFloat(coord.y) * step + cellSize / 2
                                )
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
            .frame(width: gridWidth, height: gridHeight)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            onGridFrameChange?(geo.frame(in: .named("LUGGAGE_CANVAS")))
                        }
                        .onChange(of: geo.frame(in: .named("LUGGAGE_CANVAS"))) { _, newFrame in
                            onGridFrameChange?(newFrame)
                        }
                }
            )
            .offset(gridCenterOffset)
        }
    }
}

// MARK: - Subview: Satuan Sel Kotak Koper
private struct LuggageCellView: View {
    let size: CGFloat
    let cornerRadius: CGFloat
    let emptyColor: Color
    let isInteractive: Bool
    let isOccupied: Bool
    let onDoubleTap: () -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        ZStack {
            // 1. Kotak Sel Kosong dengan Inner Shadow
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    emptyColor.shadow(
                        .inner(color: .black.opacity(0.48), radius: 1, x: 0, y: 2)
                    )
                )
            
            // 2. Area Interaksi untuk Kepingan Terpasang
            if isOccupied && isInteractive {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 6, coordinateSpace: .named("LUGGAGE_CANVAS"))
                            .onChanged(onDragChanged)
                            .onEnded(onDragEnded)
                    )
                    .onTapGesture {
                        onDoubleTap()
                    }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Previews
#Preview("Suitcase 3x5 with Pieces") {
    let dominoPiece = PieceCatalog.allPieces.first(where: { $0.shape == .domino && $0.color == .red })!
    let smallLPiece = PieceCatalog.allPieces.first(where: { $0.shape == .smallL && $0.color == .orange })!
    
    var suitcase = LuggageGridModel.suitcase
    suitcase.placedPieces = [
        PlacedPiece(
            id: UUID(),
            piece: dominoPiece,
            origin: GridCoordinate(x: 0, y: 0),
            rotation: .deg0,
            assignedLuggage: .suitcase
        ),
        PlacedPiece(
            id: UUID(),
            piece: smallLPiece,
            origin: GridCoordinate(x: 1, y: 2),
            rotation: .deg90,
            assignedLuggage: .suitcase
        )
    ]
    
    return ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        LuggageGridView(
            grid: suitcase,
            hoverCoords: [GridCoordinate(x: 0, y: 2), GridCoordinate(x: 0, y: 3)],
            isHoverValid: true
        )
    }
}

#Preview("Carry-On 2x2 Empty") {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        LuggageGridView(grid: LuggageGridModel.carryOn)
    }
}
