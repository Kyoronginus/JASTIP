//
//  CameraPreviewView.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewUIView {
        let view = VideoPreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
        uiView.updateOrientation()
    }
}

class VideoPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
        updateOrientation()
    }
    
    func updateOrientation() {
        guard let connection = videoPreviewLayer.connection else { return }
        
        let orientation: UIInterfaceOrientation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            orientation = windowScene.effectiveGeometry.interfaceOrientation
        } else {
            orientation = .landscapeRight
        }
        
        let targetAngle: CGFloat
        switch orientation {
        case .landscapeRight:
            targetAngle = 0.0
        case .landscapeLeft:
            targetAngle = 180.0
        case .portraitUpsideDown:
            targetAngle = 270.0
        case .portrait, .unknown:
            fallthrough
        @unknown default:
            targetAngle = 90.0
        }
        
        if connection.isVideoRotationAngleSupported(targetAngle) {
            connection.videoRotationAngle = targetAngle
        }
    }
}
