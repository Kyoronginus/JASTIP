//
//  StartView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct StartView: View {
    // Menggunakan @Bindable karena ViewModel kalian menggunakan @Observable macro terbaru
    @Bindable var viewModel: GameSessionViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("JASTIP")
                .padding()
                .font(.system(size: 64, weight: .bold, design: .rounded))
            
            // Indikator Lobby Status (Real-time dari Network Manager)
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.secondary)
                Text("\(viewModel.connectedPlayersCount) Player(s) Connected")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            
            Spacer()
            
            Button("START") {
                // Memanggil fungsi network trigger yang akan menyalakan isGameStarted
                // dan otomatis memindahkan semua device ke GameView secara serentak
                viewModel.triggerStartGame()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

#Preview("Light") {
    StartView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StartView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.dark)
}
