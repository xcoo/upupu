//
//  CameraHelper.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation
import AVFoundation
import ImageIO

enum CameraPosition {
    case Front
    case Back
}

class CameraHelper: NSObject {

    static let kCameraHelperCaptureRequestKey = "isCaptured"

    static var sharedInstance = CameraHelper()

    private(set) var capturedImage: UIImage?
    var isCaptured = false

    var cameraPosition: CameraPosition {
        guard let videoInput = videoInput else {
            return .Back
        }
        return sideWithCaptureDevice(videoInput)
    }

    var torch: Bool {
        get {
            guard let device = videoInput?.device else {
                return false
            }
            return torchWithCaptureDevice(device)
        }

        set(enable) {
            guard let device = videoInput?.device else {
                return
            }
            if availableTorch() {
                setTorch(enable, withCaptureDevice: device)
            }
        }
    }

    var focus: CGPoint {
        get {
            guard let device = videoInput?.device else {
                return CGPoint.zero
            }
            if CameraHelper.support() {
                return focusWithCaptureDevice(device)
            }
            return CGPoint.zero
        }

        set(newFocus) {
            guard let device = videoInput?.device else {
                return
            }
            if CameraHelper.support() {
                setFocus(newFocus, withCaptureDevice: device)
            }
        }
    }

    private var session: AVCaptureSession?
    private var videoInput: AVCaptureDeviceInput?
    private var captureStillImageOutput: AVCaptureStillImageOutput!

    class func support() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    class func supportFrontCamera() -> Bool {
        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] {
            return !devices.map({ $0.position }).filter({ $0 == .Front }).isEmpty
        }
        return false
    }

    class func supportTorch() -> Bool {
        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] {
            return !devices.filter({ $0.hasTorch }).isEmpty
        }
        return false
    }

    override init () {
        super.init()
        if CameraHelper.support() {
            self.initialize()
        }
    }

    private func initialize() {
        session = AVCaptureSession()

        guard let session_ = session else {
            return
        }

        if session_.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
            session_.sessionPreset = AVCaptureSessionPresetPhoto
        }

        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if videoDevice == nil {
            session = nil
            print("Could not create video capture device")
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session_.canAddInput(videoInput) {
                session_.addInput(videoInput)
            }
            self.videoInput = videoInput
        } catch _ {
            print("Could not create video input")
        }

        captureStillImageOutput = AVCaptureStillImageOutput()
        captureStillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

        session_.addOutput(captureStillImageOutput)

        isCaptured = true

        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(deviceOrientationDidChange),
                                                         name: UIDeviceOrientationDidChangeNotification,
                                                         object: nil)
    }

    func previewView(bounds: CGRect) -> UIView {
        return previewLayer(bounds, session: session)
    }

    private func previewLayer(bounds: CGRect, session: AVCaptureSession?) -> UIView {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        let view = UIView(frame: bounds)
        view.layer.addSublayer(previewLayer)

        return view
    }

    // MARK: - Control

    func startRunning() {
        session?.startRunning()
    }

    func stopRunning() {
        session?.stopRunning()
    }

    func capture() {
        guard session != nil && isCaptured else {
            return
        }

        isCaptured = false
        capturedImage = nil

        var videoConnection: AVCaptureConnection?
        if let connections = captureStillImageOutput.connections as? [AVCaptureConnection] {
            for con in connections {
                for p in con.inputPorts {
                    if p.mediaType == AVMediaTypeVideo {
                        videoConnection = con
                        break
                    }
                }
                if videoConnection != nil {
                    break
                }
            }
        }

        captureStillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
            [weak self] (imageSampleBuffer, error) in
            guard let imageSampleBuffer = imageSampleBuffer else {
                return
            }

            let exifAttachment = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary,
                                                 nil)
            if exifAttachment != nil {
                print("Attachment: \(exifAttachment)")
            } else {
                print("No attachment")
            }

            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            let image = UIImage(data: imageData)
            self?.capturedImage = image

            self?.setValue(true, forKey: CameraHelper.kCameraHelperCaptureRequestKey)
        }
    }

    private func sideWithCaptureDevice(videoInput: AVCaptureDeviceInput) -> CameraPosition {
        let isBackCamera = videoInput.device.position == .Back
        return isBackCamera ? CameraPosition.Back : CameraPosition.Front
    }

    private func switchSideWithCaptureDeviceInput(currentVideoInput: AVCaptureDeviceInput,
                                                  captureSession session: AVCaptureSession) -> AVCaptureDeviceInput? {
        guard CameraHelper.supportFrontCamera() else {
            return nil
        }

        var newVideoInput: AVCaptureDeviceInput?

        let isBackCamera = currentVideoInput.device.position == .Back

        session.stopRunning()
        session.removeInput(currentVideoInput)

        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] {
            for device in devices {
                if device.hasMediaType(AVMediaTypeVideo) {
                    if isBackCamera {
                        if device.position == .Front {
                            do {
                                try newVideoInput = AVCaptureDeviceInput(device: device)
                                break
                            } catch {}
                        }
                    } else {
                        if device.position == .Back {
                            do {
                                try newVideoInput = AVCaptureDeviceInput(device: device)
                                break
                            } catch {}
                        }
                    }
                }
            }
        }

        if newVideoInput != nil {
            session.addInput(newVideoInput)
            session.startRunning()
        } else {
            print("Failed to switch camera")
        }

        return newVideoInput
    }

    private func torchWithCaptureDevice(device: AVCaptureDevice) -> Bool {
        if device.hasTorch {
            return device.torchMode == .On
        }
        return false
    }

    private func setTorch(enable: Bool, withCaptureDevice device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if enable {
                device.torchMode = .On
            } else {
                device.torchMode = .Off
            }
            device.unlockForConfiguration()
        } catch {}
    }

    private func focusWithCaptureDevice(device: AVCaptureDevice) -> CGPoint {
        if device.focusPointOfInterestSupported {
            return device.focusPointOfInterest
        }
        return CGPoint.zero
    }

    private func setFocus(pointOfInterest: CGPoint, withCaptureDevice device: AVCaptureDevice) {
        if device.focusPointOfInterestSupported && device.isFocusModeSupported(.AutoFocus) {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = pointOfInterest
                device.focusMode = .AutoFocus
                device.unlockForConfiguration()
            } catch {}
        }
    }

    func switchCamera() {
        guard let videoInput = videoInput, session = session else {
            return
        }

        self.videoInput = switchSideWithCaptureDeviceInput(videoInput, captureSession: session)
    }

    func availableTorch() -> Bool {
        if let videoInput = videoInput {
            return videoInput.device.hasTorch
        }
        return false
    }

    // MARK: - Key value observation

    override class func automaticallyNotifiesObserversForKey(key: String) -> Bool {
        if key == CameraHelper.kCameraHelperCaptureRequestKey {
            return true
        }
        return super.automaticallyNotifiesObserversForKey(key)
    }

    // MARK: - Orientation

    @objc private func deviceOrientationDidChange() {
        guard let session = session else {
            return
        }

        let orientation: AVCaptureVideoOrientation
        switch UIDevice.currentDevice().orientation {
        case .Portrait:
            orientation = .Portrait
        case .PortraitUpsideDown:
            orientation = .PortraitUpsideDown
        case .LandscapeLeft:
            orientation = .LandscapeRight
        case .LandscapeRight:
            orientation = .LandscapeLeft
        default:
            orientation = .Portrait
        }

        session.beginConfiguration()

        var videoConnection: AVCaptureConnection?
        if let connections = captureStillImageOutput.connections as? [AVCaptureConnection] {
            for con in connections {
                if let inputPorts = con.inputPorts as? [AVCaptureInputPort] {
                    for p in inputPorts {
                        if p.mediaType == AVMediaTypeVideo {
                            videoConnection = con
                        }
                    }
                }
            }
        }

        if let videoConnection = videoConnection {
            if videoConnection.supportsVideoOrientation {
                videoConnection.videoOrientation = orientation
            }
        }

        session.commitConfiguration()
    }

}
