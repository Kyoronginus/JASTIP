//
//  InputNameView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

// MARK: - 3. Input Name View
struct InputNameView: View {
    @Binding var name: String
    var isHost: Bool
    var isLoading: Bool
    var onSubmit: () -> Void

    var body: some View {
        VStack {
            Spacer()
            InputNameCard(
                name: $name,
                isHost: isHost,
                isLoading: isLoading
            ) {
                onSubmit()
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}
