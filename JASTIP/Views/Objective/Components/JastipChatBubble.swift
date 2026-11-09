//
//  JastipChatBubble.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct JastipChatBubble: View {
    let order: JastipOrderModel
    
    var isSelectable: Bool = false
    var isSelected: Bool = false
    var onToggleSelect: () -> Void = {}
    
    // Model pasangan warna Avatar (Background & Icon)
    private struct ProfileTheme {
        let main: Color       // Warna background avatar & teks header
        let iconTint: Color   // Warna icon profil di dalamnya (varian 150)
    }
    
    // Daftar palet warna dari Assets yang lo punya
    private var profileTheme: ProfileTheme {
        let themes: [ProfileTheme] = [
            ProfileTheme(
                main: Color("PassportBlue"),
                iconTint: Color("PassportBlue150")
            ),
            ProfileTheme(
                main: Color("TransitTangerine"),
                iconTint: Color("TransitTangerine150")
            ),
            ProfileTheme(
                main: Color("FragileRed"),
                iconTint: Color("FragileRed150")
            ),
            ProfileTheme(
                main: Color("TaxiYellow"),
                iconTint: Color("TaxiYellow150")
            )
        ]
        
        let hash = abs(order.customerName.hashValue)
        return themes[hash % themes.count]
    }
    
    // Lebar ideal kartu gambar sesuai jumlah item (Hug Content)
    private var imageCardWidth: CGFloat {
        switch order.requirementItems.count {
        case 1:
            return 220 // 1 kartu lebar (SS 1 - Toyib)
        case 2:
            return 120 // 2 kartu sedang (SS 3 - Elliott)
        default:
            return 82  // 3 kartu ramping (SS 2 - Bella)
        }
    }
    
    // Tinggi kartu gambar konsisten 145 pt
    private let imageCardHeight: CGFloat = 145
    
    // Spacing maksimal antar kartu
    private let maxCardSpacing: CGFloat = 6
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // MARK: - Avatar Pengirim / Centang Drafting
            ZStack {
                if isSelectable {
                    Button {
                        onToggleSelect()
                    } label: {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(isSelected ? Color("PassportBlue") : Color.gray.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                } else {
                    // Background Circle Avatar
                    Circle()
                        .fill(profileTheme.main)
                        .frame(width: 44, height: 44)
                    
                    // Icon Person dengan varian warna 150
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(profileTheme.iconTint)
                }
            }
            .padding(.top, 2)
            
            // MARK: - Bubble Chat Putih (Hug Content Ukuran Asli)
            VStack(alignment: .leading, spacing: 8) {
                // 1. Header: Nama Customer & Nominal Dollar (Warna Utama Tema)
                HStack {
                    Text(order.customerName)
                        .font(.plusJakarta(15, .bold))
                        .foregroundStyle(profileTheme.main)
                    
                    Spacer(minLength: 16)
                    
                    Text("$\(order.points * 10)")
                        .font(.plusJakarta(15, .bold))
                        .foregroundStyle(profileTheme.main)
                }
                
                // 2. Chat Message
                Text(order.chatMessage)
                    .font(.plusJakarta(14, .regular))
                    .foregroundStyle(Color("NavyBlack"))
                
                // 3. Deretan Gambar Kartu
                HStack(spacing: maxCardSpacing) {
                    ForEach(order.requirementItems) { item in
                        ZStack(alignment: .topTrailing) {
                            // Gambar Kartu Item
                            Image(item.requirementImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageCardWidth, height: imageCardHeight)
                                .overlay(
                                    // Stroke Oranye jika item sudah terpenuhi
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            item.isFulfilled ? Color("TransitTangerine") : Color.clear,
                                            lineWidth: 2
                                        )
                                )

                            // Badge Centang "checkdone" di pojok kanan atas nembus garis
                            if item.isFulfilled {
                                Image("checkdone")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(14)
            // Bubble hanya sebesar konten di dalamnya (Hug Content)
            .fixedSize(horizontal: true, vertical: false)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            
            // Spacer di luar agar bubble selalu menempel rapi di kiri
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }
}
