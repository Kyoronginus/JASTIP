//
//  JastipOrderCatalog.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 05/11/26.
//

import Foundation

enum JastipOrderCatalog {
    static let allOrders: [JastipOrderModel] = [
        // ==========================================
        // MARK: - LEMBAR 1 (9 KARTU)
        // ==========================================
        
        // 1. Thomas (+4)
        JastipOrderModel(
            orderKey: "thomas",
            customerName: "Thomas",
            points: 4,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "T / L (Unique)")
            ]
        ),
        
        // 2. Toyib (+4)
        JastipOrderModel(
            orderKey: "toyib",
            customerName: "Toyib",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Unique Shape")
            ]
        ),
        
        // 3. Quincy (+4)
        JastipOrderModel(
            orderKey: "quincy",
            customerName: "Quincy",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Unique Shape")
            ]
        ),
        
        // 4. Henry (+5)
        JastipOrderModel(
            orderKey: "henry",
            customerName: "Henry",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino L"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "1 Slot (Single)")
            ]
        ),
        
        // 5. Molly (+4)
        JastipOrderModel(
            orderKey: "molly",
            customerName: "Molly",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square / L / T / I"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square / L / T / I")
            ]
        ),
        
        // 6. Mackenzie (+3)
        JastipOrderModel(
            orderKey: "mackenzie",
            customerName: "Mackenzie",
            points: 3,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Domino (2)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Domino (2)")
            ]
        ),
        
        // 7. Joe (+3)
        JastipOrderModel(
            orderKey: "joe",
            customerName: "Joe",
            points: 3,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Triomino I (3)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "1 Slot (Single)")
            ]
        ),
        
        // 8. Billie (+5)
        JastipOrderModel(
            orderKey: "billie",
            customerName: "Billie",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "4+ Grids"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "4+ Grids")
            ]
        ),
        
        // 9. Jude (+4)
        JastipOrderModel(
            orderKey: "jude",
            customerName: "Jude",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Shape A"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Shape A (Same)")
            ]
        ),

        // ==========================================
        // MARK: - LEMBAR 2 (5 KARTU)
        // ==========================================
        
        // 10. Brie (+5)
        JastipOrderModel(
            orderKey: "brie",
            customerName: "Brie",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "2 / 3 / 4"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square / T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "any")
            ]
        ),
        
        // 11. Bella (+5)
        JastipOrderModel(
            orderKey: "bella",
            customerName: "Bella",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line (2/3/4)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line (2/3/4)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "any")
            ]
        ),
        
        // 12. Roxanne (+4)
        JastipOrderModel(
            orderKey: "roxanne",
            customerName: "Roxanne",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Standard Shape"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Standard Shape")
            ]
        ),
        
        // 13. Diana (+4)
        JastipOrderModel(
            orderKey: "diana",
            customerName: "Diana",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "L / T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line Shape")
            ]
        ),
        
        // 14. Caroline (+5)
        JastipOrderModel(
            orderKey: "caroline",
            customerName: "Caroline",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "<= 2 Grids"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: ">= 5 Grids")
            ]
        ),

        // ==========================================
        // MARK: - LEMBAR 3 (9 KARTU)
        // ==========================================
        
        // 15. Matheo (+5)
        JastipOrderModel(
            orderKey: "matheo_unique",
            customerName: "Matheo",
            points: 5,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "1 Slot (Single)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Unique Shape")
            ]
        ),
        
        // 16. Fernando (+4)
        JastipOrderModel(
            orderKey: "fernando",
            customerName: "Fernando",
            points: 4,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "L / T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "2 / 3 Line")
            ]
        ),
        
        // 17. Alvin (+5)
        JastipOrderModel(
            orderKey: "alvin",
            customerName: "Alvin",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line / Square"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line / Square"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line / Square")
            ]
        ),
        
        // 18. Enzo (+4)
        JastipOrderModel(
            orderKey: "enzo",
            customerName: "Enzo",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square / L / T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square / L / T")
            ]
        ),
        
        // 19. Taylor (+5)
        JastipOrderModel(
            orderKey: "taylor",
            customerName: "Taylor",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "2+ Grids"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "3+ Grids"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "4+ Grids")
            ]
        ),
        
        // 20. Silvia (+5)
        JastipOrderModel(
            orderKey: "silvia",
            customerName: "Silvia",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Same Size"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Same Size"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Same Size")
            ]
        ),
        
        // 21. David (+3)
        JastipOrderModel(
            orderKey: "david",
            customerName: "David",
            points: 3,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square / T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line / L / Unique"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "any")
            ]
        ),
        
        // 22. Jimmy (+5)
        JastipOrderModel(
            orderKey: "jimmy",
            customerName: "Jimmy",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Shape A"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Shape B"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "any")
            ]
        ),
        
        // 23. Wayne (+5)
        JastipOrderModel(
            orderKey: "wayne",
            customerName: "Wayne",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "any"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "any"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Total >= 8")
            ]
        ),

        // ==========================================
        // MARK: - LEMBAR 4 (9 KARTU)
        // ==========================================
        
        // 24. Kevin - Straight (+4)
        JastipOrderModel(
            orderKey: "kevin_straight",
            customerName: "Kevin",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line (2/3/4)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Line (2/3/4)")
            ]
        ),
        
        // 25. Lloyd (+4)
        JastipOrderModel(
            orderKey: "lloyd",
            customerName: "Lloyd",
            points: 4,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino L"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino L")
            ]
        ),
        
        // 26. Kevin - Square (+4)
        JastipOrderModel(
            orderKey: "kevin_square",
            customerName: "Kevin",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square (2x2)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Square (2x2)")
            ]
        ),
        
        // 27. Elliot (+5)
        JastipOrderModel(
            orderKey: "elliot",
            customerName: "Elliot",
            points: 5,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino L")
            ]
        ),
        
        // 28. Jake (+5)
        JastipOrderModel(
            orderKey: "jake",
            customerName: "Jake",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: ">= 4 Grids"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: ">= 4 Grids")
            ]
        ),
        
        // 29. Leon (+4)
        JastipOrderModel(
            orderKey: "leon",
            customerName: "Leon",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Domino / Triomino"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Domino / Triomino")
            ]
        ),
        
        // 30. Matheo - Tetris T (+4)
        JastipOrderModel(
            orderKey: "matheo_tetris_t",
            customerName: "Matheo",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino T"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Tetromino T")
            ]
        ),
        
        // 31. Pixie (+5)
        JastipOrderModel(
            orderKey: "pixie",
            customerName: "Pixie",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Store A (1/2)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Store B (1/2)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "Store C (1/2)")
            ]
        ),
        
        // 32. Minnie (+4)
        JastipOrderModel(
            orderKey: "minnie",
            customerName: "Minnie",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "1 Slot (Single)"),
                JastipRequirementItem(requirementImage: "itemui", shapeDescription: "1 Slot (Single)")
            ]
        )
    ]

    
    // MARK: - Logic Validator Berbasis PieceModel (32 Kasus)
    static func checkOrderCompletion(orderKey: String, items: [PieceModel]) -> Bool {
        switch orderKey {
        // --- 1. Thomas ---
        case "thomas":
            return items.contains { ($0.color == .blue || $0.color == .green) && $0.isAnomaly }
            
        // --- 2. Toyib ---
        case "toyib":
            return items.contains { ($0.color == .yellow || $0.color == .pink) && $0.isAnomaly }
            
        // --- 3. Quincy ---
        case "quincy":
            return items.contains { ($0.color == .blue || $0.color == .red) && $0.isAnomaly }
            
        // --- 4. Henry ---
        case "henry":
            let hasRedL = items.contains { $0.color == .red && $0.shape == .tetrominoL }
            let hasNonRedSingle = items.contains { $0.color != .red && $0.shape == .single }
            return hasRedL && hasNonRedSingle
            
        // --- 5. Molly ---
        case "molly":
            let validShapes: [PieceShape] = [.square, .tetrominoL, .tetrominoT, .tetrominoI]
            return items.filter { $0.color == .yellow && validShapes.contains($0.shape) }.count >= 2
            
        // --- 6. Mackenzie ---
        case "mackenzie":
            return items.filter { $0.shape == .domino && ($0.color == .blue || $0.color == .green) }.count >= 2
            
        // --- 7. Joe ---
        case "joe":
            let hasTriomino = items.contains { [.red, .pink, .blue, .green].contains($0.color) && $0.shape == .triominoI }
            let hasSingleYellow = items.contains { $0.color == .yellow && $0.shape == .single }
            return hasTriomino && hasSingleYellow
            
        // --- 8. Billie ---
        case "billie":
            let targetItems = items.filter { $0.color == .yellow || $0.color == .pink }
            guard targetItems.count >= 2 else { return false }
            for i in 0..<targetItems.count {
                for j in (i + 1)..<targetItems.count {
                    if targetItems[i].gridCount + targetItems[j].gridCount >= 8 { return true }
                }
            }
            return false
            
        // --- 9. Jude ---
        case "jude":
            guard items.count >= 2 else { return false }
            for i in 0..<items.count {
                for j in (i + 1)..<items.count {
                    if items[i].color != items[j].color && items[i].shape == items[j].shape { return true }
                }
            }
            return false
            
        // --- 10. Brie ---
        case "brie":
            let greenItems = items.filter { $0.color == .green }
            guard greenItems.count >= 3 else { return false }
            let lineShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
            let tOrSquare: [PieceShape] = [.tetrominoT, .square]
            let hasLine = greenItems.contains { lineShapes.contains($0.shape) }
            let hasTOrSq = greenItems.contains { tOrSquare.contains($0.shape) }
            return hasLine && hasTOrSq
            
        // --- 11. Bella ---
        case "bella":
            let redItems = items.filter { $0.color == .red }
            guard redItems.count >= 3 else { return false }
            let lineShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
            return redItems.filter { lineShapes.contains($0.shape) }.count >= 2
            
        // --- 12. Roxanne ---
        case "roxanne":
            let validShapes: [PieceShape] = [.domino, .triominoI, .tetrominoT, .tetrominoL, .square]
            return items.filter { ($0.color == .blue || $0.color == .green) && validShapes.contains($0.shape) }.count >= 2
            
        // --- 13. Diana ---
        case "diana":
            let pool = items.filter { $0.color == .yellow || $0.color == .red }
            guard pool.count >= 2 else { return false }
            let hasLT = pool.contains { $0.shape == .tetrominoL || $0.shape == .tetrominoT }
            let hasLine = pool.contains { $0.shape == .domino || $0.shape == .triominoI || $0.shape == .tetrominoI }
            return hasLT && hasLine
            
        // --- 14. Caroline ---
        case "caroline":
            guard items.count >= 2 else { return false }
            for i in 0..<items.count {
                for j in (i + 1)..<items.count {
                    if items[i].color == items[j].color {
                        let sizes = [items[i].gridCount, items[j].gridCount]
                        if sizes.contains(where: { $0 <= 2 }) && sizes.contains(where: { $0 >= 5 }) { return true }
                    }
                }
            }
            return false
            
        // --- 15. Matheo (Unique) ---
        case "matheo_unique":
            let hasSingle = items.contains { $0.shape == .single }
            let hasUnique = items.contains { $0.isAnomaly }
            return hasSingle && hasUnique
            
        // --- 16. Fernando ---
        case "fernando":
            let pool = items.filter { $0.color == .red || $0.color == .pink }
            guard pool.count >= 2 else { return false }
            let hasLT = pool.contains { $0.shape == .tetrominoL || $0.shape == .tetrominoT }
            let hasLine = pool.contains { $0.shape == .domino || $0.shape == .triominoI }
            return hasLT && hasLine
            
        // --- 17. Alvin ---
        case "alvin":
            let validShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI, .square]
            return items.filter { validShapes.contains($0.shape) }.count >= 3
            
        // --- 18. Enzo ---
        case "enzo":
            let validShapes: [PieceShape] = [.square, .tetrominoL, .tetrominoT]
            return items.filter { ($0.color == .blue || $0.color == .green) && validShapes.contains($0.shape) }.count >= 2
            
        // --- 19. Taylor ---
        case "taylor":
            guard items.count >= 3 else { return false }
            for i in 0..<items.count {
                for j in 0..<items.count where j != i {
                    for k in 0..<items.count where k != i && k != j {
                        if items[i].gridCount >= 2 && items[j].gridCount >= 3 && items[k].gridCount >= 4 {
                            return true
                        }
                    }
                }
            }
            return false
            
        // --- 20. Silvia ---
        case "silvia":
            let grouped = Dictionary(grouping: items, by: { $0.gridCount })
            return grouped.values.contains { $0.count >= 3 }
            
        // --- 21. David ---
        case "david":
            let blueItems = items.filter { $0.color == .blue }
            guard blueItems.count >= 3 else { return false }
            let hasSqOrT = blueItems.contains { $0.shape == .square || $0.shape == .tetrominoT }
            let hasLongOrUnique = blueItems.contains { $0.shape == .tetrominoI || $0.shape == .smallL || $0.isAnomaly }
            return hasSqOrT && hasLongOrUnique
            
        // --- 22. Jimmy ---
        case "jimmy":
            let pinkItems = items.filter { $0.color == .pink }
            guard pinkItems.count >= 3 else { return false }
            let distinctShapes = Set(pinkItems.map { $0.shape })
            return distinctShapes.count >= 2
            
        // --- 23. Wayne ---
        case "wayne":
            let yellowItems = items.filter { $0.color == .yellow }
            guard yellowItems.count >= 3 else { return false }
            return yellowItems.reduce(0) { $0 + $1.gridCount } >= 8
            
        // --- 24. Kevin (Straight) ---
        case "kevin_straight":
            let validShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
            return items.filter { ($0.color == .blue || $0.color == .red) && validShapes.contains($0.shape) }.count >= 2
            
        // --- 25. Lloyd ---
        case "lloyd":
            return items.filter { ($0.color == .yellow || $0.color == .pink) && $0.shape == .tetrominoL }.count >= 2
            
        // --- 26. Kevin (Square) ---
        case "kevin_square":
            return items.filter { ($0.color == .yellow || $0.color == .green) && $0.shape == .square }.count >= 2
            
        // --- 27. Elliot ---
        case "elliot":
            let pool = items.filter { $0.color == .green || $0.color == .pink }
            let hasT = pool.contains { $0.shape == .tetrominoT }
            let hasL = pool.contains { $0.shape == .tetrominoL }
            return hasT && hasL
            
        // --- 28. Jake ---
        case "jake":
            return items.filter { ($0.color == .pink || $0.color == .yellow) && $0.gridCount >= 4 }.count >= 2
            
        // --- 29. Leon ---
        case "leon":
            return items.filter { $0.color == .yellow && ($0.shape == .domino || $0.shape == .triominoI) }.count >= 2
            
        // --- 30. Matheo (Tetris T) ---
        case "matheo_tetris_t":
            return items.filter { $0.shape == .tetrominoT }.count >= 2
            
        // --- 31. Pixie ---
        case "pixie":
            let smallItems = items.filter { $0.shape == .single || $0.shape == .domino }
            let distinctStores = Set(smallItems.map { $0.color })
            return distinctStores.count >= 3
            
        // --- 32. Minnie ---
        case "minnie":
            return items.filter { ($0.color == .pink || $0.color == .yellow) && $0.shape == .single }.count >= 2
            
        default:
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    /// Mengambil 3 order acak untuk Shared Objective di awal game
    static func getRandomSharedOrders(count: Int = 3) -> [JastipOrderModel] {
        Array(allOrders.shuffled().prefix(count))
    }
    
    /// Mengambil 3 opsi kartu untuk proses drafting personal objective (tidak boleh duplikat dengan yang sudah ada)
    static func getDraftOrders(count: Int = 3, excludingIds: Set<String> = []) -> [JastipOrderModel] {
        let available = allOrders.filter { !excludingIds.contains($0.id) }
        return Array(available.shuffled().prefix(count))
    }
}
