//
//  StartView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct StartView: View {
@Bindable var viewModel: GameSessionViewModel
@State private var joinCode = ""
    
init(viewModel: GameSessionViewModel) {
    self.viewModel = viewModel
}
    
var body: some View {
    Group {
        if let lobby = viewModel.lobbyService.lobby {
            LobbyView(
                lobby: lobby,
                isLoading: viewModel.lobbyService.isLoading,
                onStartGame: {
                    Task { await viewModel.startCloudGame() }
                },
                onLeaveLobby: {
                    Task { await viewModel.lobbyService.leaveLobby() }
                }
            )
        } else {
            startView
                .padding()
                .appBackground()
        }
    }
    .appBackground()
    .alert(
        "Lobby",
        isPresented: Binding(
            get: { viewModel.lobbyService.errorMessage != nil },
            set: { if !$0 { viewModel.lobbyService.errorMessage = nil } }
        )
    ) {
        Button("OK") { viewModel.lobbyService.errorMessage = nil }
    } message: {
        Text(viewModel.lobbyService.errorMessage ?? "")
    }
}

private var startView: some View {
    VStack(spacing: 20) {
        Spacer()

        Text("JASTIP")
            .font(.system(size: 64, weight: .bold, design: .rounded))
        
        Spacer()

        TextField("Username", text: $viewModel.playerName)
            .textFieldStyle(.plain)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 40)

        Button("CREATE LOBBY") {
            Task {
                await viewModel.lobbyService.createLobby(playerName: viewModel.playerName)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.lobbyService.isLoading)

        Text("OR JOIN WITH A CODE")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)

        TextField("4-letter code", text: $joinCode)
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .multilineTextAlignment(.center)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .onChange(of: joinCode) { _, newValue in
                let alphabet = Set("ABCDEFGHJKLMNPQRSTUVWXYZ")
                joinCode = String(newValue.uppercased().filter { alphabet.contains($0) }.prefix(4))
            }

        Button("JOIN LOBBY") {
            Task {
                await viewModel.lobbyService.joinLobby(
                    code: joinCode,
                    playerName: viewModel.playerName
                )
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.lobbyService.isLoading || joinCode.count != 4)

        if viewModel.lobbyService.isLoading {
            ProgressView()
        }

        Spacer()
    }
}

private func lobbyView(_ lobby: GameLobby) -> some View {
    VStack(spacing: 20) {
        Spacer()
        Text("LOBBY")
            .font(.system(size: 42, weight: .bold, design: .rounded))
        Text(lobby.code)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
            .textSelection(.enabled)
        Text("Share this code with your players")
            .foregroundStyle(.secondary)

        VStack(alignment: .leading, spacing: 12) {
            Text("Players (\(lobby.players.count)/5)")
                .font(.headline)
            ForEach(lobby.players) { player in
                Label(player.name, systemImage: "person.fill")
            }
            if lobby.isHost && lobby.players.count == 1 {
                Text("You can start the game now or wait for more players.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))

        if lobby.isHost {
            Button("START GAME") {
                Task {
                    await viewModel.startCloudGame()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.lobbyService.isLoading || lobby.status != "waiting")
        } else {
            Text(lobby.status == "playing" ? "Starting game…" : "Waiting for the host to start…")
                .foregroundStyle(.secondary)
        }

        Button("LEAVE LOBBY", role: .destructive) {
            Task { await viewModel.lobbyService.leaveLobby() }
        }
        .disabled(viewModel.lobbyService.isLoading)
        if viewModel.lobbyService.isLoading {
            ProgressView("Leaving lobby…")
        }
        Spacer()
    }
}
}

#Preview("Light") {
    StartView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.light)
}

//#Preview("Dark") {
//    StartView(viewModel: GameSessionViewModel())
//        .preferredColorScheme(.dark)
//}
