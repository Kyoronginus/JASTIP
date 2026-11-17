//
//  ObjectiveView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI
import AudioToolbox

struct ObjectiveView: View {
    private enum MessageSound {
        static let received: SystemSoundID = 1003
        static let sent: SystemSoundID = 1004
    }

    @Environment(\.dismiss) private var dismiss

    // Terima viewModel dari MainTabView
    @Bindable var viewModel: GameSessionViewModel
    
    // 3 Order awal (Shared) membaca data yang sudah tersinkronisasi dari Firebase/ViewModel
    private var sharedOrders: [JastipOrderModel] {
        viewModel.sharedJastipOrders
    }
    
    @State private var isConfirmingAddOrder: Bool = false
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let successFeedback = UINotificationFeedbackGenerator()

    private var actionBarPrompt: String {
//        viewModel.isMyTurn ? "anyone else need anything?" : "Wait for your turn"
        if !viewModel.isMyTurn { return "Wait for your turn" }
        if viewModel.remainingTurnActionQuota <= 0 { return "You're too exhausted to move" }
        return "anyone else need anything?"
    }
    
    // MARK: - Helper Formatting Teks Input Bar
    private var confirmationTemplateText: String {
        let selectedNames = viewModel.candidateOrders
            .filter { viewModel.selectedOrderIds.contains($0.id) }
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
            ZStack() {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: .white,
                        foregroundColor: Color(.black),
                        cornerRadius: 14,
                        paddingVertical: 14,
                        paddingHorizontal: 15
                    ))

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, -10)

                VStack(spacing: 0) {
                    Text("Jastip Order")
                        .font(.spaceGrotesk(33.4, .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                    Image("HeaderLine")
                }
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
                        ForEach(viewModel.personalDraftHistory) { round in
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
                        if viewModel.isDraftingObjective {
                            playerChatBubble(text: "Does anyone want to jastip other things too?")
                                .id("activePlayerRequest")
                            
                            // 3 Kandidat masuk berturut-turut
                            ForEach(viewModel.visibleCandidateOrders) { order in
                                JastipChatBubble(
                                    order: order,
                                    isSelectable: true,
                                    isSelected: viewModel.selectedOrderIds.contains(order.id),
                                    onToggleSelect: {
                                        selectionFeedback.selectionChanged()
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if viewModel.selectedOrderIds.contains(order.id) {
                                                viewModel.selectedOrderIds.remove(order.id)
                                            } else {
                                                viewModel.selectedOrderIds.insert(order.id)
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
                .onChange(of: viewModel.isDraftingObjective) { _, isStarting in
                    if isStarting {
                        scrollToBottom(proxy: proxy)
                    }
                }
                // 3. Scroll setiap kali KARTU BARU MUNCUL satu per satu
                .onChange(of: viewModel.visibleCandidateOrders.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                // 4. Scroll setiap kali SESI DRAFT DI-ACCEPT (pesan konfirmasi muncul)
                .onChange(of: viewModel.personalDraftHistory.count) { _, _ in
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
            if !viewModel.isDraftingObjective {
                // TAMPILAN NORMAL (SELALU KEMBALI KE SINI SETELAH DRAFT SELESAI)
                ZStack{
                    Image("tfback")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                    HStack{
                        Spacer()
                            .frame(width: 10)
                        Text(actionBarPrompt)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextActive"))
                        Spacer()
                    }
                }
                
                .padding(.vertical, 10)
                Button {
                    if !isConfirmingAddOrder {
                        // Tap 1: Masuk mode konfirmasi
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isConfirmingAddOrder = true
                        }
                        
                        // Auto-cancel setelah 4 detik jika tidak dikonfirmasi
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isConfirmingAddOrder = false
                            }
                        }
                    } else {
                        // Tap 2: Pemain yakin -> eksekusi!
                        isConfirmingAddOrder = false
                        startDraftingFlow()
                    }
                } label: {
                    ZStack{
                        if !viewModel.isMyTurn || !viewModel.canUseTurnAction{
                            Image("addorderbackdisabled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                            
                        } else if isConfirmingAddOrder {
                            Image("addordergreen")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                        } else  {
                            Image("addorderback")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                        }
                        Text(isConfirmingAddOrder ? "Confirm" : "Add Order")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .disabled(!viewModel.canUseTurnAction || !viewModel.isMyTurn)
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
                            .foregroundColor(viewModel.selectedOrderIds.isEmpty ? Color("TextDisabled") : Color("TextActive"))
                        Spacer()
                    }
                }
                .padding(.vertical, 10)
                
                // Tombol Send / Accept Message
                Button {
                    confirmSelectedDraftOrders()
                } label: {
                    ZStack{
                        if (viewModel.selectedOrderIds.isEmpty){
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
                .disabled(viewModel.selectedOrderIds.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.backgroundReply))
    }
    
    // MARK: - Flow Logics
    
    /// Memulai alur request chat & memunculkan 3 kandidat dengan jeda 0.5s
    private func startDraftingFlow() {
        AudioServicesPlaySystemSound(MessageSound.sent)
        withAnimation {
            viewModel.isDraftingObjective = true
            viewModel.selectedOrderIds.removeAll()
            viewModel.visibleCandidateOrders.removeAll()
        }
        
        viewModel.consumeTurnActionQuota()

        let playerName = viewModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.showToast(
            "\(playerName.isEmpty ? "A player" : playerName) just took a new personal order!",
            type: .info,
            displayLocally: false,
            playNotificationSound: true
        )
        
        // Kumpulkan semua ID yang sudah pernah ada di shared atau di accepted history
        var existingIds = Set(sharedOrders.map { $0.id })
        for round in viewModel.personalDraftHistory {
            for order in round.acceptedOrders {
                existingIds.insert(order.id)
            }
        }
        
        // 👇 GANTI BAGIAN INI:
        let rawCandidates = JastipOrderCatalog.getDraftOrders(count: 3, excludingIds: existingIds)
        viewModel.candidateOrders = rawCandidates.map {
            var order = $0
            order.isPersonal = true
            return order
        }
        // 👆 SAMPAI SINI
        
        // 1. Tentukan jeda tunggu setelah chat player terkirim (misal 1.0 detik)
        let initialPause: Double = 1.0
        
        // 2. Tiap kartu muncul dengan jeda initialPause + 0.5 detik antar kartu
        for index in 0..<viewModel.candidateOrders.count {
            let delay = initialPause + (0.5 * Double(index))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if self.viewModel.isDraftingObjective {
                        guard index < self.viewModel.candidateOrders.count else { return }

                        self.viewModel.visibleCandidateOrders.append(self.viewModel.candidateOrders[index])
                        AudioServicesPlaySystemSound(MessageSound.received)
                    }
                }
            }
        }
    }
    
    /// Mengonfirmasi order yacloudng dipilih, simpan ke histori, dan reset input bar
    private func confirmSelectedDraftOrders() {
        let templateMessage = confirmationTemplateText
        AudioServicesPlaySystemSound(MessageSound.sent)
        successFeedback.notificationOccurred(.success)
        
        // Ambil order yang dicentang & tandai sebagai Personal
        let selected = viewModel.candidateOrders.filter { viewModel.selectedOrderIds.contains($0.id) }
        let personalOrders = selected.map {
            var order = $0
            order.isPersonal = true
            return order
        }
        
        
        withAnimation(.easeInOut(duration: 0.3)) {
            // 1. Simpan ke histori chat
            viewModel.personalDraftHistory.append(DraftRoundHistory(
                acceptedOrders: personalOrders,
                confirmationMessage: templateMessage
            ))
            
            // 2. Reset state drafting -> Input bar otomatis kembali ke tombol "Request more order"
            viewModel.isDraftingObjective = false
            viewModel.candidateOrders.removeAll()
            viewModel.visibleCandidateOrders.removeAll()
            viewModel.selectedOrderIds.removeAll()
        }
        
        viewModel.personalJastipOrders.append(contentsOf: personalOrders)
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
            
            // 1. Ambil status centang per slot item dari kepingan yang ada di koper
            let itemStatuses = JastipOrderCatalog.checkItemFulfillment(
                orderKey: order.orderKey,
                items: viewModel.allLuggagePieces
            )
            
            // 2. Set isFulfilled untuk masing-masing slot kartu secara independen
            for index in updated.requirementItems.indices {
                if index < itemStatuses.count {
                    updated.requirementItems[index].isFulfilled = itemStatuses[index]
                }
            }
            
            // 3. Status order selesai jika semua slot item sudah tercentang
            updated.isCompleted = viewModel.isOrderFulfilled(order)
            
            return updated
        }}

#Preview {
    ObjectiveView(viewModel: GameSessionViewModel())
}

//#Preview {
//    MainTabView(viewModel: GameSessionViewModel())
//}
