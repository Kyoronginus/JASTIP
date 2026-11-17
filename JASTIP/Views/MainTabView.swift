//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    @Bindable var viewModel: GameSessionViewModel
    
    // State Objective Sheet
    @State private var isObjectivePresented = false
    @State private var turnBanner: TurnBannerPresentation?
    @State private var hasPendingTurnBanner = false
    
    var body: some View {
        // ZStack alignment .bottom otomatis membuat SEMUA elemen 100% CENTER secara horizontal
        ZStack(alignment: .bottom) {
            
            // 1. LAYER GAMEPLAY UTAMA (KOPER & MEJA) - Kembali Normal & Center
            GameView(
                viewModel: viewModel,
                onOpenObjective: {
                    isObjectivePresented = true
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toastNotification($viewModel.activeToast)
        .sheet(isPresented: $isObjectivePresented) {
            GeometryReader { geometry in
                ObjectivePhoneContainer(viewModel: viewModel)
                    .frame(
                        width: min(geometry.size.width - 24, 420),
                        height: min(geometry.size.height, UIScreen.main.bounds.height * 0.9)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.black.opacity(0.35))
        }
        .onChange(of: viewModel.isGameOver) { _, isGameOver in
            guard isGameOver else { return }

            viewModel.isScoreSubmitted = true
            viewModel.broadcastMyStatus()
            viewModel.captureFinalStandingsIfReady()
        }
        .fullScreenCover(isPresented: $viewModel.isGameOver) {
            FinalScoreView(
                viewModel: viewModel,
                onBackToHome: {
                    viewModel.resetToLobby()
                }
            )
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
