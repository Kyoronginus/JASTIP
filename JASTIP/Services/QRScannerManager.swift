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
    
    @ObservationIgnored private let sessionQueue = DispatchQueue(label: "camera.session.queue", qos: .userInitiated)
    @ObservationIgnored private let videoProcessingQueue = DispatchQueue(label: "camera.frame.processing", qos: .userInitiated)
    @ObservationIgnored private let videoOutput = AVCaptureVideoDataOutput()
    @ObservationIgnored private var isProcessing = false
    @ObservationIgnored private var lastScanTime = Date.distantPast
    
    @ObservationIgnored private var currentInput: AVCaptureDeviceInput?
    @ObservationIgnored private var frontInput: AVCaptureDeviceInput?
    @ObservationIgnored private var backInput: AVCaptureDeviceInput?
    var currentPosition: AVCaptureDevice.Position = .front
    private(set) var isSwitchingCamera = false

    
    override init() {
        super.init()
        sessionQueue.async { [weak self] in
            self?.setupCamera()
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        session.automaticallyConfiguresApplicationAudioSession = false
        if session.canSetSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        } else if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        }
        
        if let initialInput = cachedInput(for: .front), session.canAddInput(initialInput) {
            self.currentInput = initialInput
            session.addInput(initialInput)
            configureFocus(for: initialInput.device)
        }
        
        // Pre-warm opposite camera input off the main thread for faster flips.
        _ = cachedInput(for: .back)
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: videoProcessingQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            session.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video), connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            // Keep Vision buffer un-mirrored; preview layer handles selfie mirroring separately.
            connection.isVideoMirrored = false
        }
        
        session.commitConfiguration()
    }
    
    private func cachedInput(for position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        switch position {
        case .front:
            if let frontInput { return frontInput }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return nil
            }
            frontInput = input
            return input
        case .back:
            if let backInput { return backInput }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return nil
            }
            backInput = input
            return input
        default:
            return nil
        }
    }
    
    func flipCamera() {
        guard !isSwitchingCamera else { return }
        let newPosition: AVCaptureDevice.Position = (currentPosition == .front) ? .back : .front
        setCameraPosition(newPosition)
    }

    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        guard position != currentPosition, !isSwitchingCamera else { return }
        isSwitchingCamera = true

        sessionQueue.async { [weak self] in
            guard let self else { return }
            defer {
                DispatchQueue.main.async {
                    self.isSwitchingCamera = false
                }
            }

            guard let newInput = self.cachedInput(for: position) else { return }

            self.session.beginConfiguration()
            let previousInput = self.currentInput
            if let previousInput {
                self.session.removeInput(previousInput)
            }

            guard self.session.canAddInput(newInput) else {
                if let previousInput, self.session.canAddInput(previousInput) {
                    self.session.addInput(previousInput)
                }
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(newInput)
            self.currentInput = newInput
            self.configureFocus(for: newInput.device)

            if let connection = self.videoOutput.connection(with: .video), connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                // Keep Vision buffer un-mirrored on both cameras so QR decoding works reliably.
                connection.isVideoMirrored = false
            }

            self.session.commitConfiguration()

            DispatchQueue.main.async {
                self.currentPosition = position
            }
        }
    }

    private func configureFocus(for device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }
        } catch {
            // Device focus configuration is optional; scanning still proceeds with defaults.
        }
    }
    
    func startScanning() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
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
