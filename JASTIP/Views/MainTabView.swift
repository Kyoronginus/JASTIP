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
            Tab("Baggages", systemImage: "suitcase.rolling") {
                GameView()
            }
            Tab("Order", systemImage: "scroll") {
                ObjectiveView()
            }
            Tab("Stats", systemImage: "chart.bar") {
                ObjectiveView()
            }
            Tab("Items", systemImage: "robotic.vacuum") {
                ObjectiveView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
