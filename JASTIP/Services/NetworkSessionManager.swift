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
    
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    // Status yang dipantau StartView
    var connectedPeersCount: Int = 1 // Termasuk device ini sendiri
    var connectedPeerNames: [String] = []
    
    // Callback ketika sinyal START_GAME diterima
    var onStartGameReceived: (() -> Void)?
    
    override init() {
        super.init()
        setupMultipeer()
    }
    
    private func setupMultipeer() {
        // 1. Setup Session
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        // 2. Setup Advertiser (Membuka diri agar bisa ditemukan HP lain)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        
        // 3. Setup Browser (Mencari HP lain yang sedang membuka app)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    // MARK: - Broadcast Start Game
    func sendStartGameTrigger() {
        let message = "START_GAME"
        guard let data = message.data(using: .utf8) else { return }
        
        if !session.connectedPeers.isEmpty {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
        
        // Trigger untuk device yang memencet tombol START
        DispatchQueue.main.async {
            self.onStartGameReceived?()
        }
    }
    
    deinit {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
    }
}

// MARK: - MCSessionDelegate
extension NetworkSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("🟢 Connected to \(peerID.displayName)")
            case .notConnected:
                print("🔴 Disconnected from \(peerID.displayName)")
            case .connecting:
                print("🟡 Connecting to \(peerID.displayName)")
            @unknown default:
                break
            }
            
            // Hitung akurat: jumlah teman terhubung + 1 (diri sendiri)
            self.connectedPeersCount = session.connectedPeers.count + 1
            self.connectedPeerNames = session.connectedPeers.map { $0.displayName }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8), message == "START_GAME" {
            DispatchQueue.main.async {
                self.onStartGameReceived?()
            }
        }
    }
    
    // Delegate methods wajib (kosongkan saja untuk kebutuhan message string)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NetworkSessionManager: MCNearbyServiceAdvertiserDelegate {
    // Menerima undangan join dari player lain
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Otomatis terima jika player belum mencapai maksimal 4 orang (3 teman + 1 diri sendiri)
        let shouldAccept = session.connectedPeers.count < 5
        invitationHandler(shouldAccept, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NetworkSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Tie-breaking: hanya kirim invite jika nama device kita lebih besar secara alfabet.
        // Ini mencegah HP A dan HP B saling kirim invite bersamaan (anti-double connection)
        if myPeerID.displayName > peerID.displayName && session.connectedPeers.count < 3 {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
}
