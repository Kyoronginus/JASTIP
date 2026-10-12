import SwiftUI

struct StartView: View {
    @State private var gameSession = GameSessionViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Text("JASTIP!")
                    .padding()
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                
                Spacer()
                
                NavigationLink {
                    GameView(session: gameSession)
                        .onAppear {
                            gameSession.startNewGame()
                        }
                } label: {
                    Text("START")
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
        }
    }
}

#Preview("Light", traits: .landscapeRight) {
    StartView()
        .preferredColorScheme(.light)
}

#Preview("Dark", traits: .landscapeRight) {
    StartView()
        .preferredColorScheme(.dark)
}

