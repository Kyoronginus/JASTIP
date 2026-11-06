//
//  StartView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

enum StartStep {
    case home
    case inputCode
    case inputName(isHost: Bool)
}

struct StartView: View {
    @Bindable var viewModel: GameSessionViewModel
    @State private var joinCode = ""
    @State private var step: StartStep = .home
    
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
                        Task {
                            await viewModel.lobbyService.leaveLobby()
                            withAnimation(.easeInOut(duration: 0.15)) {
                                step = .home
                                joinCode = ""
                            }
                        }
                    }
                )
            } else {
                ZStack {
                    switch step {
                    case .home:
                        HomeView(
                            onJoinGame: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    step = .inputCode
                                }
                            },
                            onCreateGame: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    step = .inputName(isHost: true)
                                }
                            }
                        )
                        .transition(.opacity)

                    case .inputCode:
                        InputRoomCodeView(
                            code: $joinCode,
                            onBack: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    step = .home
                                    joinCode = ""
                                }
                            },
                            onSubmit: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    step = .inputName(isHost: false)
                                }
                            }
                        )
                        .transition(.opacity)

                    case .inputName(let isHost):
                        InputNameView(
                            name: $viewModel.playerName,
                            isHost: isHost,
                            isLoading: viewModel.lobbyService.isLoading,
                            onBack: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if isHost {
                                        step = .home
                                    } else {
                                        step = .inputCode
                                    }
                                }
                            },
                            onSubmit: {
                                Task {
                                    if isHost {
                                        await viewModel.lobbyService.createLobby(playerName: viewModel.playerName)
                                    } else {
                                        await viewModel.lobbyService.joinLobby(
                                            code: joinCode,
                                            playerName: viewModel.playerName
                                        )
                                    }
                                }
                            }
                        )
                        .transition(.opacity)
                    }
                }
            }
        }
        .appBackground()
        .onChange(of: viewModel.lobbyService.lobby == nil) { _, isLobbyNil in
            // Jika sebelumnya di dalam lobby dan host menutup room, kembalikan ke home
            if isLobbyNil {
                withAnimation(.easeInOut(duration: 0.15)) {
                    step = .home
                    joinCode = ""
                }
            }
        }
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
}

#Preview("Light") {
    StartView(viewModel: GameSessionViewModel())
        .preferredColorScheme(.light)
}
