//
//  PrimaryButtonStyle.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    // Warna default mengambil dari Design System
    var backgroundColor: Color = Color("NavyBlack")
    var borderColor: Color = Color("TaxiYellow")
    var shadowColor: Color? = nil
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 15
    var borderWidth: CGFloat = 2
    var shadowOffset: CGFloat = 6
    
    // Apakah tombol memenuhi lebar layar (Full Width) atau wrap content
    var isFullWidth: Bool = false
    
    var paddingVertical: CGFloat = 16
    var paddingHorizontal: CGFloat = 33

    private var resolvedShadowColor: Color {
        shadowColor ?? borderColor
    }

    // Membaca state apakah tombol sedang di-disable atau aktif
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isEnabled

        HStack(spacing: 12) {
            configuration.label
        }
        .font(.plusJakarta(16, .bold))
        .foregroundStyle(isEnabled ? foregroundColor : Color(uiColor: .systemGray))
        .padding(.vertical, paddingVertical)
        .padding(.horizontal, paddingHorizontal)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        // 1. LAYER DEPAN (Permukaan Tombol)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isEnabled ? backgroundColor : Color(uiColor: .systemGray4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isEnabled ? borderColor : Color.clear, lineWidth: borderWidth)
        )
        // Efek tombol amblas saat ditekan
        .offset(y: isPressed ? shadowOffset : 0)
        // 2. LAYER BELAKANG (Bayangan 3D mengikuti lebar tombol)
        .background(
            Group {
                if isEnabled {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(resolvedShadowColor)
                        .offset(y: shadowOffset)
                }
            }
        )
        .padding(.bottom, shadowOffset)
        .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Convenience Helpers
extension PrimaryButtonStyle {
    static func square(
        color: Color,
        size: CGFloat = 40,
        cornerRadius: CGFloat = 11
    ) -> PrimaryButtonStyle {
        PrimaryButtonStyle(
            backgroundColor: Color("NavyBlack"),
            borderColor: color,
            shadowColor: color,
            foregroundColor: color,
            cornerRadius: cornerRadius,
            borderWidth: 1.5,
            shadowOffset: 4,
            isFullWidth: false,
            paddingVertical: 10,
            paddingHorizontal: 10
        )
    }
}

// PREVIEW LIGHT MODE
#Preview("Light Mode") {
    ButtonPreviewContent()
        .preferredColorScheme(.light)
}

// PREVIEW DARK MODE
#Preview("Dark Mode") {
    ButtonPreviewContent()
        .preferredColorScheme(.dark)
}

// Helper View agar kodenya tidak duplikat panjang
private struct ButtonPreviewContent: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - COMPACT BUTTONS
                VStack(alignment: .leading, spacing: 16) {
                    Text("Compact Variants")
                        .font(.plusJakarta(14, .bold))
                        .foregroundStyle(.gray)

                    Button("Button") {}
                        .buttonStyle(PrimaryButtonStyle())

                    Button {
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(Color("TaxiYellow"))
                        Text("Button")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Button") {}
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // MARK: - FULL WIDTH BUTTONS
                VStack(alignment: .leading, spacing: 16) {
                    Text("Full Width Variants")
                        .font(.plusJakarta(14, .bold))
                        .foregroundStyle(.gray)

                    Button("Button") {}
                        .buttonStyle(PrimaryButtonStyle(isFullWidth: true))

                    Button {
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(Color("TaxiYellow"))
                        Text("Button")
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))

                    Button("Button") {}
                        .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                        .disabled(true)
                }
            }
            .padding(24)
        }
    }
}
