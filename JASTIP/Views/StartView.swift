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
                
                NavigationLink(destination: GameView()) {
                    Text("START")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Spacer()
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    StartView()
}

