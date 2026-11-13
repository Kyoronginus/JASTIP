//
//  AppFont.swift
//  JASTIP
//
//  Created by Feivel Qutby on 24/10/26.
//


import SwiftUI
import CoreText

enum AppFont {
    private static let registerCustomFonts: Void = {
        let fonts = [
            "ShantellSans-Bold.ttf", "ShantellSans-BoldItalic.ttf",
            "ShantellSans-ExtraBold.ttf", "ShantellSans-ExtraBoldItalic.ttf",
            "ShantellSans-Italic.ttf", "ShantellSans-Light.ttf",
            "ShantellSans-LightItalic.ttf", "ShantellSans-Medium.ttf",
            "ShantellSans-MediumItalic.ttf", "ShantellSans-Regular.ttf",
            "ShantellSans-SemiBold.ttf", "ShantellSans-SemiBoldItalic.ttf"
        ]
        for font in fonts {
            if let url = Bundle.main.url(forResource: font, withExtension: nil) {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        }
    }()

    // Plus Jakarta Sans
    static func plusJakarta(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .heavy:
            return .custom("PlusJakartaSans-ExtraBold", size: size)
        case .bold:
            return .custom("PlusJakartaSans-Bold", size: size)
        case .semibold:
            return .custom("PlusJakartaSans-SemiBold", size: size)
        case .medium:
            return .custom("PlusJakartaSans-Medium", size: size)
        case .light:
            return .custom("PlusJakartaSans-Light", size: size)
        default:
            return .custom("PlusJakartaSans-Regular", size: size)
        }
    }
    
    // Space Grotesk
    static func spaceGrotesk(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("SpaceGrotesk-Bold", size: size)
        case .semibold:
            return .custom("SpaceGrotesk-SemiBold", size: size)
        case .medium:
            return .custom("SpaceGrotesk-Medium", size: size)
        case .light:
            return .custom("SpaceGrotesk-Light", size: size)
        default:
            return .custom("SpaceGrotesk-Regular", size: size)
        }
    }
    
    // Shantell Sans
    static func shantellSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        _ = registerCustomFonts
        switch weight {
        case .heavy:
            return .custom("ShantellSans-ExtraBold", size: size)
        case .bold:
            return .custom("ShantellSans-Bold", size: size)
        case .semibold:
            return .custom("ShantellSans-SemiBold", size: size)
        case .medium:
            return .custom("ShantellSans-Medium", size: size)
        case .light:
            return .custom("ShantellSans-Light", size: size)
        default:
            return .custom("ShantellSans-Regular", size: size)
        }
    }
}

// Extension biar bisa dipanggil langsung: .font(.plusJakarta(16, .bold)) atau .font(.spaceGrotesk(16, .bold))
extension Font {
    static func plusJakarta(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        AppFont.plusJakarta(size: size, weight: weight)
    }
    
    static func spaceGrotesk(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        AppFont.spaceGrotesk(size: size, weight: weight)
    }
    
    static func shantellSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        AppFont.shantellSans(size: size, weight: weight)
    }
}
