import SwiftUI
import FirebaseCore

@main
struct MyApp: App {
    @State private var gameSessionVM = GameSessionViewModel()

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootAppFlowView(gameSessionVM: gameSessionVM)
                .preferredColorScheme(.light)
        }
    }
}

private struct RootAppFlowView: View {
    @Environment(\.accessibilityReduceMotion) private var isReduceMotionEnabled
    @Bindable var gameSessionVM: GameSessionViewModel

    private var stageKey: String {
        "\(gameSessionVM.isGameStarted)|\(gameSessionVM.hasProceededToGame)|\(gameSessionVM.hasSeenStoryboard)"
    }

    var body: some View {
        ZStack {
            if !gameSessionVM.isGameStarted {
                // 1. LOBBY (STARTVIEW)
                StartView(viewModel: gameSessionVM)
                    .transition(.opacity)
                    .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            } else if !gameSessionVM.hasProceededToGame {
                // 2. REVEAL AIRLINE CARD (FLIP / DISSOLVE)
                AirlineCardView(airlineCard: gameSessionVM.displayedAirlineCard) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        gameSessionVM.hasProceededToGame = true
                    }
                }
                .transition(.opacity)
            } else if !gameSessionVM.hasSeenStoryboard {
                // 3. STORYBOARD CUTSCENE
                StoryboardView(session: gameSessionVM) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        gameSessionVM.hasSeenStoryboard = true
                    }
                }
                .transition(.opacity)
            } else {
                // 4. MAIN GAMEPLAY
                MainTabView(viewModel: gameSessionVM)
                    .transition(.opacity)
            }
        }
        .animation(isReduceMotionEnabled ? .easeInOut(duration: 0.25) : .easeInOut(duration: 0.2), value: stageKey)
    }
}
