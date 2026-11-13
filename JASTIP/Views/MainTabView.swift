//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    @Bindable var viewModel: GameSessionViewModel
    
    // State Drawer Phone
    @State private var isObjectiveExpanded: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var turnBanner: TurnBannerPresentation?
    @State private var hasPendingTurnBanner = false
    private let drawerFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // ==========================================
    // ⚙️ PENGATURAN UKURAN & POSISI HP (RESIZE & REPOSITION)
    // ==========================================
    private let phoneWidth: CGFloat = UIScreen.main.bounds.width - 50
    private let phoneHeight: CGFloat = UIScreen.main.bounds.height * 0.95
    private let peekHeight: CGFloat = 120 // Tinggi bagian atas HP yang ngintip dari bawah
    private let phoneScale: CGFloat = 0.85
    
    var body: some View {
        // ZStack alignment .bottom otomatis membuat SEMUA elemen 100% CENTER secara horizontal
        ZStack(alignment: .bottom) {
            
            // 1. LAYER GAMEPLAY UTAMA (KOPER & MEJA) - Kembali Normal & Center
            GameView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 2. DIMMING BACKDROP (Hanya muncul saat HP terbuka)
            if isObjectiveExpanded {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isObjectiveExpanded = false
                        }
                    }
            }
            
            // 3. DRAWER HP KARTUN (Swipe-Up / Tap-to-Expand)
            VStack(spacing: 8) {
                ObjectivePhoneContainer(
                    viewModel: viewModel,
                    isExpanded: $isObjectiveExpanded,
                    onBack: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isObjectiveExpanded = false
                        }
                    }
                )
                .frame(width: phoneWidth, height: phoneHeight)
                .overlay(alignment: .top) {
                    if !isObjectiveExpanded {
                        Text("Tap to expand")
                            .font(.plusJakarta(13, .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isObjectiveExpanded = true
                                }
                            }
                            .offset(y: -32)
                    }
                }
//                .border(.red) // buat liat containernya doang
                .scaleEffect(phoneScale, anchor: .bottom)
            }
            // Rumus posisi: saat collapsed turun sebanyak (phoneHeight - peekHeight)
            .offset(
                y: (isObjectiveExpanded
                    ? 15
                    : (phoneHeight * phoneScale - peekHeight)) + dragOffset
            )
            // Gesture Drag / Swipe yang responsif
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if isObjectiveExpanded {
                            // Saat terbuka: hanya bisa ditarik ke bawah (menutup)
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        } else {
                            // Saat ngintip: hanya bisa ditarik ke atas (membuka)
                            if value.translation.height < 0 {
                                dragOffset = value.translation.height
                            }
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 60
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if isObjectiveExpanded {
                                if value.translation.height > threshold {
                                    isObjectiveExpanded = false
                                }
                            } else {
                                if -value.translation.height > threshold {
                                    isObjectiveExpanded = true
                                }
                            }
                            dragOffset = 0
                        }
                    }
            )
            
            // 4. END OF ROUND & RESTOCK TRANSITION OVERLAY
            if viewModel.roundAnimationPhase != .none {
                RoundTransitionOverlayView(
                    phase: viewModel.roundAnimationPhase,
                    onCalendarTearFinished: {
                        viewModel.advanceToRestockAnimation()
                    },
                    onContinueTapped: {
                        withAnimation {
                            viewModel.dismissRoundAnimation()
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(90)
            }
            
            // 5. EVENT ALERT POPUP & NOTIFIKASI BAWAAN (Muncul setelah animasi End of Round / Restock selesai)
            if let event = viewModel.currentEvent, !viewModel.isGameOver, viewModel.roundAnimationPhase == .none {
                EventAlertView(event: event) {
                    withAnimation {
                        viewModel.dismissEvent()
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }

            if let turnBanner {
                TurnChangeBanner(playerName: turnBanner.playerName)
                    .id(turnBanner.id)
                    .frame(height: 240)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
                    .zIndex(110)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: turnBannerTrigger) { _, _ in
            guard viewModel.isGameStarted, !viewModel.isGameOver else { return }
            hasPendingTurnBanner = true
            presentTurnBannerIfReady()
        }
        .onChange(of: viewModel.roundAnimationPhase) { _, _ in
            presentTurnBannerIfReady()
        }
        .onChange(of: viewModel.currentEvent) { _, _ in
            presentTurnBannerIfReady()
        }
        .onChange(of: viewModel.roundAnimationPhase) { _, newPhase in
            if newPhase != .none && isObjectiveExpanded {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isObjectiveExpanded = false
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toastNotification($viewModel.activeToast)
        .fullScreenCover(isPresented: $viewModel.isGameOver) {
            ScoringView(viewModel: viewModel) {
                viewModel.resetToLobby()
            }
        }
        .onChange(of: isObjectiveExpanded) { _, _ in
            drawerFeedback.impactOccurred()
        }
        .task(id: turnBanner?.id) {
            guard turnBanner != nil else { return }
            do {
                try await Task.sleep(nanoseconds: 1_800_000_000)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                turnBanner = nil
            }
        }
    }

    private func presentTurnBannerIfReady() {
        guard hasPendingTurnBanner,
              viewModel.isGameStarted,
              !viewModel.isGameOver,
              viewModel.roundAnimationPhase == .none,
              viewModel.currentEvent == nil,
              let player = viewModel.currentTurnPlayer else { return }

        hasPendingTurnBanner = false
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
            turnBanner = TurnBannerPresentation(playerName: player.name)
        }
    }

    private var turnBannerTrigger: String {
        "\(viewModel.currentTurnPlayer?.id ?? "none")|\(viewModel.currentTurnIndex)|\(viewModel.currentHour)|\(viewModel.daysToGo)"
    }

    private struct TurnBannerPresentation: Identifiable {
        let id = UUID()
        let playerName: String
    }

    private struct TurnChangeBanner: View {
        let playerName: String

        var body: some View {
            GeometryReader { geometry in
                let bannerWidth = geometry.size.width + 80
                let bannerHeight = bannerWidth * 0.297

                ZStack {
                    Image("turnback")
                        .resizable()
                        .frame(width: bannerWidth, height: bannerHeight)

                    Text("\(playerName)'s Turn!")
                        .font(.shantellSans(36, .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .padding(.horizontal, 24)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .rotationEffect(.degrees(-11))
            }
        }
    }
}

// MARK: - Container Phone Frame
struct ObjectivePhoneContainer: View {
    var viewModel: GameSessionViewModel
    @Binding var isExpanded: Bool
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Background dasar
            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(Color(red: 247/255, green: 244/255, blue: 235/255))
                .padding(7)
            
            // Konten ObjectiveView di dalam layar HP
            VStack(spacing: 0) {
                // Jarak atas agar konten tidak nabrak Dynamic Island frame
                Color.clear
                    .frame(height: 50)
                
                ObjectiveView(viewModel: viewModel)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .offset(y:20)
            }
            .contentShape(Rectangle())
            // Tap di kepala HP saat ngintip untuk membuka
            .onTapGesture {
                if !isExpanded {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
            }
            
            // Asset Frame HP Kartun di lapisan terdepan
            Image("PhoneFrame")
                .resizable()
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    MainTabView(viewModel: GameSessionViewModel())
}
