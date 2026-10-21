//
//  NetworkSessionManager.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 14/10/26.
//

import Foundation
import MultipeerConnectivity
import Observation
import UIKit

@Observable
class NetworkSessionManager: NSObject {
    // Bonjour Service Type: max 15 karakter, huruf kecil, angka, tanda strip
    private let serviceType = "jastip-game"
    private let maxOtherPlayers = 5 // 6 pemain total (3 teman + diri sendiri)
    
    // Identitas disimpan, jadi tetap sama setelah app ditutup / reconnect
    private let myPeerID: MCPeerID = NetworkSessionManager.loadOrCreatePeerID()
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    // MARK: - State untuk UI
    var connectedPeersCount: Int = 1 // Termasuk device ini sendiri
    var connectedPeerNames: [String] = []
    var isReconnecting: Bool = false      // true kalau ada pemain putus di tengah game
    var missingPeerNames: [String] = []   // pemain yang sedang putus
    var isHost: Bool = false              // sementara: yang menekan START
    
    // MARK: - Callbacks
    var onStartGameReceived: ((AirlineCardModel, [String: Int]) -> Void)?
    var onNextHourReceived: (() -> Void)?
    var onNextHourPayloadReceived: ((NextHourPayload) -> Void)?
    var onScannedItemReceived: ((RevealedPiece, Int) -> Void)?
    var snapshotProvider: (() -> Data?)?       // host: encode state game saat ini
    var onSnapshotReceived: ((Data) -> Void)?  // client: terapkan state dari host
    var myDisplayName: String { myPeerID.displayName } // Expose nama peer device ini
    var onPlayerSyncReceived: ((String, PlayerSyncPayload) -> Void)?// Callback ketika menerima update status & bobot dari pemain lain
    
    
    // MARK: - Bookkeeping
    private var gameInProgress = false
    private var knownPeers: Set<String> = []   // displayName semua pemain saat game mulai
    private var wasBackgrounded = false
    
    override init() {
        super.init()
        buildSession()
        startDiscovery()
    }
    
    // MARK: - Persistent identity
    private static let peerIDKey = "jastip.peerID"
    
    private static func loadOrCreatePeerID() -> MCPeerID {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: peerIDKey),
           let saved = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            return saved
        }
        // Suffix acak supaya dua HP yang sama-sama bernama "iPhone" tidak bentrok
        let shortID = String(UUID().uuidString.prefix(4))
        let name = "\(String(UIDevice.current.name.prefix(40)))-\(shortID)"
        let peerID = MCPeerID(displayName: name)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true) {
            defaults.set(data, forKey: peerIDKey)
        }
        return peerID
    }
    
    // MARK: - Session & discovery
    private func buildSession() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
    }
    
    private func startDiscovery() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    private func stopDiscovery() {
        advertiser?.stopAdvertisingPeer()
        advertiser?.delegate = nil
        browser?.stopBrowsingForPeers()
        browser?.delegate = nil
    }
    
    // MARK: - App lifecycle
    /// Panggil saat scenePhase == .background (layar terkunci / pindah app).
    func appDidEnterBackground() {
        wasBackgrounded = true
        stopDiscovery()
        session.disconnect() // peer lain langsung tahu kita pergi
    }
    
    /// Panggil saat scenePhase == .active. Bangun ulang session lalu gabung lagi.
    func appDidBecomeActive() {
        guard wasBackgrounded else { return }
        wasBackgrounded = false
        stopDiscovery()
        session.delegate = nil
        session.disconnect()
        buildSession()
        startDiscovery()
    }
    
    // MARK: - Game bookkeeping
    private func lockInPlayers() {
        gameInProgress = true
        knownPeers = Set(session.connectedPeers.map { $0.displayName } + [myPeerID.displayName])
    }
    
    func endGame() {
        gameInProgress = false
        knownPeers = []
        missingPeerNames = []
        isReconnecting = false
    }
    
    // MARK: - Sending
    private func send(_ message: String, to peers: [MCPeerID]) {
        guard !peers.isEmpty, let data = message.data(using: .utf8) else { return }
        try? session.send(data, toPeers: peers, with: .reliable)
    }
    
    private func broadcast(_ message: String) {
        send(message, to: session.connectedPeers)
    }
    
    struct StartGamePayload: Codable {
        let card: AirlineCardModel
        let pieceWeights: [String: Int]
    }
    
    func sendStartGameTrigger(card: AirlineCardModel, pieceWeights: [String: Int] = [:]) {
        let payload = StartGamePayload(card: card, pieceWeights: pieceWeights)
        guard let jsonData = try? JSONEncoder().encode(payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        isHost = true // sementara: yang menekan START jadi host
        lockInPlayers()
        broadcast("START_GAME:\(jsonString)")
        
        // Trigger untuk device yang memencet tombol START
        DispatchQueue.main.async { self.onStartGameReceived?(card, pieceWeights) }
    }
    
    func sendScannedItem(piece: RevealedPiece, weight: Int) {
        struct ScanPayload: Codable {
            let piece: PieceModel
            let weight: Int
        }
        let payload = ScanPayload(piece: piece.piece, weight: weight)
        guard let jsonData = try? JSONEncoder().encode(payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        broadcast("SCAN_ITEM:\(jsonString)")
    }
    
    func sendNextHourTrigger(payload: NextHourPayload) {
        guard let jsonData = try? JSONEncoder().encode(payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        broadcast("NEXT_HOUR:\(jsonString)")
    }
    
    func sendPlayerSync(payload: PlayerSyncPayload) {
        guard let data = try? JSONEncoder().encode(payload),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        let message = "PLAYER_SYNC:" + jsonString
        guard let msgData = message.data(using: .utf8) else { return }
        
        if !session.connectedPeers.isEmpty {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    private func sendSnapshot(to peerID: MCPeerID) {
        guard let data = snapshotProvider?(),
              let json = String(data: data, encoding: .utf8) else { return }
        send("SNAPSHOT:\(json)", to: [peerID])
    }
    
    deinit {
        stopDiscovery()
        session?.disconnect()
    }
}

// MARK: - MCSessionDelegate
extension NetworkSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            // Abaikan callback dari session lama yang sudah dibuang
            guard session === self.session else { return }
            
            let name = peerID.displayName
            let isKnownPlayer = self.gameInProgress && self.knownPeers.contains(name)
            
            switch state {
            case .connected:
                print("🟢 Connected to \(name)")
                if isKnownPlayer {
                    self.missingPeerNames.removeAll { $0 == name }
                    // Host mengejar ulang state untuk pemain yang kembali
                    if self.isHost { self.sendSnapshot(to: peerID) }
                }
            case .notConnected:
                print("🔴 Disconnected from \(name)")
                if isKnownPlayer && !self.missingPeerNames.contains(name) {
                    self.missingPeerNames.append(name)
                }
            case .connecting:
                print("🟡 Connecting to \(name)")
            @unknown default:
                break
            }
            
            self.connectedPeersCount = session.connectedPeers.count + 1
            self.connectedPeerNames = session.connectedPeers.map { $0.displayName }
            self.isReconnecting = !self.missingPeerNames.isEmpty
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = String(data: data, encoding: .utf8) else { return }
        DispatchQueue.main.async {
            if message.hasPrefix("START_GAME:") {
                let jsonString = String(message.dropFirst("START_GAME:".count))
                if let jsonData = jsonString.data(using: .utf8) {
                    self.lockInPlayers()
                    if let payload = try? JSONDecoder().decode(StartGamePayload.self, from: jsonData) {
                        self.onStartGameReceived?(payload.card, payload.pieceWeights)
                    } else if let card = try? JSONDecoder().decode(AirlineCardModel.self, from: jsonData) {
                        self.onStartGameReceived?(card, [:])
                    }
                }
            } else if message.hasPrefix("NEXT_HOUR:") {
                let jsonString = String(message.dropFirst("NEXT_HOUR:".count))
                if let jsonData = jsonString.data(using: .utf8),
                   let payload = try? JSONDecoder().decode(NextHourPayload.self, from: jsonData) {
                    self.onNextHourPayloadReceived?(payload)
                }
            } else if message.hasPrefix("SCAN_ITEM:") {
                let jsonString = String(message.dropFirst("SCAN_ITEM:".count))
                struct ScanPayload: Codable {
                    let piece: PieceModel
                    let weight: Int
                }
                if let jsonData = jsonString.data(using: .utf8),
                   let payload = try? JSONDecoder().decode(ScanPayload.self, from: jsonData) {
                    let revealed = RevealedPiece(piece: payload.piece, weight: payload.weight)
                    self.onScannedItemReceived?(revealed, payload.weight)
                }
            } else if message.hasPrefix("SNAPSHOT:") {
                let json = String(message.dropFirst("SNAPSHOT:".count))
                if !self.gameInProgress { self.lockInPlayers() }
                self.onSnapshotReceived?(Data(json.utf8))
            } else if message.hasPrefix("PLAYER_SYNC:") {
                let jsonString = String(message.dropFirst("PLAYER_SYNC:".count))
                if let jsonData = jsonString.data(using: .utf8),
                   let payload = try? JSONDecoder().decode(PlayerSyncPayload.self, from: jsonData) {
                    self.onPlayerSyncReceived?(peerID.displayName, payload) // Kirim juga displayName si pengirim
                }
            }        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NetworkSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            let isReturningPlayer = self.knownPeers.contains(peerID.displayName)
            let hasRoom = self.session.connectedPeers.count < self.maxOtherPlayers
            // Setelah game mulai, hanya pemain yang sama yang boleh masuk lagi
            let accept = self.gameInProgress ? isReturningPlayer : hasRoom
            invitationHandler(accept, self.session)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertiser error: \(error.localizedDescription)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NetworkSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            // Tie-breaking: hanya satu sisi yang mengundang
            guard self.myPeerID.displayName > peerID.displayName else { return }
            guard !self.session.connectedPeers.contains(peerID) else { return }
            
            let allowed = self.gameInProgress
            ? self.knownPeers.contains(peerID.displayName)
            : self.session.connectedPeers.count < self.maxOtherPlayers
            guard allowed else { return }
            
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browser error: \(error.localizedDescription)")
    }
}
