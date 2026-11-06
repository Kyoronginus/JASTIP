//
//  Toast.swift
//  JASTIP
//
//  Created by Feivel Qutby on 06/11/26.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastOptions?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            // Pasang di TOP (atas) agar tidak menabrak TabBar dan Koper di bawah
            .overlay(alignment: .top) {
                if let toast = toast {
                    toastView(for: toast)
                        // Muncul turun dari atas dengan transisi halus
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 12) // Jarak manis dari Safe Area / Top Bar
                        .zIndex(999)
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: toast != nil)
            .onChange(of: toast != nil) { _, isShowing in
                if isShowing {
                    scheduleDismissal()
                }
            }
    }

    @ViewBuilder
    private func toastView(for options: ToastOptions) -> some View {
        HStack(spacing: 10) {
            // Icon Status
            Image(systemName: options.type.icon)
                .foregroundStyle(options.type.color)
                .font(.system(size: 16, weight: .bold))
            
            // Pesan Teks
            Text(options.message)
                .font(.plusJakarta(13, .semibold))
                .foregroundColor(Color("NavyBlack"))
                .lineLimit(2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(maxWidth: 340) // Batas lebar agar tetap proporsional di layar besar/kecil
        .background(Color.white)
        .clipShape(Capsule())
        // Border khas style game JASTIP
        .overlay(
            Capsule()
                .stroke(Color("NavyBlack").opacity(0.15), lineWidth: 1.5)
        )
        // Shadow halus agar pop-up melayang di atas konten
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private func scheduleDismissal() {
        guard let toast = toast else { return }
        workItem?.cancel()
        
        let task = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.toast = nil
            }
        }
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
    }
}

extension View {
    func toastNotification(_ toast: Binding<ToastOptions?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}

#Preview {
    struct ToastPreviewContainer: View {
        @State private var sampleToast: ToastOptions? = nil
        
        var body: some View {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Toast Preview Playground")
                        .font(.plusJakarta(18, .bold))
                        .padding(.bottom, 10)
                    
                    Button("Trigger Success Toast") {
                        sampleToast = ToastOptions(
                            message: "Barang berhasil masuk koper! 🎉",
                            type: .success
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Button("Trigger Error Toast") {
                        sampleToast = ToastOptions(
                            message: "Koper sudah melebihi kapasitas!",
                            type: .error
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                    Button("Trigger Info Toast") {
                        sampleToast = ToastOptions(
                            message: "Giliran pemain berikutnya telah dimulai.",
                            type: .info
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding()
            }
            .toastNotification($sampleToast)
        }
    }
    
    return ToastPreviewContainer()
}
