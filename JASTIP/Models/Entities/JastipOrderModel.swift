//
//  JastipOrderModel.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 05/11/26.
//

import Foundation
struct JastipCardModel: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    
    // MARK: - Customer Identity
    let customerName: String            // Nama customer
    let points: Int                     // Point if order completed
    
    // MARK: - Group Chat Visual & Flavor
    let chatMessage: String           // Balon teks chat pembuka (misal: "Guys, ada yang lewat butik ga? Titip ya!")
    let requirementImageName: String  // Nama asset gambar diagram/simbol pesanan yang dilampirkan di chat
    let requirementDescription: String // Penjelasan singkat teksnya (misal: "1 Blue Antique (T) or Green Boutique (L)")
    
    // MARK: - Status Gameplay
    var isPersonal: Bool = false      // true jika ini personal objective (hasil drafting)
    var isCompleted: Bool = false     // true jika syarat pesanan sudah terpenuhi
}
