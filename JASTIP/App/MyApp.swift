import SwiftUI

@main
struct MyApp: App {
    @State private var gameSessionVM = GameSessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if gameSessionVM.isGameStarted {
                    // Cukup panggil GameView dan oper airlineCard dari gameSessionVM yang sudah ada
                    GameView(airlineCard: gameSessionVM.airlineCard)
                } else {
                    StartView(viewModel: gameSessionVM)
                }
            }
        }
    }
}
