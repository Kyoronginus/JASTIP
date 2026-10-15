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

    // 1. Read the system environment state for disabled controls
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            // 2. Change background color dynamically if disabled
            .background(
                isEnabled
                    ? backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0)
                    : Color(.systemGray4) // Gray look when disabled
            )
            // 3. Optional: Dim text color slightly when disabled
            .foregroundStyle(isEnabled ? foregroundColor : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // 4. Prevent the press shrinking effect when disabled
            .scaleEffect(isEnabled && configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
