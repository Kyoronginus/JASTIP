//
//  JastipOrderCatalog.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 05/11/26.
//

import Foundation

enum JastipOrderCatalog {
    static let allOrders: [JastipOrderModel] = [
        // MARK: - Kartu 1 (Thomas)
        JastipOrderModel(
            customerName: "Thomas",
            points: 4,
            chatMessage: "Bro, nitip pajangan antik bentuk T ya! Kalo ga ada, jaket butik bentuk L juga boleh.",
            requirementImageName: "req_thomas",
            requirementDescription: "1 Blue Antique (T) OR 1 Green Boutique (L)"
        ),
        
        // MARK: - Kartu 2 (Toyib)
        JastipOrderModel(
            customerName: "Toyib",
            points: 4,
            chatMessage: "Titip jajan delicacy atau mainan anak dong, bentuknya yang kayak di foto ini ya!",
            requirementImageName: "req_toyib",
            requirementDescription: "1 Yellow Delicacy OR 1 Pink Kids"
        ),
        
        // MARK: - Kartu 3 (Quincy)
        JastipOrderModel(
            customerName: "Quincy",
            points: 4,
            chatMessage: "Eh jangan lupa titipan gua, cariin antique atau buku sesuai foto ya!",
            requirementImageName: "req_quincy",
            requirementDescription: "1 Blue Antique OR 1 Red Books"
        ),
        
        // MARK: - Kartu 4 (Henry)
        JastipOrderModel(
            customerName: "Henry",
            points: 5,
            chatMessage: "Nitip buku novel tebal (L) plus satu jajan kecil 1 slot ya bro, tengkyu!",
            requirementImageName: "req_henry",
            requirementDescription: "1 Red Books (L) + 1 Single (Yellow/Pink/Blue/Green)"
        ),
        
        // MARK: - Kartu 5 (Molly)
        JastipOrderModel(
            customerName: "Molly",
            points: 4,
            chatMessage: "Guys, tolong bawain 2 makanan dari Delicacy ya, bentuknya yang kotak/L/T/I yaa.",
            requirementImageName: "req_molly",
            requirementDescription: "2 Yellow Delicacy (Square / L / T / I)"
        ),
        
        // MARK: - Kartu 6 (Mackenzie)
        JastipOrderModel(
            customerName: "Mackenzie",
            points: 3,
            chatMessage: "Titip barang antik atau baju dong, tapi harus yang bentuk domino 2 slot ya!",
            requirementImageName: "req_mackenzie",
            requirementDescription: "2 Dominoes from Blue Antique or Green Boutique"
        ),
        
        // MARK: - Kartu 7 (Billie)
        JastipOrderModel(
            customerName: "Billie",
            points: 5,
            chatMessage: "Nitip jajan atau mainan, cari yang porsi gede ya! Total ukuran berdua minimal 8 grid.",
            requirementImageName: "req_billie",
            requirementDescription: "2 Items (Yellow/Pink) with Total Size >= 8 grids"
        ),
        
        // MARK: - Kartu 8 (Jude)
        JastipOrderModel(
            customerName: "Jude",
            points: 4,
            chatMessage: "Gua suka yang kembar! Beliin 2 barang dari toko beda, tapi bentuk potongannya harus sama persis.",
            requirementImageName: "req_jude",
            requirementDescription: "2 Items from 2 different stores with exact same shape"
        ),
        
        // MARK: - Kartu 9 (Caroline)
        JastipOrderModel(
            customerName: "Caroline",
            points: 5,
            chatMessage: "Beliin 2 barang dari toko yang sama ya, satu yang kecil banget (<=2) dan satu yang gede (>=5).",
            requirementImageName: "req_caroline",
            requirementDescription: "2 Items from same store: 1 size <= 2 grids & 1 size >= 5 grids"
        ),
        
        // MARK: - Kartu 10 (Wayne)
        JastipOrderModel(
            customerName: "Wayne",
            points: 5,
            chatMessage: "Lagi laper banget nih, tolong borong 3 makanan Delicacy! Total ukurannya minimal 8 grid ya.",
            requirementImageName: "req_wayne",
            requirementDescription: "3 Yellow Delicacy items with Total Size >= 8 grids"
        )
    ]
    
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
