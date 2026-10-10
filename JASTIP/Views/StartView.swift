import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Text("JASTIP!")
                    .padding()
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                
                Spacer()
                
                NavigationLink("START", destination: GameView())
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

