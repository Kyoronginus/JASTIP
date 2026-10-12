//
//  RevealedSheetsView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 11/10/26.
//

import SwiftUI

struct RevealedSheetsView: View {
    @Environment(\.dismiss) private var dismiss


    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .tertiarySystemFill))
                                    .frame(height: 100)
                                if index % 3 == 0 {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.primary.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                } else if index % 3 == 1 {
                                    Circle()
                                        .fill(Color.primary.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.primary.opacity(0.3))
                                        .frame(width: 70, height: 35)
                                }
                            }
                            
                            VStack(spacing: 4) {
                                Text("Shape #\(index + 1)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                
                                Text("? kg")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Revealed Shapes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}

#Preview("Light", traits: .landscapeRight) {
    RevealedSheetsView()
        .preferredColorScheme(.light)
}

#Preview("Dark", traits: .landscapeRight) {
    RevealedSheetsView()
        .preferredColorScheme(.dark)
}
