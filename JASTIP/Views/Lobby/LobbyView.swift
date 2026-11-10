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
    var onReorderPlayers: ([String]) -> Void = { _ in }
    
    @State private var showLeaveConfirmation = false
    
    private var code: String {
        roomCode ?? lobby.code
    }
    
    var body: some View {
        ZStack {
            // MARK: - Custom Background Asset
            Image("LobbyBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Konten Utama Lobby
            VStack(spacing: 16) {
                // MARK: - Top Navigation Bar (Leave Button)
                HStack {
                    // Back Button
                    Button {
                        showLeaveConfirmation = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
//                            Text(lobby.isHost ? "Close Lobby" : "Leave")
////                                .font(.plusJakarta(13, .bold))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: .white,
//                        borderColor: Color("TaxiYellow"),
                        foregroundColor: Color(.black),
                        cornerRadius: 14,
                        paddingVertical: 14,
                        paddingHorizontal: 15
                    ))
                    .padding(.trailing, 10)
                    
                    // MARK: - Room Code Display
                    RoomCodeCard(code: code)
//                        .scaleEffect(0.8)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                }
                
                // MARK: - Lobby Players List (Scrollable)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(Array(lobby.players.enumerated()), id: \.element.id) { index, player in
                            playerCard(player, at: index)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Spacer()
                
                // MARK: - Bottom Action
                if lobby.isHost {
                    Button("Start Game") {
                        onStartGame()
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                    .disabled(isLoading || lobby.status != "waiting")
                } else {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(lobby.status == "playing" ? "Starting game…" : "Waiting for host to start…")
                            .font(.spaceGrotesk(15, .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .safeAreaPadding(.top)
            .padding(.bottom, 30)
        }
        .confirmationDialog(
            Text(lobby.isHost ? "Close this lobby for all players?" : "Leave this lobby?"),
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                onLeaveLobby()
            } label: {
                Text(lobby.isHost ? "Close Lobby" : "Leave Lobby")
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func playerCard(_ player: LobbyPlayer, at index: Int) -> some View {
        let card = LobbyPlayerCard(
            name: player.name,
            index: index,
            isHost: player.id == lobby.hostUID,
            showHostActions: lobby.isHost,
            onKick: {},
            onAddHost: {}
        )

        if lobby.isHost && lobby.status == "waiting" && !isLoading {
            card
                .draggable(player.id)
                .dropDestination(for: String.self) { draggedIDs, location in
                    guard let draggedID = draggedIDs.first,
                          !isLoading else { return false }
                    return movePlayer(draggedID, over: player.id, at: location)
                }
        } else {
            card
        }
    }

    private func movePlayer(_ draggedID: String, over targetID: String, at location: CGPoint) -> Bool {
        let players = lobby.players
        guard let sourceIndex = players.firstIndex(where: { $0.id == draggedID }),
              let targetIndex = players.firstIndex(where: { $0.id == targetID }) else {
            return false
        }

        let insertionIndex = targetIndex + (location.y > 32 ? 1 : 0)
        var reorderedIDs = players.map(\.id)
        let movedID = reorderedIDs.remove(at: sourceIndex)
        let adjustedIndex = insertionIndex > sourceIndex ? insertionIndex - 1 : insertionIndex
        reorderedIDs.insert(movedID, at: adjustedIndex)

        guard reorderedIDs != players.map(\.id) else { return true }
        onReorderPlayers(reorderedIDs)
        return true
    }
}

#Preview("Lobby - Host View") {
    LobbyView(
        lobby: GameLobby(
            code: "DRPF",
            hostUID: "user_quincy",
            status: "waiting",
            players: [
                LobbyPlayer(id: "user_quincy", name: "quincy"),
                LobbyPlayer(id: "user_emily", name: "emily"),
                LobbyPlayer(id: "user_david", name: "david"),
                LobbyPlayer(id: "user_hannah", name: "hannah"),
                LobbyPlayer(id: "user_matheo", name: "matheo")
            ]
        ),
        roomCode: "DRPF"
    )
}
