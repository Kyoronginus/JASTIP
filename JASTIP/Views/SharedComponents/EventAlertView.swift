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
    let event: RandomEventModel
    var onDismiss: () -> Void = {}
    
    @State private var angle: Double = 0
    @State private var offsetY: CGFloat = 650
    @State private var showButton: Bool = false
    @State private var isDismissing: Bool = false
    
    var body: some View {
        ZStack {
            // Dimmed overlay background
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    if angle >= 180 {
                        dismissWithAnimation()
                    }
                }
            
            VStack(spacing: 24) {
                // 3D Flip Card using EventCard component
                CardFlipView(angle: angle) {
                    EventCard(event: event, isFaceUp: true)
                } back: {
                    EventCard(event: event, isFaceUp: false)
                }
                .onTapGesture {
                    if angle >= 180 {
                        dismissWithAnimation()
                    }
                }
                
                // OK Button
                if showButton {
                    Button {
                        dismissWithAnimation()
                    } label: {
                        Text("OK, GOT IT")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .tracking(1)
                            .frame(maxWidth: 240)
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: Color("NavyBlack"),
                        borderColor: Color("TaxiYellow"),
                        foregroundColor: .white,
                        cornerRadius: 16,
                        paddingVertical: 14,
                        paddingHorizontal: 20
                    ))
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                } else {
                    Color.clear
                        .frame(height: 52)
                }
            }
            .offset(y: offsetY)
        }
        .onAppear {
            startEntranceSequence()
        }
    }
    
    // MARK: - Animation Sequence
    private func startEntranceSequence() {
        // 1. Slide up face-down
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            offsetY = 0
        }
        
        // 2. 3D Flip reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
            withAnimation(.easeInOut(duration: 0.65)) {
                angle = 180
            }
        }
        
        // 3. Reveal dismiss button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            withAnimation(.easeIn(duration: 0.25)) {
                showButton = true
            }
        }
    }
    
    private func dismissWithAnimation() {
        guard !isDismissing else { return }
        isDismissing = true
        withAnimation(.easeIn(duration: 0.28)) {
            offsetY = 700
            showButton = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
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
