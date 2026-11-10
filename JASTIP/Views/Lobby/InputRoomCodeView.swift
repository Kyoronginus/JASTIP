//
//  InputRoomCodeView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

struct InputRoomCodeView: View {
    @Binding var code: String
    var codeLength: Int = 4
    var onBack: () -> Void = {}
    var onSubmit: () -> Void

    private var isCodeComplete: Bool {
        code.count == codeLength
    }

    var body: some View {
        // MARK: - View Layout
        VStack {
            // Top Bar: Back Button
            HStack {
                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            // Card Room Code di Tengah
            InputRoomCodeCard(code: $code, codeLength: codeLength)
                .padding(.horizontal, 24)

            Spacer()

            // Bottom Action Button: Join Game
            Button("Join Game") {
                onSubmit()
            }
            .buttonStyle(PrimaryButtonStyle(
                font: .shantellSans(20, .bold),
                isFullWidth: true
            ))
            .disabled(!isCodeComplete)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .lobbyBackground()
    }
}

#Preview("Empty State") {
    InputRoomCodeView(code: .constant(""), onBack: {}, onSubmit: {})
}

#Preview("Filled State") {
    InputRoomCodeView(code: .constant("DRPF"), onBack: {}, onSubmit: {})
}
