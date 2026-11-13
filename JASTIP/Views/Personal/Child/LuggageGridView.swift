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
                width: luggageImageSize.width * -0.01,
                height: luggageImageSize.height * -0.01
            )
        } else {
            return CGSize(
                width: luggageImageSize.width * -0.017,
                height: luggageImageSize.height * 0.03
            )
        }
    }
    
    private func neighborFlags(at coord: GridCoordinate, for placedPiece: PlacedPiece) -> PieceCellNeighbors {
        func isSamePiece(_ dx: Int, _ dy: Int) -> Bool {
            cellPieceMap[GridCoordinate(x: coord.x + dx, y: coord.y + dy)]?.0.id == placedPiece.id
        }
        return PieceCellNeighbors(
            top: isSamePiece(0, -1),
            bottom: isSamePiece(0, 1),
            left: isSamePiece(-1, 0),
            right: isSamePiece(1, 0),
            topRight: isSamePiece(1, -1),
            bottomLeft: isSamePiece(-1, 1),
            bottomRight: isSamePiece(1, 1)
        )
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
                            let neighbors = occupiedEntry.map { neighborFlags(at: coord, for: $0.0) } ?? PieceCellNeighbors()
                            
                            LuggageCellView(
                                size: cellSize,
                                spacing: cellSpacing,
                                cornerRadius: cellCornerRadius,
                                emptyColor: emptyCellColor,
                                isInteractive: isInteractive,
                                occupied: occupiedEntry,
                                neighbors: neighbors,
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

// MARK: - Informasi Tetangga Sel dari Piece yang Sama
private struct PieceCellNeighbors {
    var top: Bool = false
    var bottom: Bool = false
    var left: Bool = false
    var right: Bool = false
    var topRight: Bool = false
    var bottomLeft: Bool = false
    var bottomRight: Bool = false
}

// MARK: - Subview: Satuan Sel Kotak Koper
private struct LuggageCellView: View {
    let size: CGFloat
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let emptyColor: Color
    let isInteractive: Bool
    let occupied: (placedPiece: PlacedPiece, piece: PieceModel)?
    let neighbors: PieceCellNeighbors
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
            
            // 2. Kepingan Terpasang (dengan penyambung antar-sel piece yang sama & outer contour gelap)
            if let (_, piece) = occupied {
                let pieceVisual = ZStack {
                    PieceCellFillShape(
                        cornerRadius: cornerRadius,
                        spacing: spacing,
                        neighbors: neighbors
                    )
                    .fill(piece.color.displayColor.opacity(0.92))
                    
                    PieceCellInnerGridShape(
                        spacing: spacing,
                        neighbors: neighbors
                    )
                    .stroke(Color.black.opacity(0.24), lineWidth: isInteractive ? 1.2 : 0.8)
                    
                    PieceCellOuterContourShape(
                        cornerRadius: cornerRadius,
                        spacing: spacing,
                        neighbors: neighbors
                    )
                    .stroke(
                        Color("SuitcaseFrame"),
                        style: StrokeStyle(
                            lineWidth: isInteractive ? 3.2 : 1.8,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
                
                if isInteractive {
                    pieceVisual
                        .opacity(isBeingDragged ? 0.15 : 1.0)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 6, coordinateSpace: .named("LUGGAGE_CANVAS"))
                                .onChanged(onDragChanged)
                                .onEnded(onDragEnded)
                        )
                        .onTapGesture() {
                            onDoubleTap()
                        }
                } else {
                    pieceVisual
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

// MARK: - Shape: Area Isi Sel + Jembatan Antar-Sel dalam Piece yang Sama
private struct PieceCellFillShape: Shape {
    let cornerRadius: CGFloat
    let spacing: CGFloat
    let neighbors: PieceCellNeighbors
    
    func path(in rect: CGRect) -> Path {
        let s = rect.width
        let r = min(cornerRadius, s / 2)
        
        let tl = (!neighbors.top && !neighbors.left) ? r : 0
        let tr = (!neighbors.top && !neighbors.right) ? r : 0
        let br = (!neighbors.bottom && !neighbors.right) ? r : 0
        let bl = (!neighbors.bottom && !neighbors.left) ? r : 0
        
        var path = Path()
        
        // Kotak sel utama dengan sudut membulat hanya di sudut luar piece
        path.move(to: CGPoint(x: tl, y: 0))
        path.addLine(to: CGPoint(x: s - tr, y: 0))
        if tr > 0 {
            path.addArc(
                center: CGPoint(x: s - tr, y: tr),
                radius: tr,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: s, y: s - br))
        if br > 0 {
            path.addArc(
                center: CGPoint(x: s - br, y: s - br),
                radius: br,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: bl, y: s))
        if bl > 0 {
            path.addArc(
                center: CGPoint(x: bl, y: s - bl),
                radius: bl,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: 0, y: tl))
        if tl > 0 {
            path.addArc(
                center: CGPoint(x: tl, y: tl),
                radius: tl,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        }
        path.closeSubpath()
        
        // Jembatan horizontal ke sel kanan jika milik piece yang sama
        if neighbors.right {
            path.addRect(CGRect(x: s - 0.5, y: 0, width: spacing + 1.0, height: s))
        }
        
        // Jembatan vertikal ke sel bawah jika milik piece yang sama
        if neighbors.bottom {
            path.addRect(CGRect(x: 0, y: s - 0.5, width: s, height: spacing + 1.0))
        }
        
        // Jembatan sudut tengah jika membentuk blok 2x2
        if neighbors.right && neighbors.bottom && neighbors.bottomRight {
            path.addRect(CGRect(x: s - 0.5, y: s - 0.5, width: spacing + 1.0, height: spacing + 1.0))
        }
        
        return path
    }
}

// MARK: - Shape: Garis Grid Tipis di Dalam Piece yang Sama
private struct PieceCellInnerGridShape: Shape {
    let spacing: CGFloat
    let neighbors: PieceCellNeighbors
    
    func path(in rect: CGRect) -> Path {
        let s = rect.width
        var path = Path()
        
        if neighbors.right {
            let midX = s + spacing / 2.0
            path.move(to: CGPoint(x: midX, y: 2))
            path.addLine(to: CGPoint(x: midX, y: s - 2))
        }
        
        if neighbors.bottom {
            let midY = s + spacing / 2.0
            path.move(to: CGPoint(x: 2, y: midY))
            path.addLine(to: CGPoint(x: s - 2, y: midY))
        }
        
        return path
    }
}

// MARK: - Shape: Garis Tepi Luar (Outer Contour) Utuh Mengelilingi Piece
private struct PieceCellOuterContourShape: Shape {
    let cornerRadius: CGFloat
    let spacing: CGFloat
    let neighbors: PieceCellNeighbors
    
    func path(in rect: CGRect) -> Path {
        let s = rect.width
        let r = min(cornerRadius, s / 2)
        var path = Path()
        
        // Sisi Atas
        if !neighbors.top {
            let startX = neighbors.left ? 0 : r
            let endX = neighbors.right ? s : (s - r)
            path.move(to: CGPoint(x: startX, y: 0))
            path.addLine(to: CGPoint(x: endX, y: 0))
        }
        
        // Sisi Bawah
        if !neighbors.bottom {
            let startX = neighbors.left ? 0 : r
            let endX = neighbors.right ? s : (s - r)
            path.move(to: CGPoint(x: startX, y: s))
            path.addLine(to: CGPoint(x: endX, y: s))
        }
        
        // Sisi Kiri
        if !neighbors.left {
            let startY = neighbors.top ? 0 : r
            let endY = neighbors.bottom ? s : (s - r)
            path.move(to: CGPoint(x: 0, y: startY))
            path.addLine(to: CGPoint(x: 0, y: endY))
        }
        
        // Sisi Kanan
        if !neighbors.right {
            let startY = neighbors.top ? 0 : r
            let endY = neighbors.bottom ? s : (s - r)
            path.move(to: CGPoint(x: s, y: startY))
            path.addLine(to: CGPoint(x: s, y: endY))
        }
        
        // 4 Sudut Luar (Convex Corners)
        if !neighbors.top && !neighbors.left {
            path.move(to: CGPoint(x: 0, y: r))
            path.addArc(
                center: CGPoint(x: r, y: r),
                radius: r,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        }
        
        if !neighbors.top && !neighbors.right {
            path.move(to: CGPoint(x: s - r, y: 0))
            path.addArc(
                center: CGPoint(x: s - r, y: r),
                radius: r,
                startAngle: .degrees(270),
                endAngle: .degrees(360),
                clockwise: false
            )
        }
        
        if !neighbors.bottom && !neighbors.right {
            path.move(to: CGPoint(x: s, y: s - r))
            path.addArc(
                center: CGPoint(x: s - r, y: s - r),
                radius: r,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        }
        
        if !neighbors.bottom && !neighbors.left {
            path.move(to: CGPoint(x: r, y: s))
            path.addArc(
                center: CGPoint(x: r, y: s - r),
                radius: r,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        }
        
        // Sisi Luar pada Jembatan Horizontal ke Sel Kanan
        if neighbors.right {
            if !(neighbors.top && neighbors.topRight) {
                path.move(to: CGPoint(x: s, y: 0))
                path.addLine(to: CGPoint(x: s + spacing, y: 0))
            }
            if !(neighbors.bottom && neighbors.bottomRight) {
                path.move(to: CGPoint(x: s, y: s))
                path.addLine(to: CGPoint(x: s + spacing, y: s))
            }
        }
        
        // Sisi Luar pada Jembatan Vertikal ke Sel Bawah
        if neighbors.bottom {
            if !(neighbors.left && neighbors.bottomLeft) {
                path.move(to: CGPoint(x: 0, y: s))
                path.addLine(to: CGPoint(x: 0, y: s + spacing))
            }
            if !(neighbors.right && neighbors.bottomRight) {
                path.move(to: CGPoint(x: s, y: s))
                path.addLine(to: CGPoint(x: s, y: s + spacing))
            }
        }
        
        return path
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
