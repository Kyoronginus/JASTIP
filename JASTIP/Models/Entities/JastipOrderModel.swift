//
//  JastipOrderModel.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 05/11/26.
//

import Foundation

struct JastipOrderModel: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    
    // MARK: - Customer Identity
    let customerName: String            // Nama customer (contoh: "Thomas", "Henry")
    let points: Int                     // Poin reward jika order selesai (+3, +4, +5)
    
    // MARK: - Group Chat Visual & Flavor
    let chatMessage: String             // Teks chat pembuka di grup
    let requirementImageName: String    // Nama asset gambar diagram/simbol pesanan
    let requirementDescription: String   // Penjelasan teks singkat dari request-nya
    
    // MARK: - Status Gameplay
    var isPersonal: Bool = false        // true jika ini personal objective (hasil drafting)
    var isCompleted: Bool = false       // true jika syarat pesanan sudah terpenuhi
}
