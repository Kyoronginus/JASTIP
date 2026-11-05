//
//  JastipChatBubble.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct JastipChatBubble: View {
    let order: JastipOrderModel
    
    // Properti Seleksi untuk Drafting
    var isSelectable: Bool = false
    var isSelected: Bool = false
    var onToggleSelect: () -> Void = {}
    
    // Warna acak pengirim ala WhatsApp Group
    private var senderColor: Color {
        let colors: [Color] = [.green, .orange, .blue, .purple, .pink]
        let hash = abs(order.customerName.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Bubble Chat Customer
            VStack(alignment: .leading, spacing: 8) {
                // 1. Header: Nama Customer & Badge
                HStack {
                    Text(order.customerName)
                        .font(.plusJakarta(13, .bold))
                        .foregroundStyle(senderColor)
                    
                    Spacer()
                    
                    // Badge Poin Reward (+3, +4, +5)
                    Text("+\(order.points) PTS")
                        .font(.plusJakarta(10, .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("TaxiYellow").opacity(0.2))
                        .foregroundStyle(Color("NavyBlack"))
                        .clipShape(Capsule())
                    
                    if order.isPersonal {
                        Text("PERSONAL")
                            .font(.plusJakarta(9, .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.15))
                            .foregroundStyle(.purple)
                            .clipShape(Capsule())
                    }
                }
                
                // 2. Teks Chat
                Text(order.chatMessage)
                    .font(.plusJakarta(14, .regular))
                    .foregroundStyle(.primary)
                
                // 3. Gambar Requirement (Fallback ke "6" jika aset spesifik belum ada)
                Group {
                    if UIImage(named: order.requirementImageName) != nil {
                        Image(order.requirementImageName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("6")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 4. Jam Chat
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
            
            // MARK: - Lingkaran Seleksi (Hollow -> Checked) di Kanan Bubble
            if isSelectable {
                Button {
                    onToggleSelect()
                } label: {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.blue : Color.gray.opacity(0.5))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 16)
    }
}
