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
    
    init(viewModel: GameSessionViewModel, lockHostToggle: Bool) {
        self.viewModel = viewModel
    }
    
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
            
            TextField("Username", text: $viewModel.playerName)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                .padding(.horizontal, 40)
            
            Button("START") {
                viewModel.triggerStartGame()
                
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.lockHostToggle)
            
            Spacer()
            
            Toggle("Host", isOn: $viewModel.lockHostToggle)
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .tint(.blue)
        }
        .padding()
    }
}

#Preview("Light") {
    StartView(viewModel: GameSessionViewModel(), lockHostToggle: false)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StartView(viewModel: GameSessionViewModel(), lockHostToggle: false)
        .preferredColorScheme(.dark)
}
