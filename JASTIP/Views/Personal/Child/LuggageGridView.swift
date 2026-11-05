//
//  LuggageGridView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 05/11/26.
//

import SwiftUI

struct LuggageGridView: View {
    let grid: LuggageGridModel
    var cellSize: CGFloat = 72
    var hoverCoords: [GridCoordinate]? = nil
    var isHoverValid: Bool = false
    var draggingPieceId: UUID? = nil
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
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<grid.height, id: \.self) { y in
                HStack(spacing: 4) {
                    ForEach(0..<grid.width, id: \.self) { x in
                        let coord = GridCoordinate(x: x, y: y)
                        let occupiedEntry = cellPieceMap[coord]
                        
                        LuggageCellView(
                            size: cellSize,
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("NavyBlack").opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color("TaxiYellow").opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Subview: Satuan Sel Kotak Koper
private struct LuggageCellView: View {
    let size: CGFloat
    let occupied: (placedPiece: PlacedPiece, piece: PieceModel)?
    let isBeingDragged: Bool
    let isHovered: Bool
    let isHoverValid: Bool
    let onDoubleTap: () -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        ZStack {
            // 1. Kotak Sel Kosong
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            
            // 2. Kepingan Terpasang
            if let (_, piece) = occupied {
                RoundedRectangle(cornerRadius: 10)
                    .fill(piece.color.displayColor.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(piece.color.displayColor, lineWidth: 2)
                    )
                    .opacity(isBeingDragged ? 0.15 : 1.0)
                    .gesture(
                        DragGesture(minimumDistance: 6, coordinateSpace: .named("LUGGAGE_CANVAS"))
                            .onChanged(onDragChanged)
                            .onEnded(onDragEnded)
                    )
                    .onTapGesture(count: 2) {
                        onDoubleTap()
                    }
            }
            
            // 3. Hover / Snapping Preview Highlight
            if isHovered {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isHoverValid ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
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
    let smallLPiece = PieceCatalog.allPieces.first(where: { $0.shape == .smallL && $0.color == .yellow })!
    
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
