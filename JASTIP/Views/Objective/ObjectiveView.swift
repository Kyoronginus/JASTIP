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
    // Terima viewModel dari MainTabView
    var viewModel: GameSessionViewModel
    
    // 3 Order awal (Shared) membaca data yang sudah tersinkronisasi dari Firebase/ViewModel
    private var sharedOrders: [JastipOrderModel] {
        viewModel.sharedJastipOrders
    }
    
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
            // 1. Header Bar
            VStack(spacing: 0){
                Text("Jastip Order")
                    .font(.spaceGrotesk(33.4, .bold))
                
                Image("HeaderLine")
            }
            
            // 2. Scrollable Chat Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        
                        // A. 3 SHARED JASTIP ORDERS AWAL
                        ForEach(sharedOrders) { order in
                           JastipChatBubble(order: validatedOrder(order))
                       }
                        
                        // B. HISTORI SESI-SESI DRAFT YANG SUDAH SELESAI SEBELUMNYA
                        ForEach(draftHistory) { round in
                            // Chat nanya
                            playerChatBubble(text: "Does anyone want to jastip other things too?")
                            
                            // Kartu-kartu yang di-accept di sesi itu
                            ForEach(round.acceptedOrders) { order in
                               JastipChatBubble(order: validatedOrder(order))
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
                        Color.clear
                            .frame(height: 1)
                            .id("CHAT_BOTTOM")
                    }
                    .padding(.vertical, 8)
                }
                // 1. Scroll saat pertama kali layar dibuka
                .onAppear {
                    scrollToBottom(proxy: proxy, animated: false)
                }
                // 2. Scroll setiap kali draft dimulai (chat player muncul)
                .onChange(of: isDrafting) { _, isStarting in
                    if isStarting {
                        scrollToBottom(proxy: proxy)
                    }
                }
                // 3. Scroll setiap kali KARTU BARU MUNCUL satu per satu
                .onChange(of: visibleCandidateOrders.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                // 4. Scroll setiap kali SESI DRAFT DI-ACCEPT (pesan konfirmasi muncul)
                .onChange(of: draftHistory.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }            }
            
            // 3. Dynamic Bottom Action Bar
            bottomActionBar
        }
        .background(Color("BackgroundChat"))
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
                ZStack{
                    Image("tfback")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                    HStack{
                        Spacer()
                            .frame(width: 10)
                        Text("anyone else need anything?")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextActive"))
                        Spacer()
                    }
                }
                
                .padding(.vertical, 10)
                Button {
                    startDraftingFlow()
                } label: {
                    ZStack{
                        Image("addorderback")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                        Text("Add Order")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
            } else {
                // TAMPILAN MODE DRAFTING (Saat memilih kartu)
                ZStack{
                    Image("tfback")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                    HStack{
                        Spacer()
                            .frame(width: 10)
                        Text(confirmationTemplateText)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(selectedOrderIds.isEmpty ? Color("TextDisabled") : Color("TextActive"))
                        Spacer()
                    }
                }
                .padding(.vertical, 10)
                
                // Tombol Send / Accept Message
                Button {
                    confirmSelectedDraftOrders()
                } label: {
                    ZStack{
                        if (selectedOrderIds.isEmpty){
                            Image("addorderbackdisabled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                        }
                        else{
                            Image("addorderback")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                        }
                        Text("Accept")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .disabled(selectedOrderIds.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.backgroundReply))
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
    
    /// Mengonfirmasi order yacloudng dipilih, simpan ke histori, dan reset input bar
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
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo("CHAT_BOTTOM", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("CHAT_BOTTOM", anchor: .bottom)
        }
    }
    
    /// Update status isFulfilled pada item order sesuai kondisi koper saat ini
    private func validatedOrder(_ order: JastipOrderModel) -> JastipOrderModel {
        var updated = order
        let completed = viewModel.isOrderFulfilled(order)
        
        // Tandai slot item-nya sebagai fulfilled jika order sudah terpenuhi
        for index in updated.requirementItems.indices {
            updated.requirementItems[index].isFulfilled = completed
        }
        return updated
    }
}

#Preview {
    ObjectiveView(viewModel: GameSessionViewModel())
}

#Preview {
    ObjectiveView(viewModel: GameSessionViewModel())
}

//#Preview {
//    MainTabView(viewModel: GameSessionViewModel())
//}
