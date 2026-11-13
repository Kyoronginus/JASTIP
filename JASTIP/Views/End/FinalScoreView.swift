//
//  FinalScoreView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/11/26.
//

import SwiftUI

struct FinalScoreView: View {
    var viewModel: GameSessionViewModel? = nil
    var standings: [PlayerStandingModel] = []
    var onBackToHome: () -> Void = {}
    
    @State private var revealedRowCount: Int = 0
    @State private var isWinnerVisible: Bool = false
    @State private var isBackToHomeVisible: Bool = false
    @State private var animationTask: Task<Void, Never>? = nil
    
    private let rowImpact = UIImpactFeedbackGenerator(style: .light)
    private let winnerFeedback = UINotificationFeedbackGenerator()
    
    private var activeStandings: [PlayerStandingModel] {
        if let vm = viewModel {
            return vm.finalStandings
        }
        return standings
    }
    
    private var displayedStandings: [PlayerStandingModel] {
        Array(activeStandings.prefix(5))
    }
    
    private var winnerName: String {
        displayedStandings.first?.name.lowercased() ?? "-"
    }
    
    private let receiptTextColor = Color(red: 58/255, green: 58/255, blue: 60/255)
    
    var body: some View {
        ZStack {
            // 1. Background Airport Gate
            Image("finalscoreBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2. Konten Utama (Skip Button, Struk Receipt, & Back to Home Button)
            VStack(spacing: 0) {
                Spacer(minLength: 12)
                
                // 3. Struk Receipt (ZStack di atas gambar Receipt)
                ZStack {
                    Image("Receipt")
                        .resizable()
                        .scaledToFit()
                    
                    VStack(spacing: 0) {
                        // Judul Struk
                        Text("FINAL STANDINGS")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(receiptTextColor)
                            .padding(.top, 26)
                            .padding(.bottom, 10)
                        
                        // Garis Pemisah Atas (* * * *)
                        dottedLine
                            .padding(.bottom, 12)
                        
                        // Header Kolom Tabel
                        HStack(spacing: 0) {
                            Text("")
                                .frame(width: 22, alignment: .leading)
                            Text("Player")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Income")
                                .frame(width: 66, alignment: .center)
                            Text("Penalty")
                                .frame(width: 66, alignment: .center)
                            Text("Total")
                                .frame(width: 54, alignment: .trailing)
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(receiptTextColor)
                        .padding(.bottom, 10)
                        
                        // Daftar Baris Pemain (Reveal satu per satu)
                        VStack(spacing: 10) {
                            ForEach(Array(displayedStandings.enumerated()), id: \.element.id) { index, player in
                                let isRevealed = index < revealedRowCount
                                HStack(spacing: 0) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 15, weight: .regular))
                                        .frame(width: 22, alignment: .leading)
                                    
                                    Text(player.name.lowercased())
                                        .font(.system(size: 15, weight: .regular))
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("$\(player.income)")
                                        .font(.system(size: 15, weight: .regular))
                                        .frame(width: 66, alignment: .center)
                                    
                                    Text(player.penalty > 0 ? "-$\(player.penalty)" : "-")
                                        .font(.system(size: 15, weight: .regular))
                                        .frame(width: 66, alignment: .center)
                                    
                                    Text("$\(player.total)")
                                        .font(.system(size: 15, weight: .bold))
                                        .frame(width: 54, alignment: .trailing)
                                }
                                .foregroundStyle(receiptTextColor)
                                .opacity(isRevealed ? 1 : 0)
                                .offset(y: isRevealed ? 0 : 6)
                            }
                        }
                        .frame(minHeight: 140, alignment: .top)
                        .padding(.bottom, 14)
                        
                        // Garis Pemisah Bawah (* * * *)
                        dottedLine
                            .padding(.bottom, 14)
                        
                        // Bagian Pemenang (WINNER)
                        ZStack {
                            // Bagian Pemenang (WINNER)
                            Text("WINNER:")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(receiptTextColor)
                                .offset(y: -20)
                                .overlay(
                                    Text(winnerName)
                                        .font(.shantellSans(66, .bold))
                                        .foregroundStyle(Color("FragileRed"))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: true, vertical: false) // Paksa lebar mengikuti panjang teks utuh (mencegah "...")
                                        .rotationEffect(.degrees(-8))
                                        .offset(y: 8)
                                        .opacity(isWinnerVisible ? 1 : 0)
                                        .scaleEffect(isWinnerVisible ? 1 : 0.6)                                )
                                .frame(height: 70)
                                .padding(.bottom, 16)
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 24)
                    // Kompensasi bayangan kanan & bawah pada asset Receipt.png
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 16)
                
                // 4. Tombol Back to Home (Muncul setelah semua teks tampil)
                VStack {
                    if isBackToHomeVisible {
                        Button("Back to Home") {
                            onBackToHome()
                        }
                        .buttonStyle(
                            PrimaryButtonStyle(
                                backgroundColor: Color("TaxiYellow"),
                                borderColor: Color("NavyBlack"),
                                foregroundColor: Color("NavyBlack"),
                                font: .shantellSans(20, .bold),
                                cornerRadius: 15,
                                borderWidth: 1.5,
                                yShadowOffset: 4,
                                xShadowOffset: 2,
                                isFullWidth: true,
                                paddingVertical: 16
                            )
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(height: 64)
                .padding(.horizontal, 30)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            startRevealSequence()
        }
        .onDisappear {
            animationTask?.cancel()
        }
        .onChange(of: activeStandings) { _, newStandings in
            // Jika data pemain lain baru masuk setelah animasi selesai atau sedang jalan:
            if isWinnerVisible {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    revealedRowCount = min(5, newStandings.count)
                }
            }
        }
    }
    
    private var dottedLine: some View {
        Text(String(repeating: "* ", count: 27).trimmingCharacters(in: .whitespaces))
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundStyle(receiptTextColor.opacity(0.75))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    private func startRevealSequence() {
        animationTask?.cancel()
        revealedRowCount = 0
        isWinnerVisible = false
        isBackToHomeVisible = false
        
        animationTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            
            let totalRows = displayedStandings.count
            if totalRows > 0 {
                for index in 1...totalRows {
                    guard !Task.isCancelled else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        revealedRowCount = index
                    }
                    rowImpact.impactOccurred()
                    try? await Task.sleep(nanoseconds: 450_000_000)
                }
            }
            
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                isWinnerVisible = true
            }
            winnerFeedback.notificationOccurred(.success)
            
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isBackToHomeVisible = true
            }
        }
    }
    
    private func skipAnimation() {
        animationTask?.cancel()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            revealedRowCount = displayedStandings.count
            isWinnerVisible = true
            isBackToHomeVisible = true
        }
    }
}

#Preview("Final Score Standings") {
    FinalScoreView(
        standings: [
            PlayerStandingModel(id: "1", name: "Bomboclat wallahi", income: 43, penalty: 0),
            PlayerStandingModel(id: "2", name: "emily", income: 45, penalty: 5),
            PlayerStandingModel(id: "3", name: "david", income: 39, penalty: 0),
            PlayerStandingModel(id: "4", name: "hannah", income: 41, penalty: 3),
            PlayerStandingModel(id: "5", name: "matheo", income: 31, penalty: 0)
        ]
    )
}

