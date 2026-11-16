//
//  QRScannerManager.swift
//  JASTIP
//
//  Created by Tohru Djunaedi Sato on 10/10/26.
//

import AVFoundation
import Vision

@Observable
class QRScannerManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var scannedCode: String?
    var onCodeDetected: ((String) -> Void)?
    
    let session = AVCaptureSession()
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private var isProcessing = false
    private var lastScanTime = Date.distantPast
    
    private var currentInput: AVCaptureDeviceInput?
    var currentPosition: AVCaptureDevice.Position = .front

    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        
        self.currentInput = input
        session.addInput(input)
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing"))
            videoOutput.alwaysDiscardsLateVideoFrames = true
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
    }
    
    func flipCamera() {
        let newPosition: AVCaptureDevice.Position = (currentPosition == .front) ? .back : .front
        setCameraPosition(newPosition)
    }

    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        guard position != currentPosition else { return }

        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        let previousInput = currentInput
        if let previousInput {
            session.removeInput(previousInput)
        }
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let newInput = try? AVCaptureDeviceInput(device: newDevice),
              session.canAddInput(newInput) else {
            if let previousInput {
                session.addInput(previousInput)
            }
            return
        }
        
        session.addInput(newInput)
        self.currentInput = newInput
        self.currentPosition = position
        
        if let connection = videoOutput.connection(with: .video), connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = (position == .front)
        }
    }
    
    func startScanning() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }
    }
    
    func stopScanning() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // debounce 1 sec
        guard Date().timeIntervalSince(lastScanTime) > 1.0 else { return }
        guard !isProcessing else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        isProcessing = true
        
        let request = VNDetectBarcodesRequest { [weak self] req, _ in
            defer { self?.isProcessing = false }
            
            guard let results = req.results as? [VNBarcodeObservation] else { return }
            
            for barcode in results {
                guard let payload = barcode.payloadStringValue,
                      payload.hasPrefix("JASTIP") else { continue }
                
                self?.lastScanTime = Date()
                DispatchQueue.main.async {
                    self?.scannedCode = payload
                    self?.onCodeDetected?(payload)
                }
                break
            }
        }
        
        request.symbologies = [.microQR, .qr, .code39]
        
//        request.regionOfInterest = CGRect(x: 0.375, y: 0.25, width: 0.25, height: 0.5)'
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
}
