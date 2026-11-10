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
    var onDragPieceChanged: ((PlacedPiece, DragGesture.Value) -> Void)? = nil
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
                width: luggageImageSize.width * 0.026,
                height: luggageImageSize.height * 0.018
            )
        } else {
            return CGSize(
                width: luggageImageSize.width * 0.001,
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
            
            // Layer Atas: Grid Sel dengan Inner Shadow
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
                                occupied: occupiedEntry,
                                isBeingDragged: occupiedEntry?.0.id == draggingPieceId,
                                isHovered: hoverCoords?.contains(coord) == true,
                                isHoverValid: isHoverValid,
                                onDoubleTap: {
                                    if let (placed, _) = occupiedEntry {
                                        onRotatePiece?(placed)
                                    }
                                },
                                onDragChanged: { value in
                                    if let (placed, _) = occupiedEntry {
                                        onDragPieceChanged?(placed, value)
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
    let occupied: (placedPiece: PlacedPiece, piece: PieceModel)?
    let isBeingDragged: Bool
    let isHovered: Bool
    let isHoverValid: Bool
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
            
            // 2. Kepingan Terpasang
            if let (_, piece) = occupied {
                if isInteractive {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(piece.color.displayColor.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(piece.color.displayColor, lineWidth: 2)
                        )
                        .opacity(isBeingDragged ? 0.15 : 1.0)
                        .gesture(
                            DragGesture(minimumDistance: 6, coordinateSpace: .named("LUGGAGE_CANVAS"))
                                .onChanged(onDragChanged)
                                .onEnded(onDragEnded)
                        )
                        .onTapGesture() {
                            onDoubleTap()
                        }
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(piece.color.displayColor.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(piece.color.displayColor, lineWidth: 1.5)
                        )
                }
            }
            
            // 3. Hover / Snapping Preview Highlight
            if isHovered {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHoverValid ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(isHoverValid ? Color.green : Color.red, lineWidth: 2.5)
                    )
                    .allowsHitTesting(false)
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
