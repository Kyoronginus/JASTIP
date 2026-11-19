//
//  StoryboardView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 08/11/26.
//

import SwiftUI
import AVFoundation
import UIKit

struct StoryboardView: View {
    @Bindable var session: GameSessionViewModel
    var onFinish: () -> Void

    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            Color("BackgroundChat")
                .ignoresSafeArea()

            if let player {
                IntroVideoPlayerView(player: player)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()

                    Button(action: finishPlayback) {
                        HStack(spacing: 4) {
                            Text("Skip")
                                .font(.spaceGrotesk(14, .bold))
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        cornerRadius: 12,
                        yShadowOffset: 4,
                        paddingVertical: 8,
                        paddingHorizontal: 14
                    ))
                    .accessibilityLabel("Skip Intro Video")
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()
            }
        }
        .onAppear {
            startIntroPlayback()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }

    // MARK: - Playback Lifecycle

    private func startIntroPlayback() {
        guard player == nil else { return }

        guard let videoURL = Self.cachedIntroVideoURL() else {
            finishPlayback()
            return
        }

        let item = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.actionAtItemEnd = .pause

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                finishPlayback()
            }
        }

        player = newPlayer
        newPlayer.play()
    }

    private func finishPlayback() {
        guard !hasFinished else { return }
        hasFinished = true
        cleanupPlayer()
        onFinish()
    }

    private func cleanupPlayer() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        player?.pause()
        player = nil
    }

    private static func cachedIntroVideoURL() -> URL? {
        guard let asset = NSDataAsset(name: "intro-video") else { return nil }
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("jastip-intro-video.mp4")

        let existingSize = (try? tempURL.resourceValues(forKeys: [.fileSizeKey]).fileSize)
        if existingSize != asset.data.count {
            do {
                try asset.data.write(to: tempURL, options: .atomic)
            } catch {
                return nil
            }
        }
        return tempURL
    }
}

// MARK: - Transparent AVPlayerLayer Host

private struct IntroVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerContainerUIView {
        let view = PlayerContainerUIView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.playerLayer.backgroundColor = UIColor.clear.cgColor
        view.playerLayer.videoGravity = .resizeAspect
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerContainerUIView, context: Context) {
        if uiView.playerLayer.player !== player {
            uiView.playerLayer.player = player
        }
    }
}

private final class PlayerContainerUIView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        // Guaranteed by `layerClass` override above.
        layer as! AVPlayerLayer
    }
}

// MARK: - Preview

#Preview {
    StoryboardView(session: GameSessionViewModel()) {
        print("Intro finished!")
    }
}
