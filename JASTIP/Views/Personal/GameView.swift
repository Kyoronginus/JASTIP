//
//  GameView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 21/10/26.
//


//
//  GameView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

extension LuggageType: Identifiable {
    var id: String { rawValue }
}

struct GameView: View {
    @Bindable private var viewModel: GameSessionViewModel
    var onOpenCamera: () -> Void
    
    // Properti UI Turn & Kalender (Siap disambungkan oleh dev yang mengerjakan logic turn/kalender)
    var currentTurnPlayerName: String? = nil
    var daysToGo: Int? = nil
    var onEndTurn: (() -> Void)? = nil
    
    private var displayedTurnPlayerName: String {
        currentTurnPlayerName ?? viewModel.currentTurnPlayerName
    }
    
    private var displayedDaysToGo: Int {
        daysToGo ?? viewModel.daysToGo
    }
    
    @State private var openedLuggage: LuggageType? = nil
    
    init(
        viewModel: GameSessionViewModel? = nil,
        airlineCard: AirlineCardModel = AirlineCardCatalog.dummy,
        currentTurnPlayerName: String? = nil,
        daysToGo: Int? = nil,
        onEndTurn: (() -> Void)? = nil,
        onOpenCamera: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel ?? GameSessionViewModel(airlineCard: airlineCard)
        self.currentTurnPlayerName = currentTurnPlayerName
        self.daysToGo = daysToGo
        self.onEndTurn = onEndTurn
        self.onOpenCamera = onOpenCamera
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Top Header (Turn & Calendar)
                topHeaderSection
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                
                Spacer(minLength: 16)
                
                // MARK: - Middle Section (Suitcase & Carry-On di Atas Kasur)
                luggagePairSection
                    .padding(.horizontal, 20)
                
                Spacer(minLength: 140)
                
                // MARK: - Bottom Section: Slot UI HP Jastip Order (Dihandle oleh Dev Lain)
            }
            
            // MARK: - Popup Event Aktif
            if let event = viewModel.currentEvent, !viewModel.isGameOver {
                EventAlertView(event: event) {
                    withAnimation {
                        viewModel.dismissEvent()
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("OpenSuitCaseViewBackground")
                .resizable()
                .scaledToFill()
                .overlay {
                    Color.black.opacity(0.4)
                }
                .ignoresSafeArea()
        )

        .animation(.easeInOut(duration: 0.2), value: viewModel.currentEvent != nil)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(item: $openedLuggage) { luggage in
            PersonalChildView(session: viewModel, initialLuggage: luggage)
        }
    }
    
    // MARK: - Subview: Top Header (Turn Info, End Turn Button, & Calendar)
    private var topHeaderSection: some View {
        HStack(alignment: .top) {
            // Kiri: Who's Turn + Tombol End Turn
            ZStack {
                Image("TurnTag")
                    .resizable()
                    .scaledToFit()
                
                VStack(alignment: .leading, spacing: 4) {
                    // 1. NAMA PEMAIN AKTIF (OTOMATIS BERUBAH)
                    Text("\(displayedTurnPlayerName)'s turn")
                        .font(.shantellSans(18, .bold))
                        .foregroundStyle(.black)
                    
                    // 2. TOMBOL END TURN (Hanya aktif jika giliran HP ini)
                    Button {
                        if let onEndTurn {
                            onEndTurn()
                        } else {
                            viewModel.endCurrentTurn()
                        }
                    } label: {
                        Text(viewModel.isMyTurn ? "End Turn" : "Waiting...")
                            .font(.shantellSans(14, .bold))
                    }
                    .disabled(!viewModel.isMyTurn)
                    .opacity(viewModel.isMyTurn ? 1.0 : 0.6)
                    .buttonStyle(
                        PrimaryButtonStyle(
                            backgroundColor: viewModel.isMyTurn ? Color("EndTurn") : Color.gray,
                            borderColor: .white,
                            shadowColor: Color("EndTurn").opacity(0.65),
                            foregroundColor: .white,
                            cornerRadius: 12,
                            borderWidth: 1.5,
                            shadowOffset: 4,
                            paddingVertical: 8,
                            paddingHorizontal: 16
                        )
                    )
                }
                .offset(x: -30)
            }
            .rotationEffect(.degrees(-3))
            
            Spacer()
            
            // 3. KANAN: KALENDER OTOMATIS BERKURANG TIAP ROUND
            CalendarCountdownView(daysToGo: displayedDaysToGo)
        }
    }
    
    // MARK: - Subview: Suitcase & Carry-On di Atas Kasur
    private var luggagePairSection: some View {
        HStack(alignment: .bottom, spacing: 8) {
            
            VStack {
                // 1. Suitcase (3x5)
                Button {
                    openedLuggage = .suitcase
                } label: {
                    LuggageGridView(
                        grid: viewModel.suitcaseGrid,
                        cellSize: 46,
                        cellSpacing: 2,
                        cellCornerRadius: 3,
                        isInteractive: false
                    )
                    .rotationEffect(.degrees(7))
                }
                .buttonStyle(.plain)
                .scaledToFit()
    //            .frame(width: 100)
                .offset(x: 0, y :-120)
                .disabled(viewModel.currentEvent != nil || viewModel.isBoarded)
                
                // text
                LuggageWeightLabel(currentWeight: viewModel.suitWeight, maxWeight: viewModel.displayedAirlineCard.maxCapacityKg)
                    .offset(x: 0, y: -100)
            }

            VStack {
                // 2. Carry-On (2x2)
                Button {
                    openedLuggage = .carryOn
                } label: {
                    LuggageGridView(
                        grid: viewModel.carryOnGrid,
                        cellSize: 46,
                        cellSpacing: 2,
                        cellCornerRadius: 3,
                        isInteractive: false
                    )
                    .rotationEffect(.degrees(-6))
                }
                .buttonStyle(.plain)
                .offset(x:0, y:-70)
                .disabled(viewModel.currentEvent != nil || viewModel.isBoarded)
                
                // text
                LuggageWeightLabel(currentWeight: viewModel.carryWeight, maxWeight: viewModel.displayedAirlineCard.maxCarryOnKg)
                    .offset(x: 0, y: -50)
            }
        }
    }
}

// MARK: - Subview: Kalender Countdown (ZStack Image + Angka)
struct CalendarCountdownView: View {
    let daysToGo: Int
    
    var body: some View {
        ZStack {
            Image("Calendar-1")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 148)
            
//            Text("\(daysToGo)")
//                .font(.shantellSans(64, .bold))
//                .foregroundStyle(Color("SuitcaseFrame"))
//                .offset(y: 16)
        }
    }
}

// MARK: - Subview: Weight label for baggages
struct LuggageWeightLabel: View {
    let currentWeight: Int
    let maxWeight: Int
    
    private var isOverweight: Bool {
        currentWeight > maxWeight
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(currentWeight)")
                .foregroundStyle(isOverweight ? Color.red : Color.black)
            Text("/ \(maxWeight) kg")
                .foregroundStyle(Color.black)
        }
        .font(.shantellSans(16, .bold))
    }
}

#Preview("PersonalView (OpenSuitcaseView)") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    return GameView(
        viewModel: mockViewModel,
        currentTurnPlayerName: "maxwell",
        daysToGo: 7
    )
}
