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
        if case let .calendarTear(oldDay, _) = viewModel.roundAnimationPhase {
            return oldDay
        }
        return daysToGo ?? viewModel.daysToGo
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
                    .padding(.top, 28)
                
                Spacer(minLength: 16)
                
                // MARK: - Middle Section (Suitcase & Carry-On di Atas Kasur)
                luggagePairSection
                    .padding(.horizontal, 20)
                
                Spacer(minLength: 140)
                
                // MARK: - Bottom Section: Slot UI HP Jastip Order (Dihandle oleh Dev Lain)
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
                        Text(!viewModel.isMyTurn ? "Waiting..." : (viewModel.isDraftingObjective ? "Drafting..." : "End Turn"))
                            .font(.shantellSans(14, .bold))
                    }
                    .disabled(!viewModel.isMyTurn)
                    .opacity(viewModel.isMyTurn ? 1.0 : 0.6)
                    .disabled(!viewModel.canEndTurn)
                    .opacity(viewModel.canEndTurn ? 1.0 : 0.6)
                    .buttonStyle(
                        PrimaryButtonStyle(
                            backgroundColor: viewModel.isMyTurn ? Color("EndTurn") : Color.gray,
                            borderColor: Color("EndTurn"),
                            shadowColor: Color("EndTurn").opacity(0.65),
                            foregroundColor: .white,
                            cornerRadius: 8,
                            borderWidth: 1.5,
                            yShadowOffset: 4,
                            xShadowOffset: 2,
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
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: displayedDaysToGo)
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
    
    // Memilih nama asset otomatis: "Calendar-7", "Calendar-6", dst.
    private var calendarImageName: String {
        let clamped = max(0, min(10, daysToGo))
        return "Calendar-\(clamped)"
    }
    
    var body: some View {
        Image(calendarImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 148)
            .id(daysToGo) // Memicu re-render & animasi saat harinya berkurang
            .transition(.scale.combined(with: .opacity))
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

// MARK: - Overlay: End of Round Calendar Tear & Restock Animation
struct RoundTransitionOverlayView: View {
    let phase: RoundAnimationPhase
    let onCalendarTearFinished: () -> Void
    let onContinueTapped: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed background di atas koper/kasur
            Color.black.opacity(0.42)
                .ignoresSafeArea()
            
            switch phase {
            case .none:
                EmptyView()
            case let .calendarTear(oldDay, newDay):
                CalendarTearAnimationView(
                    oldDay: oldDay,
                    newDay: newDay,
                    onFinished: onCalendarTearFinished
                )
            case .restock:
                RestockStoreAnimationView(onContinue: onContinueTapped)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 1. Animasi Geser Sobek Kalender (Pure Slide ke Kanan)
private struct CalendarTearAnimationView: View {
    let oldDay: Int
    let newDay: Int
    let onFinished: () -> Void
    private let tearHaptic = UIImpactFeedbackGenerator(style: .medium)
//    private let finishHaptic = UIImpactFeedbackGenerator(style: .light)
    
    @State private var isSlidAway: Bool = false
    
    private var clampedOldDay: Int {
        max(0, min(10, oldDay))
    }
    
    private var clampedNewDay: Int {
        max(0, min(10, newDay))
    }
    
    var body: some View {
        ZStack {
            // Layer Belakang: Kalender utuh hari baru
            Image("Calendar-\(clampedNewDay)")
                .resizable()
                .scaledToFit()
                .frame(width: 236, height: 318)
            
            // Layer Depan: Lembaran angka hari lama yang meluncur ke kanan
            Image("CalendarNumber-\(clampedOldDay)")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 226)
                .offset(x: isSlidAway ? 380 : -4, y: 40)
                .opacity(isSlidAway ? 0.3 : 1.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .offset(y: -20)
        .task(id: "\(oldDay)->\(newDay)") {
            isSlidAway = false
            tearHaptic.prepare()
            
            // 1. Tahan sebentar sebelum kertas sobek
            try? await Task.sleep(nanoseconds: 120_000_000)
            guard !Task.isCancelled else { return }
            
            // 2. Picu suara dan haptic hentakan awal tepat saat animasi geser dimulai
            tearHaptic.impactOccurred()
            AudioManager.shared.play("paper-tear") // Mainkan SFX (jika aset sudah dimasukkan)
            
            withAnimation(.easeInOut(duration: 0.42)) {
                isSlidAway = true
            }
            
            // 3. Tunggu durasi animasi geser selesai (420ms)
            try? await Task.sleep(nanoseconds: 420_000_000)
            guard !Task.isCancelled else { return }
            
//            // 4. Haptic ringan saat lembaran lama lepas penuh dan angka hari baru terlihat
//            finishHaptic.impactOccurred()
//            
            // 5. Beri jeda sisa (230ms) agar pemain sempat melihat hari baru sebelum pindah ke Restock
            try? await Task.sleep(nanoseconds: 930_000_000)
            guard !Task.isCancelled else { return }
            onFinished()
        }
    }
}

// MARK: - 2. Stop-Motion Animasi Restock ("Time to shift the store items", 100ms per frame)
private struct RestockStoreAnimationView: View {
    let onContinue: () -> Void
    
    @State private var currentFrame: Int = 1
    private let totalFrames: Int = 20
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Time to shift the store items")
                .font(.shantellSans(18, .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
                .padding(.bottom, -36)
                .zIndex(2)
            
            Image("CardV4-\(currentFrame)")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)
                .allowsHitTesting(false)
                .offset(y: -55)
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: Color("ScanItem"),
                    borderColor: Color("ScanItem"),
                    shadowColor: Color("SuitcaseFrame").opacity(0.65),
                    foregroundColor: .black,
                    font: .shantellSans(20, .bold),
                    cornerRadius: 16,
                    borderWidth: 1.5,
                    yShadowOffset: 4,
                    xShadowOffset: 2,
                    paddingVertical: 14,
                    paddingHorizontal: 24
                )
            )
            .padding(.horizontal, 28)
            .padding(.top, -18)
        }
        .offset(y: -10)
        .task {
            currentFrame = 1
            while !Task.isCancelled {
                for frame in 1...totalFrames {
                    currentFrame = frame
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    if Task.isCancelled { return }
                }
                // Jeda singkat di akhir siklus sebelum mengulang
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
        }
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

#Preview("1. End of Round - Calendar Tear -> Restock") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    mockViewModel.daysToGo = 6
    mockViewModel.triggerRoundTransitionAnimation(from: 7, to: 6)
    return GameView(
        viewModel: mockViewModel,
        currentTurnPlayerName: "maxwell"
    )
}

#Preview("2. Restock Animation Only") {
    let mockViewModel = GameSessionViewModel(airlineCard: AirlineCardCatalog.dummy)
    mockViewModel.isBoarded = false
    mockViewModel.daysToGo = 7
    mockViewModel.roundAnimationPhase = .restock
    return GameView(
        viewModel: mockViewModel,
        currentTurnPlayerName: "maxwell"
    )
}
