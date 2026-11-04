//
//  InputRoomCodeCard.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

//
//  InputRoomCodeCard.swift
//  JASTIP
//

import SwiftUI

struct InputRoomCodeCard: View {
    @Binding var code: String
    var codeLength: Int = 4
    var onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    private var isCodeComplete: Bool {
        code.count == codeLength
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Input Room Code")
                .font(.plusJakarta(15, .bold))
                .foregroundStyle(Color("TaxiYellow"))

            // FlipTile Row with Tap-to-Focus
            ZStack {
                // Invisible input capturing keystrokes
                TextField("", text: $code)
                    .focused($isFocused)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .opacity(0.01)
                    .frame(width: 1, height: 1)
                    .onChange(of: code) { _, newValue in
                        let alphabet = Set("ABCDEFGHJKLMNPQRSTUVWXYZ")
                        let filtered = newValue.uppercased().filter { alphabet.contains($0) }
                        code = String(filtered.prefix(codeLength))
                    }

                HStack(spacing: 6) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        let char: Character = index < code.count
                            ? code[code.index(code.startIndex, offsetBy: index)]
                            : " "
                        let isCurrentTile = (index == code.count) && isFocused

                        ZStack {
                            FlipTile(
                                character: char,
                                width: 36,
                                height: 52,
                                fontSize: 30
                            )

                            if isCurrentTile {
                                Text("|")
                                    .font(.spaceGrotesk(26, .bold))
                                    .foregroundStyle(Color("TaxiYellow"))
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }

            // Submit Button inside the card
            Button(isCodeComplete ? "Enter Room" : "Start Game") {
                onSubmit()
            }
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .disabled(!isCodeComplete)
        }
        .padding(20)
        .background(
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("TileDivider"))

                Image("AsteriskYellow")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.white.opacity(0.06))
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: 24, y: 35)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    InputRoomCodeCard(code: .constant("DAWG")) {}
        .padding()
}
