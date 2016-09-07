//
//  CameraHelper.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit
import AVFoundation
import ImageIO

enum CameraPosition {
    case Front
    case Back
}

class CameraHelper {

    static var sharedInstance = CameraHelper()

    static var cameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    static var frontCameraAvailable: Bool {
        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            as? [AVCaptureDevice] {
            return !devices.map({ $0.position }).filter({ $0 == .Front }).isEmpty
        }
        return false
    }

    static var torchAvailable: Bool {
        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            as? [AVCaptureDevice] {
            return !devices.filter({ $0.hasTorch }).isEmpty
        }
        return false
    }

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
            if torchAvailable {
                setTorch(enable, withCaptureDevice: device)
            }
        }
    }

    var torchAvailable: Bool {
        if let videoInput = videoInput {
            return videoInput.device.hasTorch
        }
        return false
    }

    var focus: CGPoint {
        get {
            guard let device = videoInput?.device else {
                return CGPoint.zero
            }
            if CameraHelper.cameraAvailable {
                return focusWithCaptureDevice(device)
            }
            return CGPoint.zero
        }

        set(newFocus) {
            guard let device = videoInput?.device else {
                return
            }
            if CameraHelper.cameraAvailable {
                setFocus(newFocus, withCaptureDevice: device)
            }
        }
    }

    private var session: AVCaptureSession?
    private var videoInput: AVCaptureDeviceInput?
    private var captureStillImageOutput: AVCaptureStillImageOutput!

    private init () {
        if CameraHelper.cameraAvailable {
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
        captureStillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

        session_.addOutput(captureStillImageOutput)

        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(deviceOrientationDidChange),
                         name: UIDeviceOrientationDidChangeNotification, object: nil)
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

    func capture(completion: ((image: UIImage?, error: NSError?) -> Void)?) {
        captureStillImageOutput.captureStillImageAsynchronouslyFromConnection(
            captureStillImageOutput.connectionWithMediaType(AVMediaTypeVideo)) {
                (sampleBuffer, error) in
                guard let sampleBuffer = sampleBuffer else {
                    completion?(image: nil, error: error)
                    return
                }

                let exifAttachment =
                    CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, nil)
                if exifAttachment != nil {
                    print("Attachment: \(exifAttachment)")
                } else {
                    print("No attachment")
                }

                let imageData =
                    AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: imageData)
                completion?(image: image, error: nil)
        }
    }

    private func sideWithCaptureDevice(videoInput: AVCaptureDeviceInput) -> CameraPosition {
        let isBackCamera = videoInput.device.position == .Back
        return isBackCamera ? CameraPosition.Back : CameraPosition.Front
    }

    private func sideSwitchedInput(currentVideoInput: AVCaptureDeviceInput,
                                   captureSession session: AVCaptureSession)
        -> AVCaptureDeviceInput? {
            guard CameraHelper.frontCameraAvailable else {
                return nil
            }

            var newVideoInput: AVCaptureDeviceInput?

            session.stopRunning()
            session.removeInput(currentVideoInput)

            if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                as? [AVCaptureDevice] {
                for device in devices {
                    if device.hasMediaType(AVMediaTypeVideo) {
                        if currentVideoInput.device.position == .Back {
                            if device.position == .Front {
                                do {
                                    try newVideoInput = AVCaptureDeviceInput(device: device)
                                    break
                                } catch {
                                    print("Failed to create input")
                                }
                            }
                        } else {
                            if device.position == .Back {
                                do {
                                    try newVideoInput = AVCaptureDeviceInput(device: device)
                                    break
                                } catch {
                                    print("Failed to create input")
                                }
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

        self.videoInput = sideSwitchedInput(videoInput, captureSession: session)
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
            orientation = .Portrait
        case .LandscapeLeft:
            orientation = .LandscapeRight
        case .LandscapeRight:
            orientation = .LandscapeLeft
        default:
            orientation = .Portrait
        }

        session.beginConfiguration()

        if let connection = captureStillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            if connection.supportsVideoOrientation {
                connection.videoOrientation = orientation
            }
        }

        session.commitConfiguration()
    }

}
