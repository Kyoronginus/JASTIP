//
//  Toast.swift
//  JASTIP
//
//  Created by Feivel Qutby on 06/11/26.
//

import SwiftUI
import AudioToolbox

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
                        .padding(.top, 150) // Jarak manis dari Safe Area / Top Bar
                        .zIndex(999)
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: toast != nil)
            .onChange(of: toast?.id) { _, toastID in
                if toastID != nil {
                    scheduleDismissal()
                    if toast?.playsNotificationSound == true {
                        AudioServicesPlaySystemSound(1003)
                    }
                }
            }
    }

    @ViewBuilder
    private func toastView(for options: ToastOptions) -> some View {
        ZStack{
            Image("toastback")
                .resizable()
                .scaledToFit()
            HStack(spacing: 10) {
                // Icon Status
                Image("telp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)

                // Pesan Teks
                Text(options.message)
                    .font(.shantellSans(16, .regular))
                    .foregroundColor(.black)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(maxWidth: 420) // Batas lebar agar tetap proporsional di layar besar/kecil
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
                Color(uiColor: .gray)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Toast Preview Playground")
                        .font(.plusJakarta(18, .bold))
                        .padding(.bottom, 10)
                    
                    Button("Trigger Success Toast") {
                        sampleToast = ToastOptions(
                            message: "Donny just took a new personal order!",
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
