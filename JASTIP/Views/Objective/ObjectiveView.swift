//
//  ObjectiveView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

// Model pencatat riwayat per sesi draft yang berhasil
struct DraftRoundHistory: Identifiable {
    let id = UUID().uuidString
    let acceptedOrders: [JastipOrderModel]
    let confirmationMessage: String
}

struct ObjectiveView: View {
    // 3 Order awal (Shared)
    @State private var sharedOrders: [JastipOrderModel] = JastipOrderCatalog.getRandomSharedOrders(count: 3)
    
    // Riwayat draft yang sudah pernah diselesaikan (bisa berkali-kali)
    @State private var draftHistory: [DraftRoundHistory] = []
    
    // State Sesi Drafting yang Sedang Berjalan
    @State private var isDrafting: Bool = false
    @State private var candidateOrders: [JastipOrderModel] = []
    @State private var visibleCandidateOrders: [JastipOrderModel] = []
    @State private var selectedOrderIds: Set<String> = []
    
    // MARK: - Helper Formatting Teks Input Bar
    private var confirmationTemplateText: String {
        let selectedNames = candidateOrders
            .filter { selectedOrderIds.contains($0.id) }
            .map { $0.customerName }
        
        switch selectedNames.count {
        case 0:
            return "select an order..."
        case 1:
            return "okay, i'll take \(selectedNames[0])'s order"
        case 2:
            return "okay, i'll take \(selectedNames[0]) and \(selectedNames[1])'s order"
        case 3:
            return "okay, i'll take \(selectedNames[0]), \(selectedNames[1]), and \(selectedNames[2])'s order"
        default:
            return "okay, i'll take \(selectedNames.joined(separator: ", "))'s order"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Anchored Header Bar
            headerView
            
            // 2. Scrollable Chat Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        // Date Separator
                        Text("TODAY")
                            .font(.plusJakarta(11, .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(Capsule())
                            .padding(.vertical, 8)
                        
                        // A. 3 SHARED JASTIP ORDERS AWAL
                        ForEach(sharedOrders) { order in
                            JastipChatBubble(order: order)
                        }
                        
                        // B. HISTORI SESI-SESI DRAFT YANG SUDAH SELESAI SEBELUMNYA
                        ForEach(draftHistory) { round in
                            // Chat nanya
                            playerChatBubble(text: "Does anyone want to jastip other things too?")
                            
                            // Kartu-kartu yang di-accept di sesi itu
                            ForEach(round.acceptedOrders) { order in
                                JastipChatBubble(order: order)
                            }
                            
                            // Chat balasan konfirmasi
                            playerChatBubble(text: round.confirmationMessage)
                                .id(round.id)
                        }
                        
                        // C. SESI DRAFTING YANG SEDANG AKTIF
                        if isDrafting {
                            playerChatBubble(text: "Does anyone want to jastip other things too?")
                                .id("activePlayerRequest")
                            
                            // 3 Kandidat masuk berturut-turut
                            ForEach(visibleCandidateOrders) { order in
                                JastipChatBubble(
                                    order: order,
                                    isSelectable: true,
                                    isSelected: selectedOrderIds.contains(order.id),
                                    onToggleSelect: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if selectedOrderIds.contains(order.id) {
                                                selectedOrderIds.remove(order.id)
                                            } else {
                                                selectedOrderIds.insert(order.id)
                                            }
                                        }
                                    }
                                )
                                .id(order.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                // Tambahkan listener ini tepat di bawah .onChange(of: visibleCandidateOrders.count):
                .onChange(of: isDrafting) { _, newValue in
                    if newValue {
                        // Begitu tombol diklik, LANGSUNG scroll ke chat biru player di detik 0!
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("activePlayerRequest", anchor: .bottom)
                        }
                    }
                }
                // Auto scroll ke konfirmasi pesan terakhir
                .onChange(of: draftHistory.count) { _, _ in
                    if let lastRound = draftHistory.last {
                        withAnimation { proxy.scrollTo(lastRound.id, anchor: .bottom) }
                    }
                }
            }
            
            // 3. Dynamic Bottom Action Bar
            bottomActionBar
        }
        .appBackground()
    }
    
    // MARK: - Subview: Header Bar
    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Jastip Meepolis 🚩")
                    .font(.spaceGrotesk(16, .bold))
                    .foregroundStyle(.primary)
                
                Text("Thomas, Toyib, Quincy, Henry, Molly...")
                    .font(.plusJakarta(12, .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .overlay(Divider(), alignment: .bottom)
    }
    
    // MARK: - Subview: Bubble Chat Player (Biru di Kanan)
    private func playerChatBubble(text: String) -> some View {
        HStack {
            Spacer(minLength: 40)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(text)
                    .font(.plusJakarta(14, .medium))
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text("08:31")
                        .font(.plusJakarta(10, .regular))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Image(systemName: "checkmark.done")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    // MARK: - Subview: Bottom Action Bar
    private var bottomActionBar: some View {
        HStack(spacing: 10) {
            if !isDrafting {
                // TAMPILAN NORMAL (SELALU KEMBALI KE SINI SETELAH DRAFT SELESAI)
                HStack {
                    Text("any1 else need anything?")
                        .font(.plusJakarta(14, .regular))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .trailing) {
                    Button {
                        startDraftingFlow()
                    } label: {
                        Text("Request more order")
                            .font(.plusJakarta(12, .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.trailing, 6)
                }
            } else {
                // TAMPILAN MODE DRAFTING (Saat memilih kartu)
                HStack {
                    Text(confirmationTemplateText)
                        .font(.plusJakarta(13, .regular))
                        .foregroundColor(selectedOrderIds.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Tombol Send Message
                Button {
                    confirmSelectedDraftOrders()
                } label: {
                    Text("Send message")
                        .font(.plusJakarta(12, .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(selectedOrderIds.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(selectedOrderIds.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Flow Logics
    
    /// Memulai alur request chat & memunculkan 3 kandidat dengan jeda 0.5s
    private func startDraftingFlow() {
        withAnimation {
            isDrafting = true
            selectedOrderIds.removeAll()
            visibleCandidateOrders.removeAll()
        }
        
        // Kumpulkan semua ID yang sudah pernah ada di shared atau di accepted history
        var existingIds = Set(sharedOrders.map { $0.id })
        for round in draftHistory {
            for order in round.acceptedOrders {
                existingIds.insert(order.id)
            }
        }
        
        // Ambil 3 kartu baru yang belum pernah muncul sama sekali
        candidateOrders = JastipOrderCatalog.getDraftOrders(count: 3, excludingIds: existingIds)
        
        // 1. Tentukan jeda tunggu setelah chat player terkirim (misal 1.0 detik)
        let initialPause: Double = 1.0
        
        // 2. Tiap kartu muncul dengan jeda initialPause + 0.5 detik antar kartu
        for index in 0..<candidateOrders.count {
            let delay = initialPause + (0.5 * Double(index))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if self.isDrafting {
                        self.visibleCandidateOrders.append(self.candidateOrders[index])
                    }
                }
            }
        }
    }
    
    /// Mengonfirmasi order yang dipilih, simpan ke histori, dan reset input bar
    private func confirmSelectedDraftOrders() {
        let templateMessage = confirmationTemplateText
        
        // Ambil order yang dicentang & tandai sebagai Personal
        let selected = candidateOrders.filter { selectedOrderIds.contains($0.id) }
        let personalOrders = selected.map {
            var order = $0
            order.isPersonal = true
            return order
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            // 1. Simpan ke histori chat
            draftHistory.append(DraftRoundHistory(
                acceptedOrders: personalOrders,
                confirmationMessage: templateMessage
            ))
            
            // 2. Reset state drafting -> Input bar otomatis kembali ke tombol "Request more order"
            isDrafting = false
            candidateOrders.removeAll()
            visibleCandidateOrders.removeAll()
            selectedOrderIds.removeAll()
        }
    }
}

#Preview {
    ObjectiveView()
}
