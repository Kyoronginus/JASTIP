//
//  AirlineCardModel.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import Foundation

struct AirlineCardModel: Identifiable {
   var id: String = UUID().uuidString
   let maxCapacityKg: Int
   let maxCarryOnKg: Int
   let departureTime: String
}
