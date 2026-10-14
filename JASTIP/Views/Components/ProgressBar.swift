//
//  VerticalNativeProgressView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 14/10/26.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let x: CGFloat
    let y: CGFloat
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.6))
                        .frame(height: geometry.size.height * CGFloat(max(0, min(progress, 1))))
                }
            }
            .frame(width: x, height: y)
            .animation(.default, value: progress)
        }
    }
}

#Preview {
    ProgressBar(progress: 0.4, x: 200, y: 250)
}
