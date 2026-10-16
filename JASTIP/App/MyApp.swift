import SwiftUI

@main
struct MyApp: App {
    @State private var gameSessionVM = GameSessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if gameSessionVM.isGameStarted {
                    GameView(viewModel: gameSessionVM, lockHostToggle: gameSessionVM.lockHostToggle)
                } else {
                    StartView(viewModel: gameSessionVM, lockHostToggle: gameSessionVM.lockHostToggle)
                        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                }
            }
        }
    }
}
