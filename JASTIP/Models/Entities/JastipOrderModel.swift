//
//  JastipOrderModel.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 05/11/26.
//

import Foundation

// Slot requirement per item di dalam chat bubble
struct JastipRequirementItem: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    let requirementImage: String        // Nama asset gambar (placeholder: "itemui")
    let shapeDescription: String       // Bentuk atau kriteria (misal: "2 / 3 / 4", "kotak / T", "any")
    var isFulfilled: Bool = false
    
    init(requirementImage: String = "itemui", shapeDescription: String, isFulfilled: Bool = false) {
        self.requirementImage = requirementImage
        self.shapeDescription = shapeDescription
        self.isFulfilled = isFulfilled
    }
}

struct JastipOrderModel: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    
    // MARK: - Rule Identifier
    let orderKey: String                // Kunci unik untuk validasi (contoh: "thomas", "henry")
    
    // MARK: - Customer Identity
    let customerName: String            // Nama customer
    let points: Int                     // Poin reward jika order selesai (+3, +4, +5)
    
    // MARK: - Group Chat Visual & Flavor
    let chatMessage: String             // Teks chat pembuka di grup
    var requirementItems: [JastipRequirementItem] = [] // Daftar slot barang (1, 2, 3, dst.)
    
    // Backward compatibility
    var requirementImage: String {
        requirementItems.first?.requirementImage ?? "itemui"
    }
    
    // MARK: - Status Gameplay
    var isPersonal: Bool = false        // true jika ini personal objective (hasil drafting)
    var isCompleted: Bool = false       // true jika syarat pesanan sudah terpenuhi
    
    // MARK: - Business Logic: Cek Kelengkapan Order via PieceModel
    func isFulfilled(by items: [PieceModel]) -> Bool {
        JastipOrderCatalog.checkOrderCompletion(orderKey: self.orderKey, items: items)
    }
    
    /// Status centang untuk masing-masing slot gambar item
    func itemStatuses(by pieces: [PieceModel]) -> [Bool] {
        JastipOrderCatalog.checkItemFulfillment(orderKey: self.orderKey, items: pieces)
    }
}
