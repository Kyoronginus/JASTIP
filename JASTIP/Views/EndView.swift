//
//  ScoringView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 12/10/26.
//

import SwiftUI

struct EndView: View {
    var onFinishGame: () -> Void = {}
    
    var body: some View {
        Button("SELESAI MAIN") {
            onFinishGame()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview("Light") {
    EndView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    EndView()
        .preferredColorScheme(.dark)
}
