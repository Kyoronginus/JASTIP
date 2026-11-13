//
//  StatsView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct StatsView: View {
    var viewModel: GameSessionViewModel? = nil
    @State private var sampleToast: ToastOptions? = nil
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Broadcast Toast Playground")
                    .font(.plusJakarta(18, .bold))
                    .padding(.bottom, 10)
                
                Button("Broadcast: Success Toast") {
                    if let vm = viewModel {
                        let sender = vm.playerName.isEmpty ? "Player" : vm.playerName
                        vm.showToast("\(sender): Barang berhasil masuk koper! 🎉", type: .success)
                    } else {
                        sampleToast = ToastOptions(message: "Success Toast Triggered!", type: .success)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Broadcast: Error Toast") {
                    if let vm = viewModel {
                        let sender = vm.playerName.isEmpty ? "Player" : vm.playerName
                        vm.showToast("\(sender): Koper kelebihan muatan! ⚠️", type: .error)
                    } else {
                        sampleToast = ToastOptions(message: "Error Toast Triggered!", type: .error)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                Button("Broadcast: Info Toast") {
                    if let vm = viewModel {
                        let sender = vm.playerName.isEmpty ? "Player" : vm.playerName
                        vm.showToast("\(sender) sedang menata koper...", type: .info)
                    } else {
                        sampleToast = ToastOptions(message: "Info Toast Triggered!", type: .info)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding()
        }
        .toastNotification($sampleToast)
    }
}

#Preview {
    StatsView()
}
