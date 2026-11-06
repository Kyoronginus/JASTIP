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
    
    @State private var showLeaveConfirmation = false
    
    private var code: String {
        roomCode ?? lobby.code
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Top Navigation Bar (Leave Button)
            HStack {
//                Button {
//                    
//                } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 14, weight: .bold))
//                        Text(lobby.isHost ? "Close Lobby" : "Leave")
//                            .font(.plusJakarta(13, .bold))
//                    }
//                    .foregroundStyle(Color("NavyBlack"))
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(Color("TaxiYellow"))
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color("NavyBlack"), lineWidth: 2)
//                    )
//                }
                
                // Back Button
                Button {
                    showLeaveConfirmation = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        Text(lobby.isHost ? "Close Lobby" : "Leave")
                            .font(.plusJakarta(13, .bold))
                    }
                }
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: .black,
                    borderColor: Color("TaxiYellow"),
                    foregroundColor: Color("TaxiYellow"),
                    cornerRadius: 14,
                    paddingVertical: 14,
                    paddingHorizontal: 15
                ))
                .padding(.trailing, 10)
                
                Spacer()
            }
            
            // MARK: - Room Code Display
            RoomCodeCard(code: code)
            
            // MARK: - Lobby Players List (Scrollable)
            ScrollView(showsIndicators: false) {
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
        .padding(.top, 16)
        .padding(.bottom, 24)
        .appBackground()
        .confirmationDialog(
            lobby.isHost ? "Close this lobby for all players?" : "Leave this lobby?",
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button(lobby.isHost ? "Close Lobby" : "Leave Lobby", role: .destructive) {
                onLeaveLobby()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
