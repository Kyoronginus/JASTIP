//
//  HowToSheets.swift
//  JASTIP
//
//  Created by Feivel Qutby on 21/10/26.
//

import SwiftUI

enum HowToPlayTab: String, CaseIterable, Identifiable {
    case actions = "Actions"
    case packing = "Packing"
    case refill = "Refill & Round"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .actions: return "bag.fill"
        case .packing: return "suitcase.rolling.fill"
        case .refill: return "arrow.triangle.2.circlepath"
        }
    }
}

struct HowToSheets: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: HowToPlayTab = .actions
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Segmented Picker Tab
                Picker("Category: ", selection: $selectedTab) {
                    ForEach(HowToPlayTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .actions:
                            actionsSection
                        case .packing:
                            packingSection
                        case .refill:
                            refillSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - 2. Pilihan Aksi (Up to 2 Actions)
    private var actionsSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Player choose actions (up to 2):")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            ruleCard(
                badge: "Action 1",
                title: "Go to a Store",
                icon: "figure.walk",
                description: "Move the meeple to one of the destination shops."
            )
            
            ruleCard(
                badge: "Action 2",
                title: "Pick 1 Item from Store",
                icon: "hand.raised.fill",
                description: "Take 1 item from the store into your hand.\n\nA player can hold a maximum of **2 items** before placing them into the suitcase."
            )
            
            ruleCard(
                badge: "Action 3",
                title: "Replace Item from Store",
                icon: "arrow.left.arrow.right",
                description: "Exchange the item you have in hand for an item in the store.\n\nExchanges can only be made in-store for the **same type**."
            )
            
            ruleCard(
                badge: "Action 4",
                title: "Take JASTIP Card",
                icon: "creditcard.fill",
                description: "Pick up personal (JASTIP) cards. \n\n1. Player draws the top 3 cards from the deck. \n2. Player may choose to keep 1, 2, or 3 cards. \n3. Discarded cards are placed at the bottom of the deck"
            )
        }
    }
    
    // MARK: - 3. Decide Phase
    private var packingSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Once the action Is complete, Decide:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            ruleCard(
                badge: "Option A",
                title: "Board Plane",
                icon: "airplane",
                description: "Player decides to stop shopping and heads straight to board the plane."
            )
            
            ruleCard(
                badge: "Option B",
                title: "Put Items into Luggages",
                icon: "qrcode.viewfinder",
                description: "Place the items from your hand into the luggages.:\n\n1. Scan items using a **QR Code** or **NFC** within the app. \n2. Choose to place them into your **Suitcase** or **Carry-On**. \n\n**Important Rule:** Once items are placed inside your luggage, you may rearrange their positions on the grid, but they **CANNOT** be moved back to your hand!"
            )
            
            ruleCard(
                badge: "Option C",
                title: "Do Nothing",
                icon: "chevron.forward.2",
                description: "Skip"
            )
        }
    }
    
    // MARK: - 4. Refill Toko & Next Round
    private var refillSection: some View {
        VStack(spacing: 14) {
            ruleCard(
                badge: "End of round",
                title: "Refill Shops",
                icon: "cart.badge.plus",
                description: "Once all players have completed their turns, restock the items in the shops:\n\n• **Shops that were interacted with** (items taken or exchanged): \nRestock until there are **at most 3 items**.\n\n• **Shops that were not touched at all**: \nAdd **1 new item**."
            )
            
            ruleCard(
                badge: "NEXT HOUR",
                title: "Host Press 'Next Hour' Button",
                icon: "clock.arrow.circlepath",
                description: "Host menekan tombol **Next Hour** di aplikasi untuk memajukan waktu 1 jam."
            )
            
            ruleCard(
                badge: "RANDOM EVENTS",
                title: "Random Event Instructions",
                icon: "exclamationmark.triangle.fill",
                description: "If a Random Event appears on the app screen at the start of a new hour, all players **must follow the event instructions** before the next shopping turn begins.."
            )
        }
    }
    
    // MARK: - Helper UI Card
    @ViewBuilder
    private func ruleCard(badge: String, title: String, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(badge)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.gray.opacity(0.15))
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.gray)
            }
            
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(.primary)
            
            Text(.init(description))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview("Light") {
    HowToSheets()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HowToSheets()
        .preferredColorScheme(.dark)
}
