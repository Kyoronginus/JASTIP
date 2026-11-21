//
//  AirlineCardView.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 24/10/26.
//

import SwiftUI

struct AirlineCardView: View {
    @Environment(\.accessibilityReduceMotion) private var isReduceMotionEnabled
    @State private var viewModel: AirlineCardViewModel

    private let bubbleCornerRadius: CGFloat = 34

    init(viewModel: AirlineCardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    init(airlineCard: AirlineCardModel, onProceedToGame: @escaping () -> Void = {}) {
        _viewModel = State(
            initialValue: AirlineCardViewModel(
                airlineCard: airlineCard,
                onProceedToGame: onProceedToGame
            )
        )
    }

    private var bubbleTransition: AnyTransition {
        isReduceMotionEnabled
            ? .opacity
            : .move(edge: .trailing).combined(with: .opacity)
    }

    var body: some View {
        ZStack {
            Color("BackgroundChat")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .trailing, spacing: 16) {
                        if viewModel.visibleBubbleCount >= 1 {
                            openJastipBubble
                                .transition(bubbleTransition)
                        }

                        if viewModel.visibleBubbleCount >= 2 {
                            promptBubble
                                .transition(bubbleTransition)
                        }

                        if viewModel.visibleBubbleCount >= 3 {
                            luggageAllowanceBubble
                                .transition(bubbleTransition)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 22)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }

                Spacer(minLength: 12)

                Button("Proceed to Game") {
                    viewModel.proceed(reduceMotion: isReduceMotionEnabled)
                }
                .buttonStyle(PrimaryButtonStyle(
                    font: .shantellSans(22, .bold),
                    isFullWidth: true
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .opacity(viewModel.showButton ? 1 : 0)
                .allowsHitTesting(viewModel.showButton && !viewModel.isFadingOut)
            }
            .opacity(viewModel.isFadingOut ? 0 : 1)
        }
        .onAppear {
            viewModel.startRevealSequence(reduceMotion: isReduceMotionEnabled)
        }
        .onDisappear {
            viewModel.cancelRevealSequence()
        }
    }

    // MARK: - Header (Matches ObjectiveView)

    private var headerSection: some View {
        VStack(spacing: 0) {
            Text("Jastip Orders")
                .font(.spaceGrotesk(33.4, .bold))
                .foregroundStyle(.black)
                .padding(.top, 10)
                .padding(.bottom, 10)

            Image("HeaderLine")
        }
    }

    // MARK: - Outgoing Blue Chat Bubbles

    private var openJastipBubble: some View {
        Text("OPEN JASTIP!!🛍️")
            .font(.system(size: 32, weight: .regular))
            .tracking(-0.32)
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .modifier(OutgoingChatBubbleModifier(cornerRadius: bubbleCornerRadius))
    }

    private var promptBubble: some View {
        Text("anyone need\nanything?")
            .font(.system(size: 32, weight: .regular))
            .tracking(-0.32)
            .foregroundStyle(.white)
            .multilineTextAlignment(.trailing)
            .lineSpacing(-2)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .modifier(OutgoingChatBubbleModifier(cornerRadius: bubbleCornerRadius))
    }

    private var luggageAllowanceBubble: some View {
        let dayWord = viewModel.totalRounds == 1 ? "day" : "days"

        return VStack(alignment: .trailing, spacing: 14) {
            (Text("flying back in ") + Text("\(viewModel.totalRounds) \(dayWord)").bold())
                .font(.system(size: 36, weight: .regular))
                .tracking(-0.32)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.trailing, 4)

            HStack(spacing: 8) {
                LuggageLimitCard(
                    title: "Suitcase",
                    imageName: "Suitcase-airline",
                    imageHeight: 68,
                    maxKg: viewModel.airlineCard.maxCapacityKg
                )

                LuggageLimitCard(
                    title: "Carry-On",
                    imageName: "Carry-on-airline",
                    imageHeight: 45,
                    maxKg: viewModel.airlineCard.maxCarryOnKg
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .modifier(OutgoingChatBubbleModifier(leadingMinSpacer: 12, cornerRadius: bubbleCornerRadius))
    }
}

private struct OutgoingChatBubbleModifier: ViewModifier {
    var leadingMinSpacer: CGFloat = 28
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        HStack {
            Spacer(minLength: leadingMinSpacer)

            content
                .background(Color("Reply"))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

// MARK: - Inner Luggage Limit Card

private struct LuggageLimitCard: View {
    let title: String
    let imageName: String
    let imageHeight: CGFloat
    let maxKg: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .tracking(-0.32)
                .foregroundStyle(.black)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: imageHeight)
                .frame(height: 70)

            (Text("Max: ").font(.system(size: 19, weight: .regular))
             + Text("\(maxKg) kg").font(.system(size: 19, weight: .bold)))
                .tracking(-0.32)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    let card = AirlineCardCatalog.allCards.first {
        $0.departureTime == "15:00" && $0.maxCapacityKg == 20 && $0.maxCarryOnKg == 7
    } ?? AirlineCardCatalog.allCards[0]

    return AirlineCardView(airlineCard: card) {
        print("Proceed to intro video!")
    }
}
