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
    var cameraPosition: AVCaptureDevice.Position = .front
    
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
    
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var coordinatedDeviceID: String?

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
        updateOrientation()
    }
    
    func updateOrientation() {
        guard let connection = videoPreviewLayer.connection else { return }
        
        // Use AVFoundation's native mirroring logic
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = true
        }
        
        // Update rotation angle for the current active device
        if let device = (videoPreviewLayer.session?.inputs.first as? AVCaptureDeviceInput)?.device {
            if coordinatedDeviceID != device.uniqueID || rotationCoordinator == nil {
                rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: videoPreviewLayer)
                coordinatedDeviceID = device.uniqueID
            }
            if let angle = rotationCoordinator?.videoRotationAngleForHorizonLevelPreview,
               connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        }
    }
}
