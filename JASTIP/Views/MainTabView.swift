//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    var viewModel: GameSessionViewModel
    
    var body: some View {
        TabView {
            Tab("Baggages", systemImage: "suitcase.rolling") {
                GameView(viewModel: viewModel)
            }
            Tab("Order", systemImage: "scroll") {
                ObjectiveView(viewModel: viewModel)
            }
            Tab("Stats", systemImage: "chart.bar") {
                ObjectiveView(viewModel: viewModel)
            }
            Tab("Items", systemImage: "robotic.vacuum") {
                ObjectiveView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    MainTabView(viewModel: GameSessionViewModel())
}
