//
//  LobbyView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

struct LobbyView: View {
    var lobby: GameLobby
    var roomCode: String? = nil
    var isLoading: Bool = false
    var onStartGame: () -> Void = {}
    var onLeaveLobby: () -> Void = {}
    
    private var code: String {
        roomCode ?? lobby.code
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Room Code
            RoomCodeCard(code: code)
            
            // Lobby Players List
            VStack(spacing: 12) {
                ForEach(Array(lobby.players.enumerated()), id: \.element.id) { index, player in
                    LobbyPlayerCard(
                        name: player.name,
                        index: index,
                        isHost: player.id == lobby.hostUID,
                        showHostActions: lobby.isHost,
                        onKick: {},
                        onAddHost: {}
                    )
                }
            }
            
            Spacer()
            
            // Bottom Action Button
            if lobby.isHost {
                Button("Start Game") {
                    onStartGame()
                }
                .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                .disabled(isLoading || lobby.status != "waiting")
            } else {
                Text(lobby.status == "playing" ? "Starting game…" : "Waiting for host to start…")
                    .font(.spaceGrotesk(15, .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .appBackground()
    }
}

#Preview {
    LobbyView(
        lobby: GameLobby(
            code: "DIPF",
            hostUID: "p1",
            status: "waiting",
            players: [
                LobbyPlayer(id: "p1", name: "quincy"),
                LobbyPlayer(id: "p2", name: "emily"),
                LobbyPlayer(id: "p3", name: "david"),
                LobbyPlayer(id: "p4", name: "hannah"),
                LobbyPlayer(id: "p5", name: "aasas")
            ]
        ),
        isLoading: false
    )
}
