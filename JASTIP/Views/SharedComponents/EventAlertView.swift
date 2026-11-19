//
//  EventAlertView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct CardFlipView<Front: View, Back: View>: View, Animatable {
    var angle: Double
    @ViewBuilder let front: () -> Front
    @ViewBuilder let back: () -> Back
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    var body: some View {
        let isFront = angle >= 90
        ZStack {
            if isFront {
                front()
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                back()
            }
        }
        .rotation3DEffect(
            .degrees(angle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.6
        )
    }
}

struct EventAlertView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let event: RandomEventModel
    var targetFrame: CGRect = .zero
    var startsFromTarget: Bool = false
    var onDismiss: () -> Void = {}
    
    @State private var angle: Double = 0
    @State private var offsetY: CGFloat = 650
    @State private var showButton: Bool = false
    @State private var isDismissing: Bool = false
    @State private var isFlyingToTarget: Bool = false
    @State private var backdropOpacity: Double = 0.55
    @State private var reduceMotionBackdropOpacity: Double = 0
    @State private var cardOpacity: Double = 0
    @State private var cardRestCenter: CGPoint = .zero
    
    init(
        event: RandomEventModel,
        targetFrame: CGRect = .zero,
        startsFromTarget: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.event = event
        self.targetFrame = targetFrame
        self.startsFromTarget = startsFromTarget
        self.onDismiss = onDismiss
        _angle = State(initialValue: startsFromTarget ? 180 : 0)
        _offsetY = State(initialValue: startsFromTarget ? 0 : 650)
        _isFlyingToTarget = State(initialValue: startsFromTarget)
        _backdropOpacity = State(initialValue: startsFromTarget ? 0 : 0.55)
    }

    private var hasValidTarget: Bool {
        targetFrame.width > 0 && targetFrame.height > 0 && cardRestCenter != .zero
    }
    
    private var cardScale: CGFloat {
        (isFlyingToTarget && hasValidTarget) ? (targetFrame.width / 270.0) : 1.0
    }
    
    private var cardTiltDegrees: Double {
        (isFlyingToTarget && hasValidTarget) ? 7.0 : 0.0
    }
    
    private var cardOffsetX: CGFloat {
        (isFlyingToTarget && hasValidTarget) ? (targetFrame.midX - cardRestCenter.x) : 0
    }
    
    private var cardOffsetY: CGFloat {
        if isFlyingToTarget {
            return hasValidTarget ? (targetFrame.midY - cardRestCenter.y) : 700
        }
        return offsetY
    }
    
    var body: some View {
        let isFlyingVisual = !reduceMotion && isFlyingToTarget && hasValidTarget

        ZStack {
            // Dimmed overlay background
            Color.black.opacity(reduceMotion ? reduceMotionBackdropOpacity : backdropOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    if reduceMotion || angle >= 180 {
                        dismissWithAnimation()
                    }
                }
            
            VStack(spacing: 24) {
                // Layout slot tetap di tengah agar titik istirahat kartu terukur akurat dalam koordinat global
                Color.clear
                    .frame(width: 270, height: 393)
                    .background(
                        GeometryReader { slotGeo in
                            Color.clear
                                .onAppear {
                                    let frame = slotGeo.frame(in: .global)
                                    cardRestCenter = CGPoint(x: frame.midX, y: frame.midY)
                                }
                                .onChange(of: slotGeo.frame(in: .global)) { _, newFrame in
                                    cardRestCenter = CGPoint(x: newFrame.midX, y: newFrame.midY)
                                }
                        }
                    )
                    .overlay {
                        // 3D Flip Card using EventCard component
                        CardFlipView(angle: reduceMotion ? 180 : angle) {
                            EventCard(
                                event: event,
                                isFaceUp: true,
                                shadowColor: .black.opacity(isFlyingVisual ? 0.22 : 0.45),
                                shadowRadius: isFlyingVisual ? 0 : 20,
                                shadowX: isFlyingVisual ? 10 : 0,
                                shadowY: isFlyingVisual ? 12 : 10
                            )
                        } back: {
                            EventCard(event: event, isFaceUp: false)
                        }
                        .scaleEffect(reduceMotion ? 1.0 : cardScale)
                        .rotationEffect(.degrees(reduceMotion ? 0.0 : cardTiltDegrees))
                        .offset(x: reduceMotion ? 0 : cardOffsetX, y: reduceMotion ? 0 : cardOffsetY)
                        .opacity(reduceMotion ? cardOpacity : 1.0)
                        .onTapGesture {
                            if reduceMotion || angle >= 180 {
                                dismissWithAnimation()
                            }
                        }
                    }
                
                // OK Button (layout tetap agar kartu tidak bergeser saat showButton berubah)
                Button {
                    dismissWithAnimation()
                } label: {
                    Text("OK, GOT IT")
                        .tracking(1)
                        .frame(maxWidth: 240)
                }
                .buttonStyle(PrimaryButtonStyle(
                    foregroundColor: .black,
                    cornerRadius: 16,
                    paddingVertical: 14,
                    paddingHorizontal: 20
                ))
                .opacity(showButton ? 1 : 0)
                .scaleEffect(reduceMotion ? 1 : (showButton ? 1 : 0.92))
                .disabled(!showButton)
                .allowsHitTesting(showButton)
            }
        }
        .onAppear {
            startEntranceSequence()
        }
    }
    
    // MARK: - Animation Sequence
    private func startEntranceSequence() {
        if reduceMotion {
            withAnimation(.easeInOut(duration: 0.25)) {
                reduceMotionBackdropOpacity = 0.55
                cardOpacity = 1
                showButton = true
            }
            return
        }

        if startsFromTarget {
            // Tunggu 1 runloop agar slotGeo.onAppear sudah mengisi cardRestCenter
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                    isFlyingToTarget = false
                    backdropOpacity = 0.55
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.2)) {
                    showButton = true
                }
            }
            return
        }

        // Flow lama untuk event baru
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            offsetY = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
            withAnimation(.easeInOut(duration: 0.65)) {
                angle = 180
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            withAnimation(.easeIn(duration: 0.25)) {
                showButton = true
            }
        }
    }
    
    private func dismissWithAnimation() {
        guard !isDismissing else { return }
        isDismissing = true
        if reduceMotion {
            withAnimation(.easeInOut(duration: 0.22)) {
                showButton = false
                reduceMotionBackdropOpacity = 0
                cardOpacity = 0
            } completion: {
                onDismiss()
            }
            return
        }
        withAnimation(.easeOut(duration: 0.18)) {
            showButton = false
        }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
            backdropOpacity = 0
            isFlyingToTarget = true
        } completion: {
            onDismiss()
        }
    }
}

#Preview("Flight Delayed") {
    EventAlertView(
        event: RandomEventCatalog.createEvent(for: .flightDelay)
    )
}

#Preview("Stores Closed") {
    EventAlertView(
        event: RandomEventCatalog.createEvent(for: .storesClosed)
    )
}

#Preview("Free Items (0 kg)") {
    EventAlertView(
        event: RandomEventCatalog.createEvent(for: .zeroWeight)
    )
}
