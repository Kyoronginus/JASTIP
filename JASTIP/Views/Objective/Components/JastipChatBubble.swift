//
//  JastipChatBubble.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct JastipChatBubble: View {
    let order: JastipOrderModel
    
    // Warna acak pengirim ala WhatsApp Group
    private var senderColor: Color {
        let colors: [Color] = [.green, .orange, .blue, .purple, .pink]
        let hash = abs(order.customerName.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // 1. Nama Customer
                HStack {
                    Text(order.customerName)
                        .font(.plusJakarta(13, .bold))
                        .foregroundStyle(senderColor)
                    
                    if order.isPersonal {
                        Text("PRIVATE")
                            .font(.plusJakarta(9, .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.15))
                            .foregroundStyle(.purple)
                            .clipShape(Capsule())
                    }
                }
                
                // 2. Isi Chat Text
                Text(order.chatMessage)
                    .font(.plusJakarta(14, .regular))
                    .foregroundStyle(.primary)
                
                // 3. Img Requirement Misi
                Image("6")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 4. Jam Chat (Pojok Kanan Bawah)
                HStack {
                    Spacer()
                    Text("08:30")
                        .font(.plusJakarta(10, .regular))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            // Spacer di kanan agar bubble menempel ke sisi kiri (pesan masuk)
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 16)
    }
}
