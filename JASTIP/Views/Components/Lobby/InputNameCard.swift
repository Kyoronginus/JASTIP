//
//  InputNameCard.swift
//  JASTIP
//

import SwiftUI

struct InputNameCard: View {
    @Binding var name: String
    var isHost: Bool
    var isLoading: Bool
    var onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Input your name")
                .font(.plusJakarta(16, .bold))
                .foregroundStyle(Color("NavyBlack"))

            // Input Pill
            HStack {
                TextField("Username", text: $name)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.plusJakarta(15, .medium))
                    .foregroundStyle(Color("NavyBlack"))

                if !name.isEmpty {
                    Button {
                        name = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color("NavyBlack").opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.inputNameBar))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Action Button
            Button(isHost ? "Enter Room" : "Enter Room") {
                onSubmit()
            }
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .disabled(!isValid || isLoading)
        }
        .padding(20)
        .background(Color(.inputNameBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.navyBlack), lineWidth: 2)
        )
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    InputNameCard(
        name: .constant("Tohru"),
        isHost: true,
        isLoading: false
    ) {}
}
