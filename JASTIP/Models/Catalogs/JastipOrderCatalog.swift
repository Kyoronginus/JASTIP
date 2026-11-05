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
            chatMessage: "Bro, nitip pajangan antik bentuk T ya! Kalo ga ada, jaket butik bentuk L juga boleh.",
            requirementImageName: "req_thomas",
            requirementDescription: "1 Blue Antique (T) OR 1 Green Boutique (L)"
        ),
        
        // 2. Toyib (+4)
        JastipOrderModel(
            orderKey: "toyib",
            customerName: "Toyib",
            points: 4,
            chatMessage: "Titip jajan delicacy atau mainan anak dong, bentuknya yang unik sesuai foto ya!",
            requirementImageName: "req_toyib",
            requirementDescription: "1 Yellow Delicacy OR 1 Pink Kids (Unique)"
        ),
        
        // 3. Quincy (+4)
        JastipOrderModel(
            orderKey: "quincy",
            customerName: "Quincy",
            points: 4,
            chatMessage: "Eh jangan lupa titipan gua, cariin antique atau buku sesuai foto ya!",
            requirementImageName: "req_quincy",
            requirementDescription: "1 Blue Antique OR 1 Red Books (Unique)"
        ),
        
        // 4. Henry (+5)
        JastipOrderModel(
            orderKey: "henry",
            customerName: "Henry",
            points: 5,
            chatMessage: "Nitip buku novel tebal (L) plus satu jajan kecil 1 slot ya bro, tengkyu!",
            requirementImageName: "req_henry",
            requirementDescription: "1 Red Books (L) + 1 Single (Yellow/Pink/Blue/Green)"
        ),
        
        // 5. Molly (+4)
        JastipOrderModel(
            orderKey: "molly",
            customerName: "Molly",
            points: 4,
            chatMessage: "Guys, tolong bawain 2 makanan dari Delicacy ya, bentuknya yang kotak/L/T/I yaa.",
            requirementImageName: "req_molly",
            requirementDescription: "2 Yellow Delicacy (Square / L / T / I)"
        ),
        
        // 6. Mackenzie (+3)
        JastipOrderModel(
            orderKey: "mackenzie",
            customerName: "Mackenzie",
            points: 3,
            chatMessage: "Titip barang antik atau baju dong, tapi harus yang bentuk domino 2 slot ya!",
            requirementImageName: "req_mackenzie",
            requirementDescription: "2 Dominoes from Blue Antique or Green Boutique"
        ),
        
        // 7. Joe (+3)
        JastipOrderModel(
            orderKey: "joe",
            customerName: "Joe",
            points: 3,
            chatMessage: "Bawain barang panjang (3 slot) dari toko buku/mainan/antik/butik, plus jajan kecil 1 slot!",
            requirementImageName: "req_joe",
            requirementDescription: "1 Triomino I (Red/Pink/Blue/Green) + 1 Single (Yellow Delicacy)"
        ),
        
        // 8. Billie (+5)
        JastipOrderModel(
            orderKey: "billie",
            customerName: "Billie",
            points: 5,
            chatMessage: "Nitip jajan atau mainan, cari yang porsi gede ya! Total ukuran berdua minimal 8 grid.",
            requirementImageName: "req_billie",
            requirementDescription: "2 Items (Yellow/Pink) with Total Size >= 8 grids"
        ),
        
        // 9. Jude (+4)
        JastipOrderModel(
            orderKey: "jude",
            customerName: "Jude",
            points: 4,
            chatMessage: "Gua suka yang kembar! Beliin 2 barang dari toko beda, tapi bentuk potongannya harus sama persis.",
            requirementImageName: "req_jude",
            requirementDescription: "2 Items from 2 different stores with exact same shape"
        ),

        // ==========================================
        // MARK: - LEMBAR 2 (5 KARTU)
        // ==========================================
        
        // 10. Brie (+5)
        JastipOrderModel(
            orderKey: "brie",
            customerName: "Brie",
            points: 5,
            chatMessage: "Tolong borong 3 barang dari Butik ya! Yang satu lurus, satu lagi bentuk T/kotak, satunya bebas.",
            requirementImageName: "req_brie",
            requirementDescription: "3 Green Boutique: 1 Line + 1 (T/Square) + 1 Any"
        ),
        
        // 11. Bella (+5)
        JastipOrderModel(
            orderKey: "bella",
            customerName: "Bella",
            points: 5,
            chatMessage: "Nitip 3 buku dari toko Books! Minimal 2 buku harus bentuk lurus (domino/triomino/tetromino I).",
            requirementImageName: "req_bella",
            requirementDescription: "3 Red Books: at least 2 Line shapes"
        ),
        
        // 12. Roxanne (+4)
        JastipOrderModel(
            orderKey: "roxanne",
            customerName: "Roxanne",
            points: 4,
            chatMessage: "Titip 2 barang dari toko Antik atau Butik ya, bentuknya yang standar kayak di foto.",
            requirementImageName: "req_roxanne",
            requirementDescription: "2 Items (Blue/Green) with shapes: Domino/Triomino/T/L/Square"
        ),
        
        // 13. Diana (+4)
        JastipOrderModel(
            orderKey: "diana",
            customerName: "Diana",
            points: 4,
            chatMessage: "Nitip 2 barang dari toko Makanan atau Buku: satu bentuk L/T, dan satu lagi yang lurus!",
            requirementImageName: "req_diana",
            requirementDescription: "2 Items (Yellow/Red): 1 (L/T) + 1 Line shape"
        ),
        
        // 14. Caroline (+5)
        JastipOrderModel(
            orderKey: "caroline",
            customerName: "Caroline",
            points: 5,
            chatMessage: "Beliin 2 barang dari toko yang sama ya, satu yang kecil banget (<=2) dan satu yang gede (>=5).",
            requirementImageName: "req_caroline",
            requirementDescription: "2 Items from same store: 1 size <= 2 grids & 1 size >= 5 grids"
        ),

        // ==========================================
        // MARK: - LEMBAR 3 (9 KARTU)
        // ==========================================
        
        // 15. Matheo (+5)
        JastipOrderModel(
            orderKey: "matheo_unique",
            customerName: "Matheo",
            points: 5,
            chatMessage: "Titip 1 barang kecil 1 slot plus 1 barang unik yang langka ya!",
            requirementImageName: "req_matheo_unique",
            requirementDescription: "1 Single + 1 Any Unique shape"
        ),
        
        // 16. Fernando (+4)
        JastipOrderModel(
            orderKey: "fernando",
            customerName: "Fernando",
            points: 4,
            chatMessage: "Nitip 2 barang dari Buku atau Mainan: satu bentuk L/T, dan satu lagi bentuk lurus pendek.",
            requirementImageName: "req_fernando",
            requirementDescription: "2 Items (Red/Pink): 1 (L/T) + 1 (Domino/Triomino I)"
        ),
        
        // 17. Alvin (+5)
        JastipOrderModel(
            orderKey: "alvin",
            customerName: "Alvin",
            points: 5,
            chatMessage: "Tolong bawain 3 barang dari toko apa aja, asalkan bentuknya geometris rapi (garis atau kotak)!",
            requirementImageName: "req_alvin",
            requirementDescription: "3 Items from any store with shapes: Domino/Triomino I/Tetromino I/Square"
        ),
        
        // 18. Enzo (+4)
        JastipOrderModel(
            orderKey: "enzo",
            customerName: "Enzo",
            points: 4,
            chatMessage: "Titip 2 barang dari toko Antik atau Butik, pilih bentuk balok kotak/L/T ya.",
            requirementImageName: "req_enzo",
            requirementDescription: "2 Items (Blue/Green) with shapes: Square/Tetromino L/Tetromino T"
        ),
        
        // 19. Taylor (+5)
        JastipOrderModel(
            orderKey: "taylor",
            customerName: "Taylor",
            points: 5,
            chatMessage: "Titip 3 barang bertingkat ukurannya: satu minimal 2 grid, satu minimal 3 grid, satu minimal 4 grid!",
            requirementImageName: "req_taylor",
            requirementDescription: "3 Items from any store: sizes 2+, 3+, 4+ grids"
        ),
        
        // 20. Silvia (+5)
        JastipOrderModel(
            orderKey: "silvia",
            customerName: "Silvia",
            points: 5,
            chatMessage: "Tolong beliin 3 barang dari toko mana aja, tapi jumlah kotaknya harus kembar identik semuanya!",
            requirementImageName: "req_silvia",
            requirementDescription: "3 Items from any store with exact same grid count"
        ),
        
        // 21. David (+3)
        JastipOrderModel(
            orderKey: "david",
            customerName: "David",
            points: 3,
            chatMessage: "Borong 3 barang dari toko Antik ya! Yang penting ada yang bentuk kotak/T dan bentuk panjang.",
            requirementImageName: "req_david",
            requirementDescription: "3 Blue Antique: 1 (Square/T) + 1 (Line/Small L/Unique) + 1 Any"
        ),
        
        // 22. Jimmy (+5)
        JastipOrderModel(
            orderKey: "jimmy",
            customerName: "Jimmy",
            points: 5,
            chatMessage: "Beliin 3 mainan anak dari toko Kids, tapi jangan kembar semua ya, minimal ada 2 bentuk berbeda!",
            requirementImageName: "req_jimmy",
            requirementDescription: "3 Pink Kids items with at least 2 different shapes"
        ),
        
        // 23. Wayne (+5)
        JastipOrderModel(
            orderKey: "wayne",
            customerName: "Wayne",
            points: 5,
            chatMessage: "Lagi laper banget nih, tolong borong 3 makanan Delicacy! Total ukurannya minimal 8 grid ya.",
            requirementImageName: "req_wayne",
            requirementDescription: "3 Yellow Delicacy items with Total Size >= 8 grids"
        ),

        // ==========================================
        // MARK: - LEMBAR 4 (9 KARTU)
        // ==========================================
        
        // 24. Kevin - Straight (+4)
        JastipOrderModel(
            orderKey: "kevin_straight",
            customerName: "Kevin",
            points: 4,
            chatMessage: "Titip 2 barang bentuk lurus (domino/triomino/tetromino I) dari toko Antik atau Buku ya!",
            requirementImageName: "req_kevin_straight",
            requirementDescription: "2 Items (Blue/Red) with Line shapes (Domino/Triomino/Tetromino I)"
        ),
        
        // 25. Lloyd (+4)
        JastipOrderModel(
            orderKey: "lloyd",
            customerName: "Lloyd",
            points: 4,
            chatMessage: "Beliin 2 barang bentuk huruf L dari toko Delicacy atau toko Mainan ya bro!",
            requirementImageName: "req_lloyd",
            requirementDescription: "2 Tetromino L from Yellow Delicacy or Pink Kids"
        ),
        
        // 26. Kevin - Square (+4)
        JastipOrderModel(
            orderKey: "kevin_square",
            customerName: "Kevin",
            points: 4,
            chatMessage: "Nitip 2 barang yang bentuknya kotak 2x2 (square) dari toko Makanan atau Butik ya!",
            requirementImageName: "req_kevin_square",
            requirementDescription: "2 Square shapes from Yellow Delicacy or Green Boutique"
        ),
        
        // 27. Elliot (+5)
        JastipOrderModel(
            orderKey: "elliot",
            customerName: "Elliot",
            points: 5,
            chatMessage: "Titip 1 barang bentuk T dan 1 barang bentuk L dari toko Butik atau Mainan ya!",
            requirementImageName: "req_elliot",
            requirementDescription: "1 Tetromino T + 1 Tetromino L (from Green Boutique or Pink Kids)"
        ),
        
        // 28. Jake (+5)
        JastipOrderModel(
            orderKey: "jake",
            customerName: "Jake",
            points: 5,
            chatMessage: "Beliin 2 barang gede (masing-masing minimal 4 kotak) dari toko Makanan atau Mainan!",
            requirementImageName: "req_jake",
            requirementDescription: "2 Items (Pink/Yellow), each with minimum 4 grids"
        ),
        
        // 29. Leon (+4)
        JastipOrderModel(
            orderKey: "leon",
            customerName: "Leon",
            points: 4,
            chatMessage: "Nitip 2 cemilan bentuk stik/lurus (domino atau triomino I) dari toko Delicacy ya!",
            requirementImageName: "req_leon",
            requirementDescription: "2 Yellow Delicacy with shapes: Domino or Triomino I"
        ),
        
        // 30. Matheo - Tetris T (+4)
        JastipOrderModel(
            orderKey: "matheo_tetris_t",
            customerName: "Matheo",
            points: 4,
            chatMessage: "Tolong cariin 2 barang yang bentuknya huruf T dari toko mana aja!",
            requirementImageName: "req_matheo_t",
            requirementDescription: "2 Tetromino T shapes from any store"
        ),
        
        // 31. Pixie (+5)
        JastipOrderModel(
            orderKey: "pixie",
            customerName: "Pixie",
            points: 5,
            chatMessage: "Beliin 3 barang kecil (single atau domino) dari 3 toko yang berbeda-beda ya!",
            requirementImageName: "req_pixie",
            requirementDescription: "3 Items from 3 different stores, each size 1 or 2 grids (Single/Domino)"
        ),
        
        // 32. Minnie (+4)
        JastipOrderModel(
            orderKey: "minnie",
            customerName: "Minnie",
            points: 4,
            chatMessage: "Titip 2 barang mungil 1 slot (single) dari toko Mainan atau Delicacy ya!",
            requirementImageName: "req_minnie",
            requirementDescription: "2 Single (1-grid) items from Pink Kids or Yellow Delicacy"
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
