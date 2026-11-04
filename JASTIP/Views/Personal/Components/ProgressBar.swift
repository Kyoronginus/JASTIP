//
//  VerticalNativeProgressView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 14/10/26.
//

import SwiftUI

// MARK: - Luggage config
enum LuggageType {
    case suitcase
    case carryOn

    var baseImage: String { self == .suitcase ? "suitcase_base" : "carryon_base" }
    var darkImage: String { self == .suitcase ? "suitcase_dark" : "carryon_dark" }

    /// tinggi / lebar canvas (base & dark harus canvas-nya sama)
    var aspectRatio: CGFloat { self == .suitcase ? 296.0 / 147.0 : 134.0 / 92.0 }

    /// Area body (fraksi dari tinggi canvas), lapisan gelap bergerak di dalam range ini
    var bodyTop: CGFloat { self == .suitcase ? 0.115 : 0.07 }
    var bodyBottom: CGFloat { self == .suitcase ? 0.885 : 0.76 }

    // Stamp
    var stampWidthRatio: CGFloat { 0.42 }
    var stampRotation: Double { self == .suitcase ? 8.83 : -10.23 }
    var stampCenter: CGPoint {
        self == .suitcase ? CGPoint(x: 0.47, y: 0.34) : CGPoint(x: 0.5, y: 0.44)
    }
}

// MARK: - ProgressBar
struct ProgressBar: View {
    let luggage: LuggageType
    let weight: Int
    let maxWeight: Int
    var width: CGFloat = 150

    private let navy = Color(red: 0x0E / 255.0, green: 0x13 / 255.0, blue: 0x20 / 255.0)

    private var height: CGFloat { width * luggage.aspectRatio }

    private var progress: Double {
        guard maxWeight > 0 else { return 0 }
        return min(max(Double(weight) / Double(maxWeight), 0), 1)
    }

    private var isOverweight: Bool { weight > maxWeight }

    private var bodyTopY: CGFloat { height * luggage.bodyTop }
    private var bodyHeight: CGFloat { height * (luggage.bodyBottom - luggage.bodyTop) }

    /// Area gelap = sisa kapasitas
    private var darkHeight: CGFloat { bodyHeight * (1 - progress) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(luggage.baseImage)
                .resizable()
                .frame(width: width, height: height)

            Image(luggage.darkImage)
                .resizable()
                .frame(width: width, height: height)
                .mask(alignment: .top) {
                    Rectangle()
                        .frame(height: darkHeight)
                        .offset(y: bodyTopY)
                }

            if isOverweight && luggage == .suitcase {
                overweightBanner
            }

            stamp
        }
        .frame(width: width, height: height)
        .animation(.easeInOut(duration: 0.4), value: weight)
        .animation(.easeInOut(duration: 0.25), value: isOverweight)
    }

    // MARK: Stamp
    private var stamp: some View {
        let stampWidth = width * luggage.stampWidthRatio
        let numberColor = isOverweight ? Color("FragileRed") : Color("TransitTangerine")

        return ZStack {
            Image(isOverweight ? "stamp_red" : "stamp_blue")
                .resizable()
                .scaledToFit()

            VStack(spacing: 0) {
                Text("WEIGHT:")
                    .font(.spaceGrotesk(stampWidth * 0.13, .bold))

                Text("\(weight)")
                    .font(.spaceGrotesk(stampWidth * 0.5, .bold))
                    .foregroundStyle(numberColor)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            
                HStack{
                    Spacer()
                    Text("/ \(maxWeight) KG")
                        .font(.spaceGrotesk(stampWidth * 0.12, .bold))
                        .offset(x:-2)
                }

            }
            .foregroundStyle(navy)
            .padding(.horizontal, stampWidth * 0.12)
        }
        .frame(width: stampWidth)
        .overlay(alignment: .topTrailing) {
            // Badge peringatan di pojok stamp carry-on
            if isOverweight && luggage == .carryOn {
                Image("overweight_stamp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: stampWidth * 0.5)
                    .offset(x: stampWidth * 0.18, y: -stampWidth * 0.18)
                    .rotationEffect(.degrees(luggage.stampRotation * -2))
            }
        }
        .rotationEffect(.degrees(luggage.stampRotation))
        .position(x: width * luggage.stampCenter.x,
                  y: height * luggage.stampCenter.y)
    }

    // MARK: Overweight banner (suitcase only)
    private var overweightBanner: some View {
        Image("overweight_banner")
            .resizable()
            .scaledToFit()
            .frame(width: width * 0.72)
            .rotationEffect(.degrees(-8))
            .position(x: width * 0.53, y: height * 0.57)
            .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Preview
private struct ProgressBarPreview: View {
    @State private var suit: Double = 0
    @State private var carry: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .bottom, spacing: 24) {
                ProgressBar(luggage: .suitcase, weight: Int(suit), maxWeight: 20, width: 155)
                ProgressBar(luggage: .carryOn, weight: Int(carry), maxWeight: 7, width: 120)
            }
            Slider(value: $suit, in: 0...25, step: 1) { Text("Suitcase") }
            Slider(value: $carry, in: 0...10, step: 1) { Text("Carry-on") }
        }
        .padding()
    }
}

#Preview("Light") {
    ProgressBarPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ProgressBarPreview()
        .preferredColorScheme(.dark)
}
