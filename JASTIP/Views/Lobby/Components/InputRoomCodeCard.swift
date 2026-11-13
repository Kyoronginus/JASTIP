//
//  InputRoomCodeCard.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

struct InputRoomCodeCard: View {
    @Binding var code: String
    var codeLength: Int = 4

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Invisible TextField penangkap input keyboard
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

            // Background Asset Luggage Tag
            Image("RoomCodeTagEmpty")
                .resizable()
                .scaledToFit()

            // Overlay Content (Enter Room Code + Box Putus-putus)
            VStack(alignment: .leading, spacing: 6) {
                Text("Enter Room Code")
                    .font(.shantellSans(18, .semibold))
                    .foregroundColor(.black)

                // Inner Box Putus-putus
                ZStack(alignment: .leading) {
                    HStack {
                        if code.isEmpty {
                            if isFocused {
                                Text("|")
                                    .font(.spaceGrotesk(28, .bold))
                                    .foregroundColor(.black)
                            }
                        } else {
                            Text(code)
                                .font(.spaceGrotesk(48, .medium))
                                .tracking(6)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }
                .frame(height: 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color(red: 0.45, green: 0.15, blue: 0.15),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                        )
                )
            }
            .padding(.leading, 24)
            .padding(.trailing, 160) // Memberi ruang agar ikon pesawat tidak tertutup
            .padding(.vertical, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        InputRoomCodeCard(code: .constant("DRPF"))
            .padding()
    }
}
