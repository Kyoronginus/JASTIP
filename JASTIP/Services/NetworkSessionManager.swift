//
//  NetworkSessionManager.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 14/10/26.
//

import Foundation
import Network
import Combine
import UIKit
import Observation

@Observable
class NetworkSessionManager {
    // Bonjour Service Type
    private let serviceType = "_jastip-game._tcp"
    
    private var listener: NWListener?
    private var browser: NWBrowser?
    
    // Nyimpen daftar connection yg aktif dgn peer lain
    var activeConnections: [NWConnection] = []
    var connectedPeersCount: Int = 0
    
    // Callback ketika nerima pesan "START_GAME"
    var onStartGameReceived: (() -> Void)?
    
    init() {
        startAdvertising()
        startBrowsing()
    }
    
    // MARK: - 1. Advertising (Membuka Listener agar device lain bisa nemu device ini)
    func startAdvertising() {
        do {
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true
            
            listener = try NWListener(using: parameters)
            listener?.service = NWListener.Service(name:UIDevice.current.name, type: serviceType)
            listener?.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print("🟢 NetworkListener ready: \(UIDevice.current.name)")
                case .failed(let error):
                    print("🔴 Listener failed: \(error)")
                default:
                    break
                }
            }
            
            // Handle connection yg masuk dari device lain
            listener?.newConnectionHandler = { [weak self] newConnection in self?.setupConnection(newConnection)
            }
            
            listener?.start(queue: .main)
        } catch {
            print("Failed to create listener: \(error)")
        }
    }
    
    // MARK: - 2. Browsing (Mencari device lain yg membuka app)
    func startBrowsing() {
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        
        let browserDescriptor = NWBrowser.Descriptor.bonjour(type: serviceType, domain: "local")
        browser = NWBrowser(for: browserDescriptor, using: parameters)
        
        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            for result in results {
                if case let .service(name, _, _, _) = result.endpoint {
                    // Avoid connection ke diri sendiri
                    if name != UIDevice.current.name {
                        let connection = NWConnection(to: result.endpoint, using: parameters)
                        self?.setupConnection(connection)
                    }
                }
            }
        }
        
        browser?.start(queue: .main)
    }
    
    // MARK: - 3. Setup & Receive Data
    private func setupConnection(_ connection: NWConnection) {
        // Cek apakah connection udah ada agar tidak duplikat
        guard !activeConnections.contains(where: { $0.endpoint == connection.endpoint }) else { return }
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
                case .ready:
                    print("Connected to: \(connection.endpoint)")
                    DispatchQueue.main.async {
                        if !(self?.activeConnections.contains(where: { $0.endpoint == connection.endpoint }) ?? false) {
                            self?.activeConnections.append(connection)
                            self?.connectedPeersCount = (self?.activeConnections.count ?? 0) + 1 // include self
                        }
                    }
                    self?.receiveData(on: connection)
                case .failed, .cancelled:
                    DispatchQueue.main.async {
                        self?.activeConnections.removeAll(where: { $0.endpoint == connection.endpoint })
                        self?.connectedPeersCount = max(1, (self?.activeConnections.count ?? 0) + 1)
                    }
                default:
                    break
            }
        }
        
        connection.start(queue: .main)
    }
    
    private func receiveData(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("Received message: \(message)")
                if message == "START_GAME" {
                    DispatchQueue.main.async {
                        self?.onStartGameReceived?()
                    }
                }
            }
            
            if isComplete {
                connection.cancel()
            } else if error == nil {
                // Keep listening data berikutnya secara berulang
                self?.receiveData(on: connection)
            }
        }
    }
    
    // MARK: - 4. Broadcast Message (Send "START_GAME")
    func sendStartGameTrigger() {
        let message = "START_GAME"
        guard let data = message.data(using: .utf8) else { return }
        
        for connection in activeConnections {
            connection.send(content: data, completion: .contentProcessed({ error in
                if let error = error {
                    print("Send error: \(error)")
                } else {
                    print("START_GAME sent to \(connection.endpoint)")
                }
            }))
        }
        // Local Trigger untuk device yg klik tombol start
        self.onStartGameReceived?()
    }
}
