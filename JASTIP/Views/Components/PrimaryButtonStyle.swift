//
//  PrimaryButtonStyle.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
