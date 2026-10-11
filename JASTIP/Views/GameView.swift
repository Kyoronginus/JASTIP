//
//  GameView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GameSessionViewModel
    var onOpenCamera: () -> Void

    init(
        airlineCard: AirlineCardModel = AirlineCardCatalog.dummy,
        onOpenCamera: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: GameSessionViewModel(airlineCard: airlineCard))
        self.onOpenCamera = onOpenCamera
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            HStack {
                AirlineCard(data: viewModel.displayedAirlineCard)

                Spacer()

                VStack(spacing: 12) {
                    Spacer()

                    Text("TIME: \(viewModel.currentTimeString)")
                        .font(.title2.bold())

                    Spacer()

                    Button("SCAN QR", action: onOpenCamera)
                        .buttonStyle(PrimaryButtonStyle())

                    Button("Next Hour") {
                        viewModel.nextHour()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Spacer()

                    Text("TIME: \(viewModel.currentTimeString)")
                        .font(.title2.bold())
                        .rotationEffect(.degrees(180))

                    Spacer()
                }

                Spacer()

                AirlineCard(data: viewModel.displayedAirlineCard)
                    .rotationEffect(.degrees(180))
            }
            .padding(.horizontal, 24)

            if let event = viewModel.currentEvent {
                // Backdrop redup
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.dismissEvent()
                    }

                EventAlertView(event: event) {
                    withAnimation {
                        viewModel.dismissEvent()
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentEvent != nil)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isGameOver) { _, isOver in
            if isOver {
                dismiss()
            }
        }
    }
}

#Preview("Light", traits: .landscapeRight) {
    GameView()
        .preferredColorScheme(.light)
}

#Preview("Dark", traits: .landscapeRight) {
    GameView()
        .preferredColorScheme(.dark)
}
