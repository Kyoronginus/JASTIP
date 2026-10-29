//
//  NFCReaderManager.swift
//  JASTIP
//
//  Created by Feivel Qutby on 21/10/26.
//

import Foundation
import CoreNFC

@Observable
class NFCReaderManager: NSObject, NFCNDEFReaderSessionDelegate {
    private var session: NFCNDEFReaderSession?
    var onTagScanned: ((String) -> Void)?
    var errorMessage: String?
    
    // Cek apakah device punya sensor NFC
    var isNFCAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }
    
    // Mulai sesi scan NFC
    func startScan() {
        guard isNFCAvailable else {
            errorMessage = "NFC tidak didukung di perangkat ini (atau sedang di Simulator)."
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Dekatkan iPhone ke stiker NFC barang belanjaan."
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                // Baca payload bertipe NDEF Text
                if let text = String(data: record.payload, encoding: .utf8) {
                    // CoreNFC payload text biasanya memiliki language code prefix (3 byte pertama), kita bersihkan:
                    let cleanText = text.count > 3 ? String(text.dropFirst(3)) : text
                    
                    DispatchQueue.main.async {
                        self.onTagScanned?(cleanText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    session.alertMessage = "Item Berhasil Terbaca! 🎉"
                    return
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("❌ NFC Session Invalidate / Error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.session = nil
        }
    }
}
