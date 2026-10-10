//
//  AirlineCard.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct AirlineCard: View {
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "airplane.departure")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            
            Spacer()
            
            Text("Time: 15.00")
            Text("Max Capacity: ")
            Text("Max Carry-on: ")
            
            Spacer()
        }
        .padding(20)
        .frame(width: 200, height: 300)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// Visual Preview
#Preview() {
    ZStack {
        Color(uiColor: .secondarySystemBackground)
            .ignoresSafeArea()
        
        AirlineCard()
        .padding()
    }
}
