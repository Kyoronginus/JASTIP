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
    var currentPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Focus & Zoom State
    var isManualFocus: Bool = false
    var lensPosition: Float = 0.15
    var zoomMultiplier: CGFloat = 1.5
    var supportsManualFocus: Bool = false
    private var baseOpticalZoomFactor: CGFloat = 1.0

    override init() {
        super.init()
        setupCamera()
    }
    
    private func bestDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if position == .back {
            // Prioritaskan virtual camera agar iPhone dengan lensa Ultra-Wide otomatis masuk mode Macro saat didekatkan
            let deviceTypes: [AVCaptureDevice.DeviceType] = [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ]
            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTypes,
                mediaType: .video,
                position: .back
            )
            if let device = discovery.devices.first {
                return device
            }
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
    
    private func configureDeviceForSmallBarcode(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            // Hitung faktor zoom yang setara 1x lensa utama (pada virtual camera dengan ultra-wide, 1.0 adalah 0.5x dan switch-over pertama adalah 1x)
            if device.isVirtualDevice,
               let firstConstituent = device.constituentDevices.first,
               firstConstituent.deviceType == .builtInUltraWideCamera,
               let firstSwitchOver = device.virtualDeviceSwitchOverVideoZoomFactors.first {
                baseOpticalZoomFactor = CGFloat(truncating: firstSwitchOver)
            } else {
                baseOpticalZoomFactor = 1.0
            }
            
            supportsManualFocus = device.isLockingFocusWithCustomLensPositionSupported
            isManualFocus = false
            
            // Fokus & eksposur dipusatkan ke tengah kotak viewfinder (0.5, 0.5)
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = true
            
            // Terapkan zoom default (1.5x dari lensa utama) untuk kartu dengan barcode kecil
            let targetZoom = baseOpticalZoomFactor * zoomMultiplier
            let clampedZoom = max(device.minAvailableVideoZoomFactor, min(targetZoom, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = clampedZoom
        } catch {
            // Abaikan jika gagal lock configuration
        }
    }
    
    func setZoom(multiplier: CGFloat) {
        zoomMultiplier = multiplier
        guard let device = currentInput?.device else { return }
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            let targetZoom = baseOpticalZoomFactor * multiplier
            let clampedZoom = max(device.minAvailableVideoZoomFactor, min(targetZoom, min(device.activeFormat.videoMaxZoomFactor, baseOpticalZoomFactor * 4.0)))
            device.videoZoomFactor = clampedZoom
        } catch {}
    }
    
    func setAutoFocus() {
        isManualFocus = false
        guard let device = currentInput?.device else { return }
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            } else if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
        } catch {}
    }
    
    func setManualFocus(position: Float) {
        let clamped = max(0.0, min(1.0, position))
        lensPosition = clamped
        guard let device = currentInput?.device,
              device.isLockingFocusWithCustomLensPositionSupported else { return }
        isManualFocus = true
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.setFocusModeLocked(lensPosition: clamped, completionHandler: nil)
        } catch {}
    }
    
    func refocusCenter() {
        if isManualFocus {
            setManualFocus(position: lensPosition)
        } else {
            setAutoFocus()
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        if session.canSetSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        }
        
        guard let device = bestDevice(for: currentPosition),
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
        configureDeviceForSmallBarcode(device)
    }
    
    func flipCamera() {
        session.beginConfiguration()
        
        // Lepas input lama
        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }
        
        // Tentukan posisi baru
        let newPosition: AVCaptureDevice.Position = (currentPosition == .front) ? .back : .front
        
        guard let newDevice = bestDevice(for: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice),
              session.canAddInput(newInput) else {
            // Jika gagal, pasang kembali input lama
            if let currentInput = currentInput {
                session.addInput(currentInput)
            }
            session.commitConfiguration()
            return
        }
        
        session.addInput(newInput)
        self.currentInput = newInput
        self.currentPosition = newPosition
        
        if let connection = videoOutput.connection(with: .video), connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = (newPosition == .front)
        }
        
        session.commitConfiguration()
        configureDeviceForSmallBarcode(newDevice)
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
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
}
