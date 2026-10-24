//
//  AirlineCardView.swift
//  JASTIP
//
//  Created by Denzel Malik Ibrahim on 24/10/26.
//

import SwiftUI

struct AirlineCardView: View {
    let airlineCard: AirlineCardModel
    var onProceedToGame: () -> Void = {}

    // State untuk Animasi 3D Flip
    @State private var isFlipped: Bool = false
    @State private var rotationDegrees: Double = 0
    @State private var showButton: Bool = false

    // Hitung total ronde (Boarding Hour - Jam 8 pagi)
    private var totalRounds: Int {
        let clean = airlineCard.departureTime.replacingOccurrences(of: ".", with: ":")
        let hour = Int(clean.split(separator: ":").first ?? "15") ?? 15
        return max(hour - 8, 1)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // MARK: - KARTU 3D FLIP CONTAINER
            ZStack {
                if !isFlipped {
                    // SISI BELAKANG (Back Card)
                    cardBackView
                } else {
                    // SISI DEPAN (Front Ticket Card)
                    cardFrontView
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // agar tidak terbalik secara horizontal
                }
            }
            .rotation3DEffect(
                .degrees(rotationDegrees),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )

            Spacer()

            // MARK: - TOMBOL PROCEED TO GAME
            Button("Proceed to Game") {
                onProceedToGame()
            }
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .padding(.horizontal, 24)
            .opacity(showButton ? 1 : 0) // Fade in setelah kartu nge-flip
            .animation(.easeInOut(duration: 0.3), value: showButton)
        }
        .padding(.vertical, 20)
        .appBackground()
        .onAppear {
            // Mulai animasi flip setelah 0.4 detik
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                    rotationDegrees = 180
                }
                // Ganti ke sisi depan tepat saat kartu vertikal (90 derajat)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isFlipped = true
                }
                // Tampilkan tombol setelah flip selesai
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showButton = true
                }
            }
        }
    }

    // MARK: - SISI BELAKANG KARTU
    private var cardBackView: some View {
        Image("AirlineCardBack")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 350)
            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    // MARK: - SISI DEPAN KARTU (TIKET)
    private var cardFrontView: some View {
        ZStack {
            // 1. Gambar Asli sebagai Frame Tiket (sudah ada border, lekukan sobekan, & garis putus-putus)
            Image("AirlineCardBack")
                .resizable()
                .scaledToFit()
            // 2. Konten Tiket di Atasnya
            VStack(spacing: 0) {
                // Header (Maskapai & Rute)
                ticketHeaderView
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                // Jarak transparan agar pas di atas garis putus-putus bawaan gambar
                Spacer()
                    .frame(height: 28)
                // 3 Blok Detail Tiket
                VStack(spacing: 12) {
                    // Blok 1: Boarding Time
                    AirlineDetailBlock(
                        icon: "clock.fill",
                        title: "BOARDING TIME",
                        subtitle: "Game Length:\n\(totalRounds) Rounds",
                        value: airlineCard.departureTime,
                        backgroundColor: Color("TaxiYellow"),
                        foregroundColor: Color("PassportBlue"),
                        watermarkImageName: "WatermarkYellow"
                    )
                    // Blok 2: Max Baggage
                    AirlineDetailBlock(
                        icon: "suitcase.fill",
                        title: "MAX BAGGAGE",
                        subtitle: "Suitcase:\n15 Slots (5x3)",
                        value: "\(airlineCard.maxCapacityKg)",
                        unit: "KG",
                        backgroundColor: Color("PassportBlue"),
                        foregroundColor: Color("PassportBlue150"),
                        watermarkImageName: "WatermarkBlue"
                    )
                    // Blok 3: Max Carry-On
                    AirlineDetailBlock(
                        icon: "bag.fill",
                        title: "MAX CARRY-ON",
                        subtitle: "Carry-on:\n4 Slots (2x2)",
                        value: "\(airlineCard.maxCarryOnKg)",
                        unit: "KG",
                        backgroundColor: Color("TransitTangerine"),
                        foregroundColor: Color(red: 0xF4 / 255.0, green: 0xCF / 255.0, blue: 0xE0 / 255.0),
                        watermarkImageName: "WatermarkOrange"
                    )
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
            }
        }
        .frame(maxWidth: 350)
        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
    }

    // MARK: - SUBVIEW: HEADER TIKET
    private var ticketHeaderView: some View {
        VStack(spacing: 12) {
            // Logo & Nama Maskapai
            HStack(spacing: 10) {
                // Logo Pesawat Kotak Biru
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0x1A / 255.0, green: 0x5E / 255.0, blue: 0xD8 / 255.0))
                        .frame(width: 32, height: 32)
                    Image(systemName: "airplane.up.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0xBE / 255.0, green: 0xFF / 255.0, blue: 0xFF / 255.0))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(airlineCard.airlineName.uppercased())
                        .font(.spaceGrotesk(20, .bold))
                        .foregroundStyle(Color(red: 0x0F / 255.0, green: 0x17 / 255.0, blue: 0x2A / 255.0))

                    Text("AIRLINE CARD #\(airlineCard.id.prefix(3))")
                        .font(.plusJakarta(9, .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // Route: SIN -> CGK
            ZStack {
                // 1. Ikon Pesawat (Terkunci 100% Dead Center)
                Image(systemName: "airplane")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(Color(red: 0x1A / 255.0, green: 0x5E / 255.0, blue: 0xD8 / 255.0))
                // 2. Kota Kiri dan Kota Kanan
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SINGAPORE")
                            .font(.plusJakarta(10, .bold))
                            .foregroundStyle(.secondary)
                        Text("SIN")
                            .font(.spaceGrotesk(32, .bold))
                            .foregroundStyle(Color("PassportBlue850"))
                    }
                    Spacer() // Cuma butuh 1 Spacer untuk memisahkan kiri dan kanan
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("JAKARTA")
                            .font(.plusJakarta(10, .bold))
                            .foregroundStyle(.secondary)
                        Text("CGK")
                            .font(.spaceGrotesk(32, .bold))
                            .foregroundStyle(Color("PassportBlue850"))
                    }
                }
            }
        }
    }

    // MARK: - SUBVIEW: GARIS PERFORASI TIKET
    private var ticketPerforationView: some View {
        HStack(spacing: 0) {
            // Lekukan setengah lingkaran kiri
            Circle()
                .fill(Color.clear)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color("PassportBlue850").opacity(0.25), lineWidth: 1.5)
                )
                .offset(x: -10)

            // Garis Putus-Putus
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                .foregroundStyle(Color.gray.opacity(0.35))
                .frame(height: 1)

            // Lekukan setengah lingkaran kanan
            Circle()
                .fill(Color.clear)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color("PassportBlue850").opacity(0.25), lineWidth: 1.5)
                )
                .offset(x: 10)
        }
        .frame(height: 20)
        .clipped()
    }
}

// Helper Garis Horizontal
private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

#Preview {
    AirlineCardView(
        airlineCard: AirlineCardCatalog.allCards[2],
        onProceedToGame: {}
    )
}
