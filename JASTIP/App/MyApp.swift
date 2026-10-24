import SwiftUI

@main
struct MyApp: App {
    @State private var gameSessionVM = GameSessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !gameSessionVM.isGameStarted {
                    // 1. LOBBY (STARTVIEW)
                    StartView(viewModel: gameSessionVM, lockHostToggle: gameSessionVM.lockHostToggle)
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
                    GameView(viewModel: gameSessionVM, lockHostToggle: gameSessionVM.lockHostToggle)
                }
            }
            
        }
    }
}
