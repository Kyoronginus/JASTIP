//
//  StartView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct StartView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Spacer()
                Text("JASTIP!")
                    .padding()
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button("START") {
                    let randomCard = AirlineCardCatalog.getRandomCard()
                    path.append(randomCard)
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
            .navigationDestination(for: AirlineCardModel.self) { card in
                GameView(airlineCard: card)
            }
        }
    }
}

#Preview("Light") {
    StartView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StartView()
        .preferredColorScheme(.dark)
}
