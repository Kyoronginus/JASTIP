//
//  GameEventType.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct RandomEventModel: Identifiable {
   var id: String = UUID().uuidString
   let title: String
   let message: String
}
