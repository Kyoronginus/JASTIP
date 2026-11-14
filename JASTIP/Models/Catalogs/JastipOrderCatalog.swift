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
        
        // 1. Thomas (+4) -> 1 item (Anomaly Green/Blue)
        JastipOrderModel(
            orderKey: "thomas",
            customerName: "Thomas",
            points: 4,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_thomas", shapeDescription: "Anomaly (Green/Blue)")
            ]
        ),
        
        // 2. Toyib (+4) -> 1 item (Anomaly Red/Orange)
        JastipOrderModel(
            orderKey: "toyib",
            customerName: "Toyib",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_toyib", shapeDescription: "Anomaly (Red/Orange)")
            ]
        ),
        
        // 3. Quincy (+4) -> 1 item (Anomaly Green/Purple)
        JastipOrderModel(
            orderKey: "quincy",
            customerName: "Quincy",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_quincy", shapeDescription: "Anomaly (Green/Purple)")
            ]
        ),
        
        // 4. Henry (+5) -> 2 items (Non-purple Single/Domino & Purple Anomaly)
        JastipOrderModel(
            orderKey: "henry",
            customerName: "Henry",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_henry", shapeDescription: "Non-Purple Single/Domino"),
                JastipRequirementItem(requirementImage: "req_henry2", shapeDescription: "Purple Anomaly")
            ]
        ),
        
        // 5. Molly (+4) -> 2 items (Orange Square & Orange Tetromino T)
        JastipOrderModel(
            orderKey: "molly",
            customerName: "Molly",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_molly", shapeDescription: "Orange Square"),
                JastipRequirementItem(requirementImage: "req_molly2", shapeDescription: "Orange Tetromino T")
            ]
        ),
        
        // 6. Mackenzie (+3) -> 2 items (2x Domino Green/Blue)
        JastipOrderModel(
            orderKey: "mackenzie",
            customerName: "Mackenzie",
            points: 3,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_mackenzie", shapeDescription: "Domino (Green/Blue)"),
                JastipRequirementItem(requirementImage: "req_mackenzie2", shapeDescription: "Domino (Green/Blue)")
            ]
        ),
        
        // 7. Joe (+3) -> 2 items (Single Orange & Tetromino I)
        JastipOrderModel(
            orderKey: "joe",
            customerName: "Joe",
            points: 3,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_joe", shapeDescription: "Single Orange"),
                JastipRequirementItem(requirementImage: "req_joe2", shapeDescription: "Tetromino I")
            ]
        ),
        
        // 8. Billie (+5) -> 2 items (Orange Sq/T & Orange L)
        JastipOrderModel(
            orderKey: "billie",
            customerName: "Billie",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_billie", shapeDescription: "Orange Square / Tetromino T"),
                JastipRequirementItem(requirementImage: "req_billie2", shapeDescription: "Orange Small L / Tetromino L")
            ]
        ),
        
        // 9. Jude (+4) -> 2 items (Blue L & Orange L)
        JastipOrderModel(
            orderKey: "jude",
            customerName: "Jude",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_jude", shapeDescription: "Blue Small L / Tetromino L"),
                JastipRequirementItem(requirementImage: "req_jude2", shapeDescription: "Orange Small L / Tetromino L")
            ]
        ),
        
        // ==========================================
        // MARK: - LEMBAR 2 (5 KARTU)
        // ==========================================
        
        // 10. Brie (+5) -> 3 items (Blue Line, Blue Square/T, Blue Any)
        JastipOrderModel(
            orderKey: "brie",
            customerName: "Brie",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_brie", shapeDescription: "Blue Line (Domino/Triomino/Tetromino)"),
                JastipRequirementItem(requirementImage: "req_brie2", shapeDescription: "Blue Square / Tetromino T"),
                JastipRequirementItem(requirementImage: "req_brie3", shapeDescription: "Blue Any")
            ]
        ),
        
        // 11. Bella (+5) -> 3 items (2x Purple Line + 1 Purple Any)
        JastipOrderModel(
            orderKey: "bella",
            customerName: "Bella",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_bella", shapeDescription: "Purple Line"),
                JastipRequirementItem(requirementImage: "req_bella2", shapeDescription: "Purple Line"),
                JastipRequirementItem(requirementImage: "req_bella3", shapeDescription: "Purple Any")
            ]
        ),
        
        // 12. Roxanne (+4) -> 2 items (Blue/Green Sq/T & Blue/Green Triomino/Small L)
        JastipOrderModel(
            orderKey: "roxanne",
            customerName: "Roxanne",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_roxanne", shapeDescription: "Blue/Green Square / T"),
                JastipRequirementItem(requirementImage: "req_roxanne2", shapeDescription: "Blue/Green Triomino I / Small L")
            ]
        ),
        
        // 13. Diana (+4) -> 2 items (Orange/Purple Line & Orange/Purple Sq/T)
        JastipOrderModel(
            orderKey: "diana",
            customerName: "Diana",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_diana", shapeDescription: "Orange/Purple Line"),
                JastipRequirementItem(requirementImage: "req_diana2", shapeDescription: "Orange/Purple Square / T")
            ]
        ),
        
        // 14. Caroline (+5) -> 2 items (Non-blue Single/Domino & Blue Anomaly)
        JastipOrderModel(
            orderKey: "caroline",
            customerName: "Caroline",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_caroline", shapeDescription: "Non-Blue Single/Domino"),
                JastipRequirementItem(requirementImage: "req_caroline2", shapeDescription: "Blue Anomaly")
            ]
        ),
        
        // ==========================================
        // MARK: - LEMBAR 3 (9 KARTU)
        // ==========================================
        
        // 15. Kayden (+5) -> 2 items (Single & Anomaly)
        JastipOrderModel(
            orderKey: "kayden",
            customerName: "Kayden",
            points: 5,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_kayden", shapeDescription: "Single (1 Slot)"),
                JastipRequirementItem(requirementImage: "req_kayden2", shapeDescription: "Anomaly (Unique)")
            ]
        ),
        
        // 16. Fernando (+4) -> 2 items (Purple/Red L/T & Purple/Red Line)
        JastipOrderModel(
            orderKey: "fernando",
            customerName: "Fernando",
            points: 4,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_fernando", shapeDescription: "Purple/Red L / T"),
                JastipRequirementItem(requirementImage: "req_fernando2", shapeDescription: "Purple/Red Line (3/4)")
            ]
        ),
        
        // 17. Alvin (+5) -> 3 items (Blue 1/2, Red/Orange 1/2, Purple/Green 3/4)
        JastipOrderModel(
            orderKey: "alvin",
            customerName: "Alvin",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_alvin", shapeDescription: "Blue Single / Domino"),
                JastipRequirementItem(requirementImage: "req_alvin2", shapeDescription: "Red/Orange Single / Domino"),
                JastipRequirementItem(requirementImage: "req_alvin3", shapeDescription: "Purple/Green Triomino / Tetromino I")
            ]
        ),
        
        // 18. Enzo (+4) -> 2 items (Blue/Green Square & Blue/Green L/T)
        JastipOrderModel(
            orderKey: "enzo",
            customerName: "Enzo",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_enzo", shapeDescription: "Blue/Green Square"),
                JastipRequirementItem(requirementImage: "req_enzo2", shapeDescription: "Blue/Green L / T")
            ]
        ),
        
        // 19. Taylor (+5) -> 3 items (Blue Domino, Red/Orange L/T, Purple/Green Sq/Line)
        JastipOrderModel(
            orderKey: "taylor",
            customerName: "Taylor",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_taylor", shapeDescription: "Blue Domino"),
                JastipRequirementItem(requirementImage: "req_taylor2", shapeDescription: "Red/Orange L / T"),
                JastipRequirementItem(requirementImage: "req_taylor3", shapeDescription: "Purple/Green Square / Tetromino I")
            ]
        ),
        
        // 20. Silvia (+5) -> 3 items (Blue Tri/L, Red/Orange Tri/L, Purple/Green Tri/L)
        JastipOrderModel(
            orderKey: "silvia",
            customerName: "Silvia",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_silvia", shapeDescription: "Blue Triomino I / Small L"),
                JastipRequirementItem(requirementImage: "req_silvia2", shapeDescription: "Red/Orange Triomino I / Small L"),
                JastipRequirementItem(requirementImage: "req_silvia3", shapeDescription: "Purple/Green Triomino I / Small L")
            ]
        ),
        
        // 21. David (+3) -> 3 items (Green Square + 2 Green Any)
        JastipOrderModel(
            orderKey: "david",
            customerName: "David",
            points: 3,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_david", shapeDescription: "Green Square"),
                JastipRequirementItem(requirementImage: "req_david2", shapeDescription: "Green Any"),
                JastipRequirementItem(requirementImage: "req_david3", shapeDescription: "Green Any")
            ]
        ),
        
        // 22. Jimmy (+5) -> 3 items (Red Line, Red Sq/T, Red Any)
        JastipOrderModel(
            orderKey: "jimmy",
            customerName: "Jimmy",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_jimmy", shapeDescription: "Red Triomino / Tetromino I"),
                JastipRequirementItem(requirementImage: "req_jimmy2", shapeDescription: "Red Square / Tetromino T"),
                JastipRequirementItem(requirementImage: "req_jimmy3", shapeDescription: "Red Any")
            ]
        ),
        
        // 23. Wayne (+5) -> 3 items (Orange Sq/T, Orange Tri/L, Orange Any)
        JastipOrderModel(
            orderKey: "wayne",
            customerName: "Wayne",
            points: 5,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_wayne", shapeDescription: "Orange Square / Tetromino T"),
                JastipRequirementItem(requirementImage: "req_wayne2", shapeDescription: "Orange Triomino I / Small L"),
                JastipRequirementItem(requirementImage: "req_wayne3", shapeDescription: "Orange Any")
            ]
        ),
        
        // ==========================================
        // MARK: - LEMBAR 4 (9 KARTU)
        // ==========================================
        
        // 24. Kevin - Straight (+4) -> 2 items (2x Green/Purple Line)
        JastipOrderModel(
            orderKey: "kevin_straight",
            customerName: "Kevin",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_kevin", shapeDescription: "Green/Purple Line"),
                JastipRequirementItem(requirementImage: "req_kevin2", shapeDescription: "Green/Purple Line")
            ]
        ),
        
        // 25. Lloyd (+4) -> 2 items (2x Orange/Red Tetromino L)
        JastipOrderModel(
            orderKey: "lloyd",
            customerName: "Lloyd",
            points: 4,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_lloyd", shapeDescription: "Orange/Red Tetromino L"),
                JastipRequirementItem(requirementImage: "req_lloyd2", shapeDescription: "Orange/Red Tetromino L")
            ]
        ),
        
        // 26. Hannah (+4) -> 2 items (2x Orange/Blue Square)
        JastipOrderModel(
            orderKey: "hannah",
            customerName: "Hannah",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_hannah", shapeDescription: "Orange/Blue Square"),
                JastipRequirementItem(requirementImage: "req_hannah2", shapeDescription: "Orange/Blue Square")
            ]
        ),
        
        // 27. Elliott (+5) -> 2 items (Blue/Red Tetromino T & Blue/Red L)
        JastipOrderModel(
            orderKey: "elliott",
            customerName: "Elliott",
            points: 5,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_elliott", shapeDescription: "Blue/Red Tetromino T"),
                JastipRequirementItem(requirementImage: "req_elliott2", shapeDescription: "Blue/Red Small L / Tetromino L")
            ]
        ),
        
        // 28. Jake (+5) -> 2 items (Red Square & Green Tetromino T)
        JastipOrderModel(
            orderKey: "jake",
            customerName: "Jake",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_jake", shapeDescription: "Red Square"),
                JastipRequirementItem(requirementImage: "req_jake2", shapeDescription: "Green Tetromino T")
            ]
        ),
        
        // 29. Leon (+4) -> 2 items (2x Orange Triomino/Tetromino I)
        JastipOrderModel(
            orderKey: "leon",
            customerName: "Leon",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_leon", shapeDescription: "Orange Triomino / Tetromino I"),
                JastipRequirementItem(requirementImage: "req_leon2", shapeDescription: "Orange Triomino / Tetromino I")
            ]
        ),
        
        // 30. Matheo - Tetris T (+4) -> 2 items (2x Tetromino T)
        JastipOrderModel(
            orderKey: "matheo_tetris_t",
            customerName: "Matheo",
            points: 4,
            chatMessage: "gurl cn u get me these??",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_matheo", shapeDescription: "Tetromino T"),
                JastipRequirementItem(requirementImage: "req_matheo2", shapeDescription: "Tetromino T")
            ]
        ),
        
        // 31. Pixie (+5) -> 3 items (Red/Orange 1/2, Purple/Green 1/2, Blue 1/2)
        JastipOrderModel(
            orderKey: "pixie",
            customerName: "Pixie",
            points: 5,
            chatMessage: "i’d like to request these items,",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_pixie", shapeDescription: "Red/Orange Single / Domino"),
                JastipRequirementItem(requirementImage: "req_pixie2", shapeDescription: "Purple/Green Single / Domino"),
                JastipRequirementItem(requirementImage: "req_pixie3", shapeDescription: "Blue Single / Domino")
            ]
        ),
        
        // 32. Minnie (+4) -> 2 items (2x Red/Orange Single)
        JastipOrderModel(
            orderKey: "minnie",
            customerName: "Minnie",
            points: 4,
            chatMessage: "get me these plsss",
            requirementItems: [
                JastipRequirementItem(requirementImage: "req_minnie", shapeDescription: "Red/Orange Single (1 Slot)"),
                JastipRequirementItem(requirementImage: "req_minnie2", shapeDescription: "Red/Orange Single (1 Slot)")
            ]
        )
    ]
    
    
    // MARK: - Logic Validator Berbasis PieceModel
        /// Order selesai JIKA dan HANYA JIKA semua item slot-nya bernilai true
        static func checkOrderCompletion(orderKey: String, items: [PieceModel]) -> Bool {
            let fulfilledStatuses = checkItemFulfillment(orderKey: orderKey, items: items)
            guard !fulfilledStatuses.isEmpty else { return false }
            return fulfilledStatuses.allSatisfy { $0 == true }
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
    
    // MARK: - Logic Validator Status Centang Per Slot Item (32 Kasus)
        /// Mengembalikan array boolean [Bool] penanda centang untuk masing-masing slot item di order
        /// 
        /// Consumes one matching item from the pool per slot.
        /// Note: Always place specific predicates before general/"Any" predicates.
        private static func matchSlots(
            items: [PieceModel],
            predicates: [(PieceModel) -> Bool]
        ) -> [Bool] {
            var pool = items
            return predicates.map { predicate in
                guard let index = pool.firstIndex(where: predicate) else { return false }
                pool.remove(at: index)
                return true
            }
        }
        static func checkItemFulfillment(orderKey: String, items: [PieceModel]) -> [Bool] {
            switch orderKey {
            // --- 1. Thomas (1 slot) ---
            case "thomas":
                // return [items.contains { ($0.color == .green || $0.color == .blue) && $0.isAnomaly }]
                return matchSlots(items: items, predicates: [
                    { $0.color == .green || $0.color == .blue && $0.isAnomaly }
                ])
                
            // --- 2. Toyib (1 slot) ---
            case "toyib":
                // return [items.contains { ($0.color == .red || $0.color == .orange) && $0.isAnomaly }]
                return matchSlots(items: items, predicates: [
                    { $0.color == .red || $0.color == .orange && $0.isAnomaly }
                ])
                
            // --- 3. Quincy (1 slot) ---
            case "quincy":
                // return [items.contains { ($0.color == .green || $0.color == .purple) && $0.isAnomaly }]
                return matchSlots(items: items, predicates: [
                    { $0.color == .green || $0.color == .purple && $0.isAnomaly }
                ])
                
            // --- 4. Henry (2 slot) ---
            case "henry":
                return matchSlots(items: items, predicates: [
                    { $0.color != .purple && ($0.shape == .single || $0.shape == .domino) },
                    { $0.color == .purple && $0.isAnomaly }
                ])
                
            // --- 5. Molly (2 slot) ---
            case "molly":
                return matchSlots(items: items, predicates: [
                    { $0.color == .orange && $0.shape == .square },
                    { $0.color == .orange && $0.shape == .tetrominoT }
                ])
                
            // --- 6. Mackenzie (2 slot: 2x Domino Green/Blue) ---
            case "mackenzie":
                return matchSlots(items: items, predicates: [
                    { $0.shape == .domino && ($0.color == .green || $0.color == .blue) },
                    { $0.shape == .domino && ($0.color == .green || $0.color == .blue) }
                ])
                
            // --- 7. Joe (2 slot) ---
            case "joe":
                return matchSlots(items: items, predicates: [
                    { $0.color == .orange && $0.shape == .single },
                    { $0.color != .orange && $0.shape == .tetrominoI }
                ])
                
            // --- 8. Billie (2 slot) ---
            case "billie":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .red || $0.color == .orange) && ($0.shape == .square || $0.shape == .tetrominoT) },
                    { ($0.color == .red || $0.color == .orange) && ($0.shape == .smallL || $0.shape == .tetrominoL) }
                ])
                
            // --- 9. Jude (2 slot) ---
            case "jude":
                return matchSlots(items: items, predicates: [
                    { $0.color == .blue && ($0.shape == .smallL || $0.shape == .tetrominoL) },
                    { $0.color == .orange && ($0.shape == .smallL || $0.shape == .tetrominoL) }
                ])
                
            // --- 10. Brie (3 slot: Blue Line, Blue T/Square, Blue Any) ---
            case "brie":
                let lineShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
                let tOrSquare: [PieceShape] = [.tetrominoT, .square]
                return matchSlots(items: items, predicates: [
                    { $0.color == .blue && lineShapes.contains($0.shape) },
                    { $0.color == .blue && tOrSquare.contains($0.shape) },
                    { $0.color == .blue }
                ])
                
            // --- 11. Bella (3 slot: Purple Line x2, Purple Any) ---
            case "bella":
                let lineShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
                return matchSlots(items: items, predicates: [
                    { $0.color == .purple && lineShapes.contains($0.shape) },
                    { $0.color == .purple && lineShapes.contains($0.shape) },
                    { $0.color == .purple }
                ])
                
            // --- 12. Roxanne (2 slot) ---
            case "roxanne":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .blue || $0.color == .green) && ($0.shape == .square || $0.shape == .tetrominoT) },
                    { ($0.color == .blue || $0.color == .green) && ($0.shape == .triominoI || $0.shape == .smallL) }
                ])
                
            // --- 13. Diana (2 slot) ---
            case "diana":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .orange || $0.color == .purple) && ($0.shape == .domino || $0.shape == .triominoI || $0.shape == .tetrominoI) },
                    { ($0.color == .orange || $0.color == .purple) && ($0.shape == .square || $0.shape == .tetrominoT) }
                ])
                
            // --- 14. Caroline (2 slot) ---
            case "caroline":
                return matchSlots(items: items, predicates: [
                    { $0.color == .blue && ($0.shape == .single || $0.shape == .domino) },
                    { $0.color == .blue && $0.isAnomaly }
                ])
                
            // --- 15. Kayden (2 slot) ---
            case "kayden":
                return matchSlots(items: items, predicates: [
                    { $0.isAnomaly },
                    { $0.shape == .single }
                ])
                
            // --- 16. Fernando (2 slot) ---
            case "fernando":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .purple || $0.color == .red) && ($0.shape == .tetrominoL || $0.shape == .smallL || $0.shape == .tetrominoT) },
                    { ($0.color == .purple || $0.color == .red) && ($0.shape == .triominoI || $0.shape == .tetrominoI) }
                ])
                
            // --- 17. Alvin (3 slot) ---
            case "alvin":
                return matchSlots(items: items, predicates: [
                    { $0.color == .blue && ($0.shape == .single || $0.shape == .domino) },
                    { ($0.color == .red || $0.color == .orange) && ($0.shape == .single || $0.shape == .domino) },
                    { ($0.color == .purple || $0.color == .green) && ($0.shape == .triominoI || $0.shape == .tetrominoI) }
                ])
                
            // --- 18. Enzo (2 slot) ---
            case "enzo":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .blue || $0.color == .green) && $0.shape == .square },
                    { ($0.color == .blue || $0.color == .green) && ($0.shape == .smallL || $0.shape == .tetrominoL || $0.shape == .tetrominoT) }
                ])
                
            // --- 19. Taylor (3 slot) ---
            case "taylor":
                return matchSlots(items: items, predicates: [
                    { $0.color == .blue && $0.shape == .domino },
                    { ($0.color == .red || $0.color == .orange) && ($0.shape == .smallL || $0.shape == .tetrominoL || $0.shape == .tetrominoT) },
                    { ($0.color == .purple || $0.color == .green) && ($0.shape == .square || $0.shape == .tetrominoI) }
                ])
                
            // --- 20. Silvia (3 slot) ---
            case "silvia":
                return matchSlots(items: items, predicates: [
                    { $0.color == .blue && ($0.shape == .triominoI || $0.shape == .smallL) },
                    { ($0.color == .red || $0.color == .orange) && ($0.shape == .triominoI || $0.shape == .smallL) },
                    { ($0.color == .purple || $0.color == .green) && ($0.shape == .triominoI || $0.shape == .smallL) }
                ])
                
            // --- 21. David (3 slot: Green Square, Green Any, Green Any) ---
            case "david":
                return matchSlots(items: items, predicates: [
                    { $0.color == .green && $0.shape == .square },
                    { $0.color == .green },
                    { $0.color == .green }
                ])
                
            // --- 22. Jimmy (3 slot: Red Line, Red Sq/T, Red Any) ---
            case "jimmy":
                return matchSlots(items: items, predicates: [
                    { $0.color == .red && ($0.shape == .triominoI || $0.shape == .tetrominoI) },
                    { $0.color == .red && ($0.shape == .square || $0.shape == .tetrominoT) },
                    { $0.color == .red }
                ])
                
            // --- 23. Wayne (3 slot: Orange Sq/T, Orange Tri/L, Orange Any) ---
            case "wayne":
                return matchSlots(items: items, predicates: [
                    { $0.color == .orange && ($0.shape == .square || $0.shape == .tetrominoT) },
                    { $0.color == .orange && ($0.shape == .triominoI || $0.shape == .smallL) },
                    { $0.color == .orange }
                ])
                
            // --- 24. Kevin Straight (2 slot) ---
            case "kevin_straight":
                let validShapes: [PieceShape] = [.domino, .triominoI, .tetrominoI]
                return matchSlots(items: items, predicates: [
                    { ($0.color == .green || $0.color == .purple) && validShapes.contains($0.shape) },
                    { ($0.color == .green || $0.color == .purple) && validShapes.contains($0.shape) }
                ])
                
            // --- 25. Lloyd (2 slot: 2x Tetromino L Orange/Red) ---
            case "lloyd":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .red || $0.color == .orange) && $0.shape == .tetrominoL },
                    { ($0.color == .red || $0.color == .orange) && $0.shape == .tetrominoL }
                ])
                
            // --- 26. Hannah (2 slot: 2x Square Orange/Blue) ---
            case "hannah":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .orange || $0.color == .blue) && $0.shape == .square },
                    { ($0.color == .orange || $0.color == .blue) && $0.shape == .square }
                ])
                
            // --- 27. Elliott (2 slot) ---
            case "elliott":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .blue || $0.color == .red) && ($0.shape == .tetrominoL || $0.shape == .smallL) },
                    { ($0.color == .blue || $0.color == .red) && $0.shape == .tetrominoT }
                ])
                
            // --- 28. Jake (2 slot) ---
            case "jake":
                return matchSlots(items: items, predicates: [
                    { $0.color == .red && $0.shape == .square },
                    { $0.color == .green && $0.shape == .tetrominoT }
                ])
                
            // --- 29. Leon (2 slot: 2x Orange Triomino/Tetromino I) ---
            case "leon":
                return matchSlots(items: items, predicates: [
                    { $0.color == .orange && ($0.shape == .triominoI || $0.shape == .tetrominoI) },
                    { $0.color == .orange && ($0.shape == .triominoI || $0.shape == .tetrominoI) }
                ])
                
            // --- 30. Matheo (2 slot: 2x Tetromino T) ---
            case "matheo_tetris_t":
                return matchSlots(items: items, predicates: [
                    { $0.shape == .tetrominoT },
                    { $0.shape == .tetrominoT }
                ])
                
            // --- 31. Pixie (3 slot) ---
            case "pixie":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .red || $0.color == .orange) && ($0.shape == .single || $0.shape == .domino) },
                    { ($0.color == .purple || $0.color == .green) && ($0.shape == .single || $0.shape == .domino) },
                    { $0.color == .blue && ($0.shape == .single || $0.shape == .domino) }
                ])
                
            // --- 32. Minnie (2 slot: 2x Red/Orange Single) ---
            case "minnie":
                return matchSlots(items: items, predicates: [
                    { ($0.color == .red || $0.color == .orange) && $0.shape == .single },
                    { ($0.color == .red || $0.color == .orange) && $0.shape == .single }
                ])
                
            default:
                return []
            }
        }
}