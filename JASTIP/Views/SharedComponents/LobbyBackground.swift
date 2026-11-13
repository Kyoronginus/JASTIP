//
//  AppBackground.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 24/10/26.
//

import SwiftUI

// MARK: - ViewModifier
struct LobbyBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("LobbyBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
}
// MARK: - View Extension (Agar mudah dipanggil)
extension View {
    func lobbyBackground() -> some View {
        modifier(LobbyBackgroundModifier())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Sample Page Title")
            .font(.spaceGrotesk(24, .bold))
        
        Button("Sample Button") {}
            .buttonStyle(PrimaryButtonStyle())
    }
    .lobbyBackground()
}
