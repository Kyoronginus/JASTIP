//
//  GameView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 10/10/26.
//

import SwiftUI

struct GameView: View {
    var currentTime: String = "08.00"
    var onOpenCamera: () -> Void = {}
    var onNextHour: () -> Void = {}
    @State private var isShowingRevealedSheet: Bool = false
    
    var session: GameSessionViewModel = GameSessionViewModel()
    
    var dummy: AirlineCardModel = AirlineCardModel(
        id: "1",
        maxCapacityKg: 20,
        maxCarryOnKg: 7,
        departureTime: "15.00"
    )
    
    @State private var isShowingScanner = false
    @State private var isShowingRevealedWeights = false
    @State private var lastScannedPiece: PieceModel? = nil
    @State private var currentEvent: RandomEventModel? = nil // for DEBUG AlertView (reminder untuk dihapus)
    
    var body: some View {
        ZStack{
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            HStack {
                AirlineCard(data: dummy)
                Spacer()
                
                VStack(spacing: 12) {
                    Spacer()
                    Text("TIME: \(currentTime)")
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Button("SCAN QR") {
                        isShowingScanner = true
                        onOpenCamera()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                        
                    
                    Button("Next Hour", action: onNextHour)
                        .buttonStyle(PrimaryButtonStyle())
                    
                    Button("DAFTAR BOBOT") {
                        withAnimation {
                            isShowingRevealedWeights = true
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    
                    // TODO: Temporary Button - Hapus sebelum rilis
                    Button("TEST EVENT") {
                        currentEvent = RandomEventModel(
                            title: "Toko Buku Tutup!",
                            message: "Toko Buku sedang istirahat. Tidak ada item yang bisa diambil di jam ini."
                        )
                    }
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    
                    Button("OPEN SHAPES") {
                        isShowingRevealedSheet = true
                    }
                    .font(.caption2.bold())
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Spacer()
                    
                    Text("TIME: \(currentTime)")
                        .font(.title2.bold())
                        .rotationEffect(.degrees(180))
                    
                    Spacer()
                }
                
                Spacer()
                AirlineCard(data: dummy)
                    .rotationEffect(.degrees(180))
            }
            .padding(.horizontal, 24)
            .navigationBarBackButtonHidden(true)
            
            if let event = currentEvent {
                // Backdrop redup
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        currentEvent = nil
                    }
                
                EventAlertView(event: event) {
                    withAnimation {
                        currentEvent = nil
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            if isShowingRevealedWeights {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowingRevealedWeights = false
                        }
                    }
                
                RevealedPiecesListView(pieces: session.revealedPieces) {
                    withAnimation {
                        isShowingRevealedWeights = false
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentEvent != nil || isShowingRevealedWeights)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingRevealedSheet) {
               RevealedSheetsView()
                   .presentationDetents([.medium, .large])
           }
        .fullScreenCover(isPresented: $isShowingScanner) {
            QRScannerView(session: session) { piece, code, weight in
                lastScannedPiece = piece
                
                if let piece = piece, let weight = weight {
                    session.recordScannedPiece(piece, weight: weight)
                }
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
