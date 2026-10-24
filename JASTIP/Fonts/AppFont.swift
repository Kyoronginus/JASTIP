//
//  AppFont.swift
//  JASTIP
//
//  Created by Feivel Qutby on 24/10/26.
//


import SwiftUI

enum AppFont {
    // Plus Jakarta Sans
    static func plusJakarta(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("PlusJakartaSans-Bold", size: size)
        case .semibold:
            return .custom("PlusJakartaSans-SemiBold", size: size)
        case .medium:
            return .custom("PlusJakartaSans-Medium", size: size)
        default:
            return .custom("PlusJakartaSans-Regular", size: size)
        }
    }
    
    // Space Grotesk
    static func spaceGrotesk(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("SpaceGrotesk-Bold", size: size)
        default:
            return .custom("SpaceGrotesk-Regular", size: size)
        }
    }
}

// Extension biar bisa dipanggil langsung: .font(.appPlusJakarta(16, .bold))
extension Font {
    static func appPlusJakarta(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        AppFont.plusJakarta(size: size, weight: weight)
    }
    
    static func appSpaceGrotesk(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        AppFont.spaceGrotesk(size: size, weight: weight)
    }
}
