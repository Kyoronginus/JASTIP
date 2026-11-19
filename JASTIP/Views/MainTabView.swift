//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.accessibilityReduceMotion) private var isReduceMotionEnabled
    @Bindable var viewModel: GameSessionViewModel
    
    // State Objective child page
    @State private var isObjectivePresented = false
    @State private var turnBanner: TurnBannerPresentation?
    @State private var hasPendingTurnBanner = false
    @State private var eventCardTargetFrame: CGRect = .zero
    @State private var isInspectingActiveEvent = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                GameView(
                    viewModel: viewModel,
                    onOpenObjective: {
                        if isReduceMotionEnabled {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isObjectivePresented = true
                            }
                        } else {
                            isObjectivePresented = true
                        }
                    },
                    isInspectingActiveEvent: isInspectingActiveEvent,
                    onEventCardTargetFrameChange: { newFrame in
                        if newFrame != .zero {
                            eventCardTargetFrame = newFrame
                        }
                    },
                    onTapActiveEvent: {
                        isInspectingActiveEvent = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationDestination(isPresented: Binding(
                    get: { !isReduceMotionEnabled && isObjectivePresented },
                    set: { isObjectivePresented = $0 }
                )) {
                    ObjectiveView(viewModel: viewModel)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                }
            }

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

            if let event = viewModel.currentEvent,
               !viewModel.isGameOver,
               viewModel.roundAnimationPhase == .none {
                EventAlertView(
                    event: event,
                    targetFrame: eventCardTargetFrame
                ) {
                    viewModel.dismissEvent()
                }
                .zIndex(100)
            } else if isInspectingActiveEvent,
                let activeEvent = viewModel.activeHourEvent,
                !viewModel.isGameOver,
                viewModel.roundAnimationPhase == .none {
            EventAlertView(
                event: activeEvent,
                targetFrame: eventCardTargetFrame,
                startsFromTarget: true
            ) {
                isInspectingActiveEvent = false
            }
            .zIndex(100)
        }

            if let turnBanner {
                TurnChangeBanner(playerName: turnBanner.playerName)
                    .id(turnBanner.id)
                    .frame(height: 240)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .transition(
                        isReduceMotionEnabled
                            ? .opacity
                            : .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                    )
                    .zIndex(110)
                    .allowsHitTesting(false)
            }

            if isReduceMotionEnabled && isObjectivePresented {
                ObjectiveView(
                    viewModel: viewModel,
                    onDismissOverride: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isObjectivePresented = false
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(120)
            }

            if isReduceMotionEnabled && viewModel.isGameOver {
                FinalScoreView(
                    viewModel: viewModel,
                    onBackToHome: {
                        viewModel.resetToLobby()
                    }
                )
                .transition(.opacity)
                .zIndex(200)
            }
        }
        .animation(isReduceMotionEnabled ? .easeInOut(duration: 0.25) : nil, value: isObjectivePresented)
        .animation(isReduceMotionEnabled ? .easeInOut(duration: 0.25) : nil, value: viewModel.isGameOver)
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
        .onChange(of: viewModel.isGameOver) { _, isGameOver in
            guard isGameOver else { return }

            viewModel.isScoreSubmitted = true
            viewModel.broadcastMyStatus()
            viewModel.captureFinalStandingsIfReady()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !isReduceMotionEnabled && viewModel.isGameOver },
            set: { viewModel.isGameOver = $0 }
        )) {
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
            withAnimation(isReduceMotionEnabled ? .easeInOut(duration: 0.25) : .spring(response: 0.5, dampingFraction: 0.85)) {
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
        withAnimation(isReduceMotionEnabled ? .easeInOut(duration: 0.25) : .spring(response: 0.55, dampingFraction: 0.78)) {
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

#Preview {
    MainTabView(viewModel: GameSessionViewModel())
}
