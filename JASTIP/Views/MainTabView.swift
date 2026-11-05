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
            Tab("JASTIP", systemImage: "bubble") {
                ObjectiveView()
            }
            Tab("JASTIP", systemImage: "bubble") {
                ObjectiveView()
            }
            Tab("JASTIP", systemImage: "bubble") {
                ObjectiveView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
