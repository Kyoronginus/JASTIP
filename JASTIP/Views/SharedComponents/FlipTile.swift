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
    
    var textColor: Color = .black
    var isUsingBackground: Bool = true
    
    var body: some View {
        ZStack {
            if isUsingBackground {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x24 / 255.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color(red: 0x22 / 255.0, green: 0x2A / 255.0, blue: 0x38 / 255.0), lineWidth: 1))
                Rectangle()
                    .fill(Color(red: 0x0A / 255.0, green: 0x0D / 255.0, blue: 0x14 / 255.0))
                    .frame(height: 1)
            }
            
            Text(String(character))
                .font(.spaceGrotesk(fontSize, .semibold)) // 2. Gunakan variabel fontSize agar dinamis
                .foregroundStyle(textColor) // 3. Gunakan variabel textColor di sini
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    HStack {
        // Contoh pemanggilan
        FlipTile(character: "A") // Otomatis warna hitam (default)
        FlipTile(character: "B", textColor: .red) // Ganti warna jadi merah
        FlipTile(character: "C", textColor: .blue) // Ganti warna jadi biru
        FlipTile(character: "D", textColor: Color("TaxiYellow")) // Ganti pakai warna custom dari asset
    }
}
