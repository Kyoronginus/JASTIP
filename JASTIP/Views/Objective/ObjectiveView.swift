//
//  ObjectiveView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct ObjectiveView: View {
    @State private var orders: [JastipOrderModel] = JastipOrderCatalog.getRandomSharedOrders(count: 3)
    
    var body: some View {
        // Wrap everything in a main vertical stack
        VStack(spacing: 0) {
            // 1. Anchored Header (Completely outside the ScrollView)
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jastip Meepolis 🚩")
                        .font(.spaceGrotesk(16, .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Thomas, Toyib, Quincy, Henry, Molly...")
                        .font(.plusJakarta(12, .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .overlay(
                Divider(), alignment: .bottom
            )
            
            // 2. Scrollable Chat Content
            ScrollView {
                VStack(spacing: 12) {
                    Text("TODAY")
                        .font(.plusJakarta(11, .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(Capsule())
                        .padding(.vertical, 8)
                    
                    ForEach(orders) { order in
                        JastipChatBubble(order: order)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 3. Text field
            HStack(spacing: 12) {
                Text("any1 else need anything?")
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading) // Spans full width like a text field
                    .frame(minHeight: 34) // Standard iOS system text field height
                    .background(Color(.systemBackground)) // Adapts to Light/Dark mode
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                    .overlay{
                        HStack{
                            Spacer()
                            Button {
                                print("button tapped!")
                            } label: {
                                Text("Request more order")
                                    .font(.caption)
                                    .padding(5)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
        }
        .appBackground()
    }
}

#Preview {
    ObjectiveView()
}
