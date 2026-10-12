//
//  EventAlertView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct EventAlertView: View {
    let event: RandomEventModel
    var onDismiss: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("AIRPORT ANNOUNCEMENT")
                    .font(.caption.bold())
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            Divider()

            Text(event.title)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text(event.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Button(action: onDismiss) {
                Text("OK, GOT IT")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(
                backgroundColor: .primary,
                foregroundColor: Color(uiColor: .systemBackground)
            ))
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: 380)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

#Preview("Light", traits: .landscapeRight) {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        EventAlertView(
            event: RandomEventModel(
                title: "Bookstore Closed!",
                message: "The bookstore is taking a break. No items can be collected during this hour."
            )
        )
    }
    .preferredColorScheme(.light)
}

#Preview("Dark", traits: .landscapeRight) {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        EventAlertView(
            event: RandomEventModel(
                title: "Bookstore Closed!",
                message: "The bookstore is taking a break. No items can be collected during this hour."
            )
        )
    }
    .preferredColorScheme(.dark)
}

