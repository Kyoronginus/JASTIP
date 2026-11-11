//
//  ToastType.swift
//  JASTIP
//
//  Created by Feivel Qutby on 06/11/26.
//

import SwiftUI

enum ToastModel: String, Codable, Equatable {
    case success, error, info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct ToastOptions: Codable, Equatable {
    var id: String = UUID().uuidString
    let message: String
    let type: ToastModel
    var duration: TimeInterval = 2.5
    var playsNotificationSound: Bool? = nil
    var senderID: String? = nil
}
