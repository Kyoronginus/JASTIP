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
                    // Track (Background)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                    
                    // Filled Progress Area
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue)
                    // Multiply the total height by the progress fraction
                        .frame(height: geometry.size.height * CGFloat(max(0, min(progress, 1))))
                }
            }
            // Set the size of the container boundary here
            .frame(width: x, height: y)
            .animation(.default, value: progress) // Smooth fill animation
        }
    }
}

#Preview {
    ProgressBar(progress: 0.4, x: 200, y: 250)
}
