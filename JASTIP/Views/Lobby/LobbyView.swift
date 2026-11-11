//
//  LobbyView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

private struct LobbyPlayerFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

struct LobbyView: View {
    var lobby: GameLobby
    var roomCode: String? = nil
    var isLoading: Bool = false
    var onStartGame: () -> Void = {}
    var onLeaveLobby: () -> Void = {}
    var onReorderPlayers: ([String]) -> Void = { _ in }
    
    @State private var showLeaveConfirmation = false
    @State private var draggingPlayerID: String?
    @State private var dragOffset: CGFloat = 0
    @State private var dragStartMidY: CGFloat = 0
    @State private var playerFrames: [String: CGRect] = [:]
    
    private var code: String {
        roomCode ?? lobby.code
    }
    
    var body: some View {
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
                    ForEach(lobby.players) { player in
                        let index = lobby.players.firstIndex { $0.id == player.id } ?? 0
                        playerCard(player, at: index)
                            .background {
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: LobbyPlayerFramePreferenceKey.self,
                                        value: [player.id: geometry.frame(in: .named("lobbyPlayers"))]
                                    )
                                }
                            }
                            .offset(y: draggingPlayerID == player.id ? dragOffset : 0)
                            .scaleEffect(draggingPlayerID == player.id ? 1.03 : 1)
                            .zIndex(draggingPlayerID == player.id ? 1 : 0)
                    }
                }
                .padding(.vertical, 4)
            }
            .coordinateSpace(name: "lobbyPlayers")
            .onPreferenceChange(LobbyPlayerFramePreferenceKey.self) { playerFrames = $0 }
            
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
//        .padding()
        .safeAreaPadding(.top)
        .padding(.bottom, 30)
        .lobbyBackground()
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
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .id(player.id)
                .gesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named("lobbyPlayers")))
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                beginDragging(player.id)
                            case .second(true, let drag?):
                                beginDragging(player.id)
                                guard draggingPlayerID == player.id else { return }
                                dragOffset = drag.translation.height
                            default:
                                break
                            }
                        }
                        .onEnded { value in
                            guard draggingPlayerID == player.id else { return }
                            if case .second(true, let drag?) = value {
                                finishDragging(player.id, translation: drag.translation.height)
                            }
                            draggingPlayerID = nil
                            dragOffset = 0
                        }
                )
        } else {
            card
        }
    }

    private func beginDragging(_ playerID: String) {
        guard draggingPlayerID == nil,
              let frame = playerFrames[playerID] else { return }
        draggingPlayerID = playerID
        dragStartMidY = frame.midY
    }

    private func finishDragging(_ playerID: String, translation: CGFloat) {
        let projectedMidY = dragStartMidY + translation
        guard let target = playerFrames
            .filter({ $0.key != playerID })
            .min(by: { abs($0.value.midY - projectedMidY) < abs($1.value.midY - projectedMidY) }) else { return }

        var reorderedIDs = lobby.players.map(\.id)
        guard let sourceIndex = reorderedIDs.firstIndex(of: playerID) else { return }
        reorderedIDs.remove(at: sourceIndex)
        guard let targetIndex = reorderedIDs.firstIndex(of: target.key) else { return }
        let insertionIndex = targetIndex + (projectedMidY > target.value.midY ? 1 : 0)
        reorderedIDs.insert(playerID, at: insertionIndex)

        guard reorderedIDs != lobby.players.map(\.id) else { return }
        onReorderPlayers(reorderedIDs)
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
