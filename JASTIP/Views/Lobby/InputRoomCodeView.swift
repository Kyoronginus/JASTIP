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
    var onBack: () -> Void = {}
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar: Back Button
            HStack {
//                Button {
//                    onBack()
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundStyle(Color("NavyBlack"))
//                        .frame(width: 44, height: 44)
//                        .background(Color("TaxiYellow"))
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color("NavyBlack"), lineWidth: 2)
//                        )
//                }
                
                // Back Button
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                }
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: .black,
                    borderColor: Color("TaxiYellow"),
                    foregroundColor: Color("TaxiYellow"),
                    cornerRadius: 14,
                    paddingVertical: 14,
                    paddingHorizontal: 15
                ))
                .padding(.trailing, 10)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            InputRoomCodeCard(code: $code) {
                onSubmit()
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
