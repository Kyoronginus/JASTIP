//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Luggages", systemImage: "house") {
                GameView()
            }
            Tab("JASTIP", systemImage: "gear") {
                ObjectiveView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
