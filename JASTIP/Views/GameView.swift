//
//  GameView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct GameView: View {
    @State private var showScanner = false
    
    var body: some View {
        HStack{
            AirlineCard()
            Spacer()
            VStack(spacing: 12){
                Spacer()
                Text("TIME: 08.00")
                
                Spacer()
                
                Button("Open Camera") {
                    
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button("Next Hour") {
                    
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
            }
            Spacer()
            AirlineCard()
                .rotationEffect(.degrees(180))
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview(traits: .landscapeRight) {
    GameView()
}
