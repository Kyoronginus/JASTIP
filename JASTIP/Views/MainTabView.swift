//
//  MainTabView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct MainTabView: View {
    @Bindable var viewModel: GameSessionViewModel
    @State private var activeToast: ToastOptions? = nil
    
    // State Drawer Phone
    @State private var isObjectiveExpanded: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    // ==========================================
    // ⚙️ PENGATURAN UKURAN & POSISI HP (RESIZE & REPOSITION)
    // ==========================================
    private let phoneWidth: CGFloat = UIScreen.main.bounds.width - 10
    private let phoneHeight: CGFloat = UIScreen.main.bounds.height * 0.90
    private let peekHeight: CGFloat = 120 // Tinggi bagian atas HP yang ngintip dari bawah
    
    var body: some View {
        // ZStack alignment .bottom otomatis membuat SEMUA elemen 100% CENTER secara horizontal
        ZStack(alignment: .bottom) {
            
            // 1. LAYER GAMEPLAY UTAMA (KOPER & MEJA) - Kembali Normal & Center
            GameView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 2. DIMMING BACKDROP (Hanya muncul saat HP terbuka)
            if isObjectiveExpanded {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isObjectiveExpanded = false
                        }
                    }
            }
            
            // 3. DRAWER HP KARTUN (Swipe-Up / Tap-to-Expand)
            VStack(spacing: 8) {
                // Teks "Tap to expand" di atas HP saat ngintip
                if !isObjectiveExpanded {
                    Text("Tap to expand")
                        .font(.plusJakarta(13, .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isObjectiveExpanded = true
                            }
                        }
                }
                
                // Wadah Badan HP
                ObjectivePhoneContainer(
                    viewModel: viewModel,
                    isExpanded: $isObjectiveExpanded,
                    onBack: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isObjectiveExpanded = false
                        }
                    }
                )
                .frame(width: phoneWidth, height: phoneHeight)
            }
            // Rumus posisi: saat collapsed turun sebanyak (phoneHeight - peekHeight)
            .offset(y: (isObjectiveExpanded ? 15 : (phoneHeight - peekHeight)) + dragOffset)
            // Gesture Drag / Swipe yang responsif
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if isObjectiveExpanded {
                            // Saat terbuka: hanya bisa ditarik ke bawah (menutup)
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        } else {
                            // Saat ngintip: hanya bisa ditarik ke atas (membuka)
                            if value.translation.height < 0 {
                                dragOffset = value.translation.height
                            }
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 60
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if isObjectiveExpanded {
                                if value.translation.height > threshold {
                                    isObjectiveExpanded = false
                                }
                            } else {
                                if -value.translation.height > threshold {
                                    isObjectiveExpanded = true
                                }
                            }
                            dragOffset = 0
                        }
                    }
            )
            
            // 4. EVENT ALERT POPUP & NOTIFIKASI BAWAAN
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toastNotification($viewModel.activeToast)
        .fullScreenCover(isPresented: $viewModel.isGameOver) {
            EndView(players: viewModel.leaderboardPlayers) {
                viewModel.resetToLobby()
            }
        }
    }
}

// MARK: - Container Phone Frame
struct ObjectivePhoneContainer: View {
    var viewModel: GameSessionViewModel
    @Binding var isExpanded: Bool
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Background dasar
            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(Color(red: 247/255, green: 244/255, blue: 235/255))
                .padding(7)
            
            // Konten ObjectiveView di dalam layar HP
            VStack(spacing: 0) {
                // Jarak atas agar konten tidak nabrak Dynamic Island frame
                Color.clear
                    .frame(height: 57)
                
                ObjectiveView(viewModel: viewModel)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            .contentShape(Rectangle())
            // Tap di kepala HP saat ngintip untuk membuka
            .onTapGesture {
                if !isExpanded {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
            }
            
            // Asset Frame HP Kartun di lapisan terdepan
            Image("PhoneFrame")
                .resizable()
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    MainTabView(viewModel: GameSessionViewModel())
}
