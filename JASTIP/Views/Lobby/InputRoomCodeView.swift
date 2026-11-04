//
//  InputRoomCodeView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 26/10/26.
//

import SwiftUI

// MARK: - 2. Input Room Code View
struct InputRoomCodeView: View {
    @Binding var code: String
    var onSubmit: () -> Void

    var body: some View {
        VStack {
            Spacer()
            InputRoomCodeCard(code: $code) {
                onSubmit()
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}
