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
            orderKey: "kayden",
            customerName: "Kayden",
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
            orderKey: "hannah",
            customerName: "Hannah",
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
            return items.contains { ($0.color == .green || $0.color == .blue) && $0.isAnomaly }
            
        // --- 2. Toyib ---
        case "toyib":
            return items.contains { ($0.color == .red || $0.color == .orange) && $0.isAnomaly }
            
        // --- 3. Quincy ---
        case "quincy":
            return items.contains { ($0.color == .green || $0.color == .purple) && $0.isAnomaly }
            
        // --- 4. Henry ---
        case "henry":
            let hasPurpleAnomaly = items.contains { ($0.color == .purple) && $0.isAnomaly }
            let hasNonPurpleSingleOrDomino = items.contains {
                $0.color != .purple && ($0.shape == .single || $0.shape == .domino)
            }
            return hasNonPurpleSingleOrDomino && hasPurpleAnomaly
            
        // --- 5. Molly ---
        case "molly":
            let shape1 = items.contains { $0.color == .orange && ($0.shape == .square ) }
            let shape2 = items.contains { $0.color == .orange && ($0.shape == .tetrominoT ) }
            return shape1 && shape2
            
        // --- 6. Mackenzie ---
        case "mackenzie":
            return items.filter { $0.shape == .domino && ($0.color == .green || $0.color == .blue) }.count >= 2
            
        // --- 7. Joe ---
        case "joe":
            let hasTetrominoI = items.contains { [.purple, .red, .green, .blue].contains($0.color) && $0.shape == .tetrominoI }
            let hasSingleOrange = items.contains { $0.color == .orange && $0.shape == .single }
            return hasSingleOrange && hasTetrominoI
            
        // --- 8. Billie ---
        case "billie":
            let shape1 = items.contains { $0.color == .orange && ($0.shape == .square || $0.shape == .tetrominoT) }
            let shape2 = items.contains { $0.color == .orange && ($0.shape == .smallL || $0.shape == .tetrominoL ) }
            return shape1 && shape2
            
        // --- 9. Jude ---
        case "jude":
            let shape1 = items.contains { $0.color == .blue && ($0.shape == .smallL || $0.shape == .tetrominoL) }
            let shape2 = items.contains { $0.color == .orange && ($0.shape == .smallL || $0.shape == .tetrominoL ) }
            return shape1 && shape2
            
        // --- 10. Brie ---
        case "brie":
            let blueItems = items.filter { $0.color == .blue }
            guard blueItems.count >= 3 else { return false }
            let lineShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
            let tOrSquare: [PieceShape] = [.tetrominoT, .square]
            let hasLine = blueItems.contains { lineShapes.contains($0.shape) }
            let hasTOrSq = blueItems.contains { tOrSquare.contains($0.shape) }
            return hasLine && hasTOrSq
            
        // --- 11. Bella ---
        case "bella":
            let purpleItems = items.filter { $0.color == .purple }
            guard purpleItems.count >= 3 else { return false }
            let lineShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
            return purpleItems.filter { lineShapes.contains($0.shape) }.count >= 2
            
        // --- 12. Roxanne ---
        case "roxanne":
            let shape1 = items.contains { ($0.color == .blue || $0.color == .green) && ($0.shape == .square || $0.shape == .tetrominoT) }
            let shape2 = items.contains { ($0.color == .blue || $0.color == .green) && ($0.shape == .triominoI || $0.shape == .smallL) }
            return shape1 && shape2
            
        // --- 13. Diana ---
        case "diana":
            let pool = items.filter { $0.color == .orange || $0.color == .purple }
            guard pool.count >= 2 else { return false }
            let hasSqT = pool.contains { $0.shape == .square || $0.shape == .tetrominoT }
            let hasLine = pool.contains { $0.shape == .domino || $0.shape == .triominoI || $0.shape == .tetrominoI }
            return hasLine && hasSqT
            
        // --- 14. Caroline ---
        case "caroline":
            let hasBlueAnomaly = items.contains { ($0.color == .blue) && $0.isAnomaly }
            let hasBlueSingleOrDomino = items.contains {
                $0.color != .blue && ($0.shape == .single || $0.shape == .domino)
            }
            return hasBlueSingleOrDomino && hasBlueAnomaly
            
        // --- 15. Kayden ---
        case "kayden":
            let hasSingle = items.contains { $0.shape == .single }
            let hasUnique = items.contains { $0.isAnomaly }
            return hasUnique && hasSingle
            
        // --- 16. Fernando ---
        case "fernando":
            let pool = items.filter { $0.color == .purple || $0.color == .red }
            guard pool.count >= 2 else { return false }
            let hasLT = pool.contains { $0.shape == .tetrominoL || $0.shape == .smallL || $0.shape == .tetrominoT }
            let hasLine = pool.contains { $0.shape == .triominoI || $0.shape == .tetrominoI }
            return hasLine && hasLT
            
        // --- 17. Alvin ---
        case "alvin":
            let shape1 = items.contains { $0.color == .blue && ($0.shape == .single || $0.shape == .domino) }
            let shape2 = items.contains { ($0.color == .red || $0.color == .orange) && ($0.shape == .single || $0.shape == .domino) }
            let shape3 = items.contains { ($0.color == .purple || $0.color == .green) && ($0.shape == .triominoI || $0.shape == .tetrominoI) }
            return shape1 && shape2 && shape3
            
        // --- 18. Enzo ---
        case "enzo":
            let shape1 = items.contains { ($0.color == .blue || $0.color == .green) && $0.shape == .square }
            let shape2 = items.contains { ($0.color == .blue || $0.color == .green) && ($0.shape == .smallL || $0.shape == .tetrominoL || $0.shape == .tetrominoT) }
            return shape1 && shape2
            
        // --- 19. Taylor ---
        case "taylor":
            let shape1 = items.contains { $0.color == .blue && $0.shape == .domino }
            let shape2 = items.contains { ($0.color == .red || $0.color == .orange) && ($0.shape == .smallL || $0.shape == .tetrominoL || $0.shape == .tetrominoT) }
            let shape3 = items.contains { ($0.color == .purple || $0.color == .green) && ($0.shape == .square || $0.shape == .tetrominoI) }
            return shape1 && shape2 && shape3
            
        // --- 20. Silvia ---
        case "silvia":
            let shape1 = items.contains { $0.color == .blue && ($0.shape == .triominoI || $0.shape == .smallL) }
            let shape2 = items.contains { ($0.color == .red || $0.color == .orange) && ($0.shape == .triominoI || $0.shape == .smallL) }
            let shape3 = items.contains { ($0.color == .purple || $0.color == .green) && ($0.shape == .triominoI || $0.shape == .smallL) }
            return shape1 && shape2 && shape3
            
        // --- 21. David ---
        case "david":
            let greenItems = items.filter { $0.color == .green }
            guard greenItems.count >= 3 else { return false }
            let hasSqOrT = greenItems.contains { $0.shape == .square }
            return hasSqOrT
            
        // --- 22. Jimmy ---
        case "jimmy":
            let redItems = items.filter { $0.color == .red }
            guard redItems.count >= 3 else { return false }
            let shape1 = redItems.contains { $0.shape == .triominoI || $0.shape == .tetrominoI }
            let shape2 = redItems.contains { $0.shape == .square || $0.shape == .tetrominoT }

            return shape1 && shape2
            
        // --- 23. Wayne ---
        case "wayne":
            let orangeItems = items.filter { $0.color == .orange }
            guard orangeItems.count >= 3 else { return false }
            let shape1 = orangeItems.contains { $0.shape == .square || $0.shape == .tetrominoT }
            let shape2 = orangeItems.contains { $0.shape == .triominoI || $0.shape == .smallL }

            return shape1 && shape2
            
        // --- 24. Kevin (Straight) ---
        case "kevin_straight":
            let validShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
            return items.filter { ($0.color == .green || $0.color == .purple) && validShapes.contains($0.shape) }.count >= 2
            
        // --- 25. Lloyd ---
        case "lloyd":
            return items.filter { ($0.color == .orange || $0.color == .red) && $0.shape == .tetrominoL }.count >= 2
            
        // --- 26. hannah ---
        case "hannah":
            return items.filter { ($0.color == .orange || $0.color == .blue) && $0.shape == .square }.count >= 2
            
        // --- 27. Elliot ---
        case "elliot":
            let pool = items.filter { $0.color == .blue || $0.color == .red }
            let hasT = pool.contains { $0.shape == .tetrominoT }
            let hasL = pool.contains { $0.shape == .tetrominoL || $0.shape == .smallL }
            return hasL && hasT
            
        // --- 28. Jake ---
        case "jake":
            let shape1 = items.contains { $0.color == .red && $0.shape == .square }
            let shape2 = items.contains { $0.color == .green && $0.shape == .tetrominoT }
            return shape1 && shape2
            
        // --- 29. Leon ---
        case "leon":
            return items.filter { $0.color == .orange && ($0.shape == .triominoI || $0.shape == .tetrominoI) }.count >= 2
            
        // --- 30. Matheo (Tetris T) ---
        case "matheo_tetris_t":
            return items.filter { $0.shape == .tetrominoT }.count >= 2
            
        // --- 31. Pixie ---
        case "pixie":
            let shape1 = items.contains { ($0.color == .red || $0.color == .orange) && ($0.shape == .single || $0.shape == .domino) }
            let shape2 = items.contains { ($0.color == .purple || $0.color == .green) && ($0.shape == .single || $0.shape == .domino) }
            let shape3 = items.contains { $0.color == .blue && ($0.shape == .single || $0.shape == .domino) }
            
            return shape1 && shape2 && shape3
            
        // --- 32. Minnie ---
        case "minnie":
            return items.filter { ($0.color == .red || $0.color == .orange) && $0.shape == .single }.count >= 2
            
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
