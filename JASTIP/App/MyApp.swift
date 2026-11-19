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
            if gameSessionVM.isGameStarted && !gameSessionVM.hasSeenStoryboard {
                Color("BackgroundChat")
                    .ignoresSafeArea()
            }

            if !gameSessionVM.isGameStarted {
                // 1. LOBBY (STARTVIEW)
                StartView(viewModel: gameSessionVM)
                    .transition(.opacity)
                    .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            } else if !gameSessionVM.hasProceededToGame {
                // 2. AIRLINE CARD (CHAT ALLOWANCE) -> FADES CONTENT TO BACKGROUND BEFORE VIDEO
                AirlineCardView(airlineCard: gameSessionVM.displayedAirlineCard) {
                    gameSessionVM.hasProceededToGame = true
                }
                .transition(.identity)
            } else if !gameSessionVM.hasSeenStoryboard {
                // 3. INTRO VIDEO CUTSCENE (ON MATCHING BACKGROUND)
                StoryboardView(session: gameSessionVM) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        gameSessionVM.hasSeenStoryboard = true
                    }
                }
                .transition(.identity)
            } else {
                // 4. MAIN GAMEPLAY
                MainTabView(viewModel: gameSessionVM)
                    .transition(.opacity)
            }
        }
        .animation(isReduceMotionEnabled ? .easeInOut(duration: 0.25) : .easeInOut(duration: 0.2), value: stageKey)
    }
}
