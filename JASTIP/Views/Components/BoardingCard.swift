
//
//  BoardingButton.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 24/10/26.
//

import SwiftUI

struct BoardingCard: View {
    var departureTime: String = "15:00"
    var currentTimeString: String = "08:00"
    var isHost: Bool = false
    var isNextHourDisabled: Bool = false
    var onNextHour: () -> Void = {}
    
    // Parsing digit jam dan menit
    private var digits: (Character, Character, Character, Character) {
        let clean = currentTimeString.replacingOccurrences(of: ":", with: "")
        let chars = Array(clean)
        let d1 = chars.count > 0 ? chars[0] : "0"
        let d2 = chars.count > 1 ? chars[1] : "8"
        let d3 = chars.count > 2 ? chars[2] : "0"
        let d4 = chars.count > 3 ? chars[3] : "0"
        return (d1, d2, d3, d4)
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background Card
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("NavyBlack"))
                .frame(height: 120)
            
            Image("AsteriskYellow")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.white.opacity(0.08))
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: 24, y: 65)

            
            // konten Card
            if isHost {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Boarding Time: \(departureTime)")
                            .font(.plusJakarta(15, .bold))
                            .foregroundStyle(Color("TaxiYellow"))
                        
                        flipClockView
                    }
                    
                    Spacer()
                    
                    Button(action: onNextHour) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 15, weight: .bold))
                            Text("+01:00")
                                .font(.plusJakarta(15, .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: Color("NavyBlack"),
                        borderColor: Color("TaxiYellow"),
                        foregroundColor: Color("TaxiYellow"),
                        cornerRadius: 14,
                        paddingVertical: 10,
                        paddingHorizontal: 14
                    ))
                    .disabled(isNextHourDisabled)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            } else {
                VStack(alignment: .center, spacing: 8) {
                    Text("Boarding Time: \(departureTime)")
                        .font(.plusJakarta(15, .bold))
                        .foregroundStyle(Color("TaxiYellow"))
                    
                    flipClockView
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Flip Clock Row
    private var flipClockView: some View {
        let (d1, d2, d3, d4) = digits
        return HStack(spacing: 5) {
            flipTile(d1)
            flipTile(d2)
            
            Image("ClockColon")
                .resizable()
                .scaledToFit()
                .frame(width: 8, height: 20)
                .padding(.horizontal, 3)
            
            flipTile(d3)
            flipTile(d4)
        }
    }
    
    // MARK: - Flip Tile Satuan
    private func flipTile(_ digit: Character) -> some View {
        ZStack {
            // Background Tile Kotak Jam
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x24 / 255.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0x22 / 255.0, green: 0x2A / 255.0, blue: 0x38 / 255.0), lineWidth: 1)
                )
            
            // Garis celah tengah mekanik (Split-flap seam)
            Rectangle()
                .fill(Color(red: 0x0A / 255.0, green: 0x0D / 255.0, blue: 0x14 / 255.0))
                .frame(height: 1)
            
            // Angka Jam
            Text(String(digit))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0xF5 / 255.0, green: 0xF4 / 255.0, blue: 0xEE / 255.0))
        }
        .frame(width: 36, height: 52)
    }
}

#Preview("Host View") {
    VStack {
        BoardingCard(
            departureTime: "15:00",
            currentTimeString: "08:00",
            isHost: true
        )
    }
    .padding()
}

#Preview("Non-Host View") {
    VStack {
        BoardingCard(
            departureTime: "15:00",
            currentTimeString: "08:00",
            isHost: false
        )
    }
    .padding()
}
