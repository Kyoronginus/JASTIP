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
    
    // Warna tema acak pengirim ala WhatsApp Group
    private var senderColor: Color {
        let colors: [Color] = [.orange, .blue, .green, .purple, Color(red: 0.95, green: 0.45, blue: 0.15)]
        let hash = abs(order.customerName.hashValue)
        return colors[hash % colors.count]
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
                            .foregroundStyle(isSelected ? Color.blue : Color.gray.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                } else {
                    Circle()
                        .fill(senderColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(.top, 2)
            
            // MARK: - Bubble Chat Putih (Hug Content Ukuran Asli)
            VStack(alignment: .leading, spacing: 8) {
                // 1. Header: Nama Customer & Nominal Dollar
                HStack {
                    Text(order.customerName)
                        .font(.plusJakarta(15, .bold))
                        .foregroundStyle(senderColor)
                    
                    Spacer(minLength: 16)
                    
                    Text("$\(order.points * 10)")
                        .font(.plusJakarta(15, .bold))
                        .foregroundStyle(senderColor)
                }
                
                // 2. Chat Message
                Text(order.chatMessage)
                    .font(.plusJakarta(14, .regular))
                    .foregroundStyle(Color("NavyBlack"))
                
                // 3. Deretan Gambar Kartu
                HStack(spacing: maxCardSpacing) {
                    ForEach(order.requirementItems) { item in
                        Image(item.requirementImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageCardWidth, height: imageCardHeight)
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
