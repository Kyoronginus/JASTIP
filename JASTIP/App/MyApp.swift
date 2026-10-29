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
            Group {
                if !gameSessionVM.isGameStarted {
                    // 1. LOBBY (STARTVIEW)
                    StartView(viewModel: gameSessionVM)
                        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                } else if !gameSessionVM.hasProceededToGame {
                    // 2. REVEAL AIRLINE CARD (FLIP ANIMATION)
                    AirlineCardView(airlineCard: gameSessionVM.displayedAirlineCard) {
                        withAnimation {
                            gameSessionVM.hasProceededToGame = true
                        }
                    }
                } else {
                    // 3. MAIN GAMEPLAY
                    GameView(viewModel: gameSessionVM)
                }
            }
            
        }
    }
}
