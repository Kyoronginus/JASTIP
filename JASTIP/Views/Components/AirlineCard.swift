//
//  AirlineCard.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct AirlineCard: View {
    let data: AirlineCardModel

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Airline Card")
                .font(.headline)
                .padding(.bottom, 20)

            Image(systemName: "airplane.departure")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            
            Spacer()
            Text("Max Capacity: \(data.maxCapacityKg)kg")
            Text("Max Carry-on: \(data.maxCarryOnKg)kg")
            Text("Depart: \(data.departureTime)")
            Spacer()
        }
        .padding(20)
        .frame(width: 200, height: 300)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1) 
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview("Light") {
    AirlineCard(data: AirlineCardModel(
        id: "1",
        maxCapacityKg: 20,
        maxCarryOnKg: 7,
        departureTime: "15.00"
    ))
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    AirlineCard(data: AirlineCardModel(
        id: "1",
        maxCapacityKg: 20,
        maxCarryOnKg: 7,
        departureTime: "15.00"
    ))
    .preferredColorScheme(.dark)
}

