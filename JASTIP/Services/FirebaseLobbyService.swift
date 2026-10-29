import FirebaseAuth
import FirebaseFirestore
import Foundation
import Observation

struct LobbyPlayer: Identifiable {
    let id: String
    let name: String
}

struct GameLobby {
    let code: String
    let hostUID: String
    let status: String
    let players: [LobbyPlayer]

    var isHost: Bool {
        Auth.auth().currentUser?.uid == hostUID
    }
}

struct CloudGameState: Codable, Equatable {
    let card: AirlineCardModel
    let pieceWeights: [String: Int]
    var currentHour: Int
    var delayHours: Int
    var isGameOver: Bool
    var currentEvent: RandomEventModel?
    var activeHourEvent: RandomEventModel?
    var triggeredUniqueEvents: Set<RandomEventType>
    var lastRoundEventType: RandomEventType?
}

@Observable
final class FirebaseLobbyService {
    private(set) var lobby: GameLobby?
    private(set) var playerStatuses: [String: PlayerSyncPayload] = [:]
    private(set) var revealedPieces: [RevealedPiece] = []
    private(set) var isLoading = false
    var errorMessage: String?

    var onGameStarted: ((AirlineCardModel, [String: Int]) -> Void)?
    var onGameStateChanged: ((CloudGameState) -> Void)?
    var onPlayerStatusesChanged: (([String: PlayerSyncPayload]) -> Void)?
    var onScannedPiecesChanged: (([RevealedPiece]) -> Void)?

    var currentPlayerID: String? {
        Auth.auth().currentUser?.uid
    }

    @ObservationIgnored private let database = Firestore.firestore()
    @ObservationIgnored private var lobbyListener: ListenerRegistration?
    @ObservationIgnored private var playerListener: ListenerRegistration?
    @ObservationIgnored private var scanListener: ListenerRegistration?
    @ObservationIgnored private var lastObservedGameState: CloudGameState?

    func createLobby(playerName: String) async {
        await performLobbyAction {
            let uid = try await self.ensureSignedIn()
            let name = Self.validatedName(playerName)

            for _ in 0..<10 {
                let code = Self.makeCode()
                let reference = self.database.collection("lobbies").document(code)
                let created = try await self.createLobbyDocument(
                    reference,
                    uid: uid,
                    playerName: name
                )
                guard created else { continue }
                self.listen(to: reference)
                return
            }

            throw LobbyError.couldNotCreateCode
        }
    }

    func joinLobby(code: String, playerName: String) async {
        await performLobbyAction {
            let uid = try await self.ensureSignedIn()
            let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            guard normalizedCode.count == 4,
                  normalizedCode.allSatisfy({ Self.codeAlphabet.contains($0) }) else {
                throw LobbyError.invalidCode
            }

            let reference = self.database.collection("lobbies").document(normalizedCode)
            let snapshot = try await reference.getDocument()
            guard let data = snapshot.data() else { throw LobbyError.lobbyNotFound }
            guard data["status"] as? String == "waiting" else { throw LobbyError.lobbyAlreadyStarted }

            let players = data["players"] as? [String: [String: String]] ?? [:]
            if players[uid] == nil {
                guard players.count < 5 else { throw LobbyError.lobbyFull }
                try await reference.updateData([
                    "players.\(uid)": ["uid": uid, "name": Self.validatedName(playerName)],
                    "updatedAt": FieldValue.serverTimestamp()
                ])
            }

            self.listen(to: reference)
        }
    }

    func startGame(state: CloudGameState) async {
        guard let lobby, lobby.isHost else { return }
        await performLobbyAction {
            try await self.database.collection("lobbies").document(lobby.code).updateData([
                "status": "playing",
                "game": try Self.encode(state),
                "updatedAt": FieldValue.serverTimestamp()
            ])
        }
    }

    func publishGameState(_ state: CloudGameState) async {
        guard let lobby, lobby.isHost, lobby.status == "playing" else { return }
        do {
            try await database.collection("lobbies").document(lobby.code).updateData([
                "game": try Self.encode(state),
                "updatedAt": FieldValue.serverTimestamp()
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func publishPlayerStatus(_ status: PlayerSyncPayload) async {
        guard let lobby, lobby.status == "playing",
              let uid = currentPlayerID else { return }
        do {
            try await database.collection("lobbies").document(lobby.code)
                .collection("playerStates").document(uid).setData([
                    "peerId": uid,
                    "name": Self.validatedName(status.name),
                    "suitcaseWeight": status.suitcaseWeight,
                    "carryOnWeight": status.carryOnWeight,
                    "isBoarded": status.isBoarded,
                    "updatedAt": FieldValue.serverTimestamp()
                ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func publishScannedPiece(_ revealedPiece: RevealedPiece) async {
        guard let lobby, lobby.status == "playing" else { return }
        do {
            try await database.collection("lobbies").document(lobby.code)
                .collection("scans").document(revealedPiece.piece.id)
                .setData(try Self.encode(revealedPiece))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveLobby() async {
        guard let lobby, let uid = currentPlayerID else { return }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let reference = database.collection("lobbies").document(lobby.code)
            if lobby.hostUID == uid {
                let playerStates = try await reference.collection("playerStates").getDocuments()
                let scans = try await reference.collection("scans").getDocuments()
                let batch = database.batch()
                playerStates.documents.forEach { batch.deleteDocument($0.reference) }
                scans.documents.forEach { batch.deleteDocument($0.reference) }
                batch.deleteDocument(reference)
                try await batch.commit()
            } else {
                try await reference.collection("playerStates").document(uid).delete()
                try await reference.updateData([
                    "players.\(uid)": FieldValue.delete(),
                    "updatedAt": FieldValue.serverTimestamp()
                ])
            }
            stopListening()
            self.lobby = nil
            playerStatuses = [:]
            revealedPieces = []
            lastObservedGameState = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performLobbyAction(_ action: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func ensureSignedIn() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid {
            return uid
        }

        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signInAnonymously { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let uid = result?.user.uid {
                    continuation.resume(returning: uid)
                } else {
                    continuation.resume(throwing: LobbyError.signInFailed)
                }
            }
        }
    }

    private func createLobbyDocument(
        _ reference: DocumentReference,
        uid: String,
        playerName: String
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            database.runTransaction({ transaction, errorPointer -> Any? in
                do {
                    let existingLobby = try transaction.getDocument(reference)
                    guard !existingLobby.exists else { return false }

                    transaction.setData([
                        "hostUID": uid,
                        "status": "waiting",
                        "players": [uid: ["uid": uid, "name": playerName]],
                        "createdAt": FieldValue.serverTimestamp(),
                        "updatedAt": FieldValue.serverTimestamp()
                    ], forDocument: reference)
                    return true
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }, completion: { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let created = result as? Bool {
                    continuation.resume(returning: created)
                } else {
                    continuation.resume(throwing: LobbyError.invalidData)
                }
            })
        }
    }

    private func listen(to reference: DocumentReference) {
        stopListening()
        lastObservedGameState = nil

        lobbyListener = reference.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let data = snapshot?.data() else {
                    self.lobby = nil
                    self.errorMessage = LobbyError.lobbyClosed.localizedDescription
                    return
                }

                let previousStatus = self.lobby?.status
                guard let playersData = data["players"] as? [String: [String: String]],
                      let hostUID = data["hostUID"] as? String,
                      let status = data["status"] as? String else {
                    self.errorMessage = LobbyError.invalidLobbyData.localizedDescription
                    return
                }
                self.lobby = GameLobby(
                    code: reference.documentID,
                    hostUID: hostUID,
                    status: status,
                    players: playersData.values.compactMap { player in
                        guard let uid = player["uid"], let name = player["name"] else { return nil }
                        return LobbyPlayer(id: uid, name: name)
                    }.sorted {
                        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    }
                )

                if status == "playing" {
                    do {
                        guard let game = data["game"] as? [String: Any] else {
                            throw LobbyError.invalidGameData
                        }
                        let state = try Self.decode(CloudGameState.self, from: game)
                        if previousStatus != "playing" {
                            self.onGameStarted?(state.card, state.pieceWeights)
                        }
                        if self.lastObservedGameState != state {
                            self.lastObservedGameState = state
                            self.onGameStateChanged?(state)
                        }
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }

        playerListener = reference.collection("playerStates").addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                var statuses: [String: PlayerSyncPayload] = [:]
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    guard let name = data["name"] as? String,
                          let suitcaseWeight = data["suitcaseWeight"] as? Int,
                          let carryOnWeight = data["carryOnWeight"] as? Int,
                          let isBoarded = data["isBoarded"] as? Bool else {
                        self.errorMessage = LobbyError.invalidPlayerData.localizedDescription
                        return
                    }
                    statuses[document.documentID] = PlayerSyncPayload(
                        peerId: document.documentID,
                        name: name,
                        suitcaseWeight: suitcaseWeight,
                        carryOnWeight: carryOnWeight,
                        isBoarded: isBoarded
                    )
                }
                self.playerStatuses = statuses
                self.onPlayerStatusesChanged?(statuses)
            }
        }

        scanListener = reference.collection("scans").addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                var scans: [RevealedPiece] = []
                for document in snapshot?.documents ?? [] {
                    do {
                        scans.append(try Self.decode(RevealedPiece.self, from: document.data()))
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
                self.revealedPieces = scans.sorted { $0.id < $1.id }
                self.onScannedPiecesChanged?(self.revealedPieces)
            }
        }
    }

    private func stopListening() {
        lobbyListener?.remove()
        playerListener?.remove()
        scanListener?.remove()
        lobbyListener = nil
        playerListener = nil
        scanListener = nil
    }

    private static func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw LobbyError.invalidData
        }
        return dictionary
    }

    private static func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(type, from: data)
    }

    private static func validatedName(_ name: String) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return String((trimmedName.isEmpty ? "Player" : trimmedName).prefix(30))
    }

    private static func makeCode() -> String {
        String((0..<4).compactMap { _ in codeAlphabet.randomElement() })
    }

    private static let codeAlphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")
}

private enum LobbyError: LocalizedError {
    case couldNotCreateCode
    case invalidCode
    case lobbyNotFound
    case lobbyAlreadyStarted
    case lobbyFull
    case lobbyClosed
    case signInFailed
    case invalidData
    case invalidLobbyData
    case invalidGameData
    case invalidPlayerData

    var errorDescription: String? {
        switch self {
        case .couldNotCreateCode: "Could not generate an unused lobby code. Please try again."
        case .invalidCode: "Enter the 4-letter lobby code."
        case .lobbyNotFound: "No lobby was found for that code."
        case .lobbyAlreadyStarted: "That lobby has already started."
        case .lobbyFull: "That lobby already has 5 players."
        case .lobbyClosed: "The lobby was closed or is no longer available."
        case .signInFailed: "Anonymous Firebase sign-in failed. Check Firebase Authentication settings."
        case .invalidData: "Could not encode game data for Firestore."
        case .invalidLobbyData: "The lobby document is missing required data."
        case .invalidGameData: "The lobby game state is missing or invalid."
        case .invalidPlayerData: "A player status document is missing required data."
        }
    }
}
