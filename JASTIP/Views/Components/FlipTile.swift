//
//  FlipTile.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

struct FlipTile: View {
    
    var character: Character
    var width: CGFloat = 36
    var height: CGFloat = 52
    var fontSize: CGFloat = 32
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x24 / 255.0))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color(red: 0x22 / 255.0, green: 0x2A / 255.0, blue: 0x38 / 255.0), lineWidth: 1))
            Rectangle()
                .fill(Color(red: 0x0A / 255.0, green: 0x0D / 255.0, blue: 0x14 / 255.0))
                .frame(height: 1)
            
            Text(String(character))
                .font(.spaceGrotesk(fontSize, .bold))
                .foregroundStyle(Color(red: 0xF5 / 255.0, green: 0xF4 / 255.0, blue: 0xEE / 255.0))
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    HStack {
        FlipTile(character: "A")
        FlipTile(character: "B")
        FlipTile(character: "A")
        FlipTile(character: "B")
    }
}
