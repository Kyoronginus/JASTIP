//
//  StoryboardView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 08/11/26.
//

import SwiftUI
import AudioToolbox
import AVFoundation

struct StoryboardView: View {
    @Bindable var session: GameSessionViewModel
    var onFinish: () -> Void
    
    // State animasi PPT: langkah reveal saat ini (0..6)
    @State private var currentStep: Int = 0

    @State private var audioPlayer: AVAudioPlayer?
    
    // Suara & Haptik
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private var currentSheet: Int {
        if currentStep <= 2 {
            return 1
        } else if currentStep <= 4 {
            return 2
        } else {
            return 3
        }
    }
    
    var body: some View {
        ZStack {
            // Background Komik Hangat
            Color(red: 0.98, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            // Konten Lembar Sesuai Step
            Group {
                if currentSheet == 1 {
                    StoryboardSheet1View(step: currentStep)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else if currentSheet == 2 {
                    StoryboardSheet2View(step: currentStep)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    StoryboardSheet3View(
                        step: currentStep,
                        orders: session.sharedJastipOrders
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))

                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: currentSheet)
            
            // Overlay Navigasi (Tombol Skip & Indikator Halaman)
            VStack {
                HStack {
                    // Indikator Halaman Komik
                    HStack(spacing: 6) {
                        ForEach(1...3, id: \.self) { page in
                            Capsule()
                                .fill(currentSheet == page ? Color("TaxiYellow") : Color.black.opacity(0.15))
                                .frame(width: currentSheet == page ? 24 : 8, height: 6)
                                .animation(.easeInOut(duration: 0.25), value: currentSheet)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Tombol Skip
                    Button(action: onFinish) {
                        HStack(spacing: 4) {
                            Text("Skip")
                                .font(.spaceGrotesk(14, .bold))
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        cornerRadius: 12,
                        borderWidth: 1.5,
                        shadowOffset: 3,
                        paddingVertical: 8,
                        paddingHorizontal: 14
                    ))                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                Spacer()
                
                // Petunjuk Tap di Bawah
                Text(currentStep >= 5 ? "Tap untuk mulai berbelanja" : "Tap layar untuk melanjutkan")
                    .font(.spaceGrotesk(12, .medium))
                    .foregroundStyle(Color.secondary.opacity(0.7))
                    .padding(.bottom, 16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            advanceStep()
        }
        .onAppear {
            playStepSFX(step: 0)
        }
    }
    
    // MARK: - Step Advancement
    private func advanceStep() {
        if currentStep < 5 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep += 1
            }
            playStepSFX(step: currentStep)
        } else {
            // Selesai storyboard -> lanjut ke game
            onFinish()
        }
    }
    
    private func playStepSFX(step: Int) {
        impactFeedback.impactOccurred()
        
        switch step {
        case 0: // POST
//            AudioServicesPlaySystemSound(1104)  keyboard tap sound
            AudioManager.shared.play("panel 1.1 - post story.mp3")
        case 1: // ROLL..
//            AudioServicesPlaySystemSound(1105)
            AudioManager.shared.play("panel 1.2 - suitcase rolling.mp3")
        case 2: // Panel 3
//            AudioServicesPlaySystemSound(1104)
            AudioManager.shared.play("panel 1.3 - seatbelt click.mp3")
        case 3: // WOOOSH...
//            AudioServicesPlaySystemSound(1001) // swoosh sound
            AudioManager.shared.play("panel 2.1 - airplane swoosh.mp3")
        case 4: // STEP.. STEP..
//            AudioServicesPlaySystemSound(1104)
            AudioManager.shared.play("panel 2.2 - walking click clack.mp3")
            
        case 5: // PING!
//            AudioServicesPlaySystemSound(1003) // SMS notification chime
            // AudioManager.shared.play("panel 3 - notification ping.mp3")
            notificationFeedback.notificationOccurred(.success)
        case 6: // Cards reveal
            AudioServicesPlaySystemSound(1003)
            notificationFeedback.notificationOccurred(.success)
        default:
            break
        }
    }
}

// MARK: - Subview: Lembar 1 (Departure & Boarding - 3 Panels)
struct StoryboardSheet1View: View {
    let step: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 48)
            
            // Panel 1: Open Jastip di Lounge + SFX POP!
            ZStack(alignment: .topTrailing) {
                Image("panel_1")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Image("sfx_pop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110)
                    .offset(x: -60, y: 32)
                    .opacity(step >= 0 ? 1 : 0)
                    .scaleEffect(step >= 0 ? 1 : 0.6)
            }
            .opacity(step >= 0 ? 1 : 0)
            .scaleEffect(step >= 0 ? 1 : 0.94)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: step)
            
            // Panel 2: Jet Bridge & Koper + SFX KLAK KLAK..
            ZStack(alignment: .bottomLeading) {
                Image("panel_2")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Image("sfx_klak")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 155)
                    .offset(x: 10, y: 12)
                    .opacity(step >= 1 ? 1 : 0)
                    .scaleEffect(step >= 1 ? 1 : 0.6)
            }
            .opacity(step >= 1 ? 1 : 0)
            .scaleEffect(step >= 1 ? 1 : 0.94)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: step)
            
            // Panel 3: Duduk di Kabin Pesawat + SFX KLIK!
            ZStack(alignment: .topTrailing) {
                Image("panel_3")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Image("sfx_klik")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 115)
                    .offset(x: -30, y: 18)
                    .opacity(step >= 2 ? 1 : 0)
                    .scaleEffect(step >= 2 ? 1 : 0.6)
            }
            .opacity(step >= 2 ? 1 : 0)
            .scaleEffect(step >= 2 ? 1 : 0.94)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: step)
            
            Spacer().frame(height: 36)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Subview: Lembar 2 (Flight & Arrival - 2 Panels)
struct StoryboardSheet2View: View {
    let step: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 52)
            
            // Panel 4: Pesawat di Udara + SFX SWOOSH...
            ZStack(alignment: .topTrailing) {
                Image("panel_4")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Image("sfx_swoosh")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .offset(x: 2, y: 16)
                    .opacity(step >= 3 ? 1 : 0)
                    .scaleEffect(step >= 3 ? 1 : 0.6)
            }
            .opacity(step >= 3 ? 1 : 0)
            .scaleEffect(step >= 3 ? 1 : 0.94)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: step)
            
            // Panel 5: Keluar Gate Kedatangan + SFX TAP TAP
            ZStack(alignment: .bottomLeading) {
                Image("panel_5")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Image("sfx_tap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 145)
                    .offset(x: 6, y: 14)
                    .opacity(step >= 4 ? 1 : 0)
                    .scaleEffect(step >= 4 ? 1 : 0.6)
            }
            .opacity(step >= 4 ? 1 : 0)
            .scaleEffect(step >= 4 ? 1 : 0.94)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: step)
            
            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Subview: Lembar 3 (HP Besar & 3 Kartu Jastip)
struct StoryboardSheet3View: View {
    let step: Int
    let orders: [JastipOrderModel]

    @State private var visibleBubbleCount: Int = 0
    private let pingHaptic = UINotificationFeedbackGenerator()
    
    // Parameter layout kartu agar mudah disesuaikan
    var cardsTopOffset: CGFloat = 190
    var cardsHorizontalPadding: CGFloat = 20
    var bubbleScale: CGFloat = 0.38
    var cardsSpacing: CGFloat = -18
    
    var body: some View {
        ZStack {
            // Gambar Frame 3: HP Besar Layar Bersih
            Image("panel_6")
                .resizable()
//                .scaledToFit()
//                .frame(width: 580)
                .offset(x: -30, y: 0)
                .scaledToFill()
                .ignoresSafeArea()
            
            // Stiker PING! di atas HP
            // Overlay 3 JastipChatBubble di Layar HP
            if step >= 5 {
                VStack(alignment:.leading, spacing: cardsSpacing) {
                    Spacer().frame(height: cardsTopOffset)
                    
                    let targetOrders = Array(orders.prefix(3))
                    ForEach(0..<targetOrders.count, id: \.self) { index in
                        if index < visibleBubbleCount {
                            JastipChatBubble(order: targetOrders[index])
                                .scaleEffect(bubbleScale, anchor: .topLeading)
                                .frame(width: 10, height: 110) // Batasi slot tinggi vertikal setelah diskalakan
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                                    removal: .opacity
                                ))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, cardsHorizontalPadding)
                .offset(x: 100, y: 100)
            }
        }
        .task {
            // Tunggu 0.2 detik setelah transisi sheet 3 selesai
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            let total = min(3, orders.count)
            for i in 1...total {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    visibleBubbleCount = i
                }
                // Mainkan suara ping & haptic per bubble
                AudioManager.shared.play("panel 3 - notification ping.mp3")
                pingHaptic.notificationOccurred(.success)
                
                // Jeda 0.25 detik sebelum bubble berikutnya muncul
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
        }
    }
}

// MARK: - Subview: Item Kartu Jastip di Atas Layar HP
struct StoryboardOrderCardItemView: View {
    let order: JastipOrderModel
    
    // Warna avatar customer
    private var avatarColor: Color {
        let colors: [Color] = [.orange, .blue, .red, .green, .purple]
        let hash = abs(order.customerName.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Baris Atas: Avatar + Nama + Poin Badge
            HStack(spacing: 8) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(String(order.customerName.prefix(1)))
                            .font(.plusJakarta(12, .bold))
                            .foregroundStyle(.white)
                    )
                
                Text(order.customerName)
                    .font(.plusJakarta(13, .bold))
                    .foregroundStyle(Color("NavyBlack"))
                
                Spacer()
                
                Text("+\(order.points) PTS")
                    .font(.plusJakarta(10, .bold))
                    .foregroundStyle(Color("NavyBlack"))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color("TaxiYellow"))
                    .clipShape(Capsule())
            }
            
            // Pesan Chat
            Text(order.chatMessage)
                .font(.plusJakarta(12, .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            // Deskripsi Requirement
            HStack(spacing: 6) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
//                Text(order.requirementDescription)
//                    .font(.plusJakarta(10, .regular))
//                    .foregroundStyle(.secondary)
//                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Preview
#Preview("Storyboard Full Flow") {
    let session = GameSessionViewModel()
    return StoryboardView(session: session) {
        print("Finished Storyboard")
    }
}

#Preview("Frame 3 - Jastip Cards Placement") {
    let sampleOrders = Array(JastipOrderCatalog.allOrders.prefix(3))
    StoryboardSheet3View(
        step: 6,
        orders: sampleOrders,
        cardsTopOffset: 220,
        cardsHorizontalPadding: 48,
        cardsSpacing: 10
    )
}

