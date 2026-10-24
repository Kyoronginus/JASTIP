//
//  AirlineDetailBlock.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 24/10/26.
//

import SwiftUI

struct AirlineDetailBlock: View {
    let icon: String                // SF Symbol ikon (misal: "clock.fill")
    let title: String               // Judul (misal: "BOARDING TIME")
    let subtitle: String            // Subtitle (misal: "Game Length:\n7 Rounds")
    let value: String               // Nilai angka besar (misal: "15:00" atau "20")
    var unit: String? = nil         // Satuan (misal: "KG")
    var cornerRadius: CGFloat = 12
    
    // Warna
    let backgroundColor: Color
    var foregroundColor: Color = .white
    
    // Aset watermark siluet
    var watermarkImageName: String? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 1. Watermark Siluet di Pojok Kanan Bawah
            if let watermark = watermarkImageName {
                Image(watermark)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .offset(x: 20, y: 35)
                    .clipped()
            }

            // 2. Konten Teks & Ikon
            HStack(alignment: .center) {
                // Kolom Kiri
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                        Text(title)
                            .font(.spaceGrotesk(16, .bold))
                    }

//                    Spacer(8)
                    
                    Text(subtitle)
                        .font(.plusJakarta(11, .medium))
                        .opacity(0.85)
                }

                Spacer()

                // Kolom Kanan (Nilai Utama)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.spaceGrotesk(40, .bold))

                    if let unit = unit {
                        Text(unit)
                            .font(.spaceGrotesk(16, .bold))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .foregroundStyle(foregroundColor)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 12) {
        AirlineDetailBlock(
            icon: "clock.fill",
            title: "BOARDING TIME",
            subtitle: "Game Length:\n7 Rounds",
            value: "15:00",
            backgroundColor: Color("TaxiYellow"),
            foregroundColor: Color("PassportBlue"),
            watermarkImageName: "WatermarkYellow"
        )
        
        AirlineDetailBlock(
            icon: "suitcase.fill",
            title: "MAX BAGGAGE",
            subtitle: "Suitcase:\n15 Slots (5x3)",
            value: "20",
            unit: "KG",
            backgroundColor: Color("PassportBlue"),
            foregroundColor: Color("PassportBlue150"),
            watermarkImageName: "WatermarkBlue"
        )
        
        AirlineDetailBlock(
            icon: "bag.fill",
            title: "MAX CARRY-ON",
            subtitle: "Carry-on:\n4 Slots (2x2)",
            value: "7",
            unit: "KG",
            backgroundColor: Color("TransitTangerine"),
            foregroundColor: Color(red: 0xF4 / 255.0, green: 0xCF / 255.0, blue: 0xE0 / 255.0),
            watermarkImageName: "WatermarkOrange"
        )
    }
    .padding()
}
