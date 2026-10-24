//
//  PrimaryButtonStyle.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    // Warna default mengambil dari Design System
    var backgroundColor: Color = Color(red: 0x0E / 255.0, green: 0x13 / 255.0, blue: 0x20 / 255.0) // Navy gelap / hitam
    var borderColor: Color = Color("TaxiYellow")          // Kuning cerah
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 15
    
    // Apakah tombol memenuhi lebar layar (Full Width) atau wrap content
    var isFullWidth: Bool = false

    // Membaca state apakah tombol sedang di-disable atau aktif
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isEnabled

        HStack(spacing: 12) {
            configuration.label
        }
        .font(.plusJakarta(16, .bold))
        .foregroundStyle(isEnabled ? foregroundColor : Color(uiColor: .systemGray))
        .padding(.vertical, 16)
        .padding(.horizontal, 33)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        // 1. LAYER DEPAN (Permukaan Tombol)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isEnabled ? backgroundColor : Color(uiColor: .systemGray4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isEnabled ? borderColor : Color.clear, lineWidth: 2)
        )
        // Efek tombol amblas saat ditekan
        .offset(y: isPressed ? 6 : 0)
        // 2. LAYER BELAKANG (Bayangan Kuning persis mengikuti lebar tombol)
        .background(
            Group {
                if isEnabled {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(borderColor)
                        .offset(y: 6)
                }
            }
        )
        .padding(.bottom, 4) // Memberi ruang agar bayangan 4pt di bawah tidak terpotong
        .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
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
