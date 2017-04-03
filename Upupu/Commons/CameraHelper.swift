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
    case front
    case back
}

class CameraHelper {

    static var shared = CameraHelper()

    static var cameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    static var frontCameraAvailable: Bool {
        if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            as? [AVCaptureDevice] {
            return !devices.map({ $0.position }).filter({ $0 == .front }).isEmpty
        }
        return false
    }

    static var torchAvailable: Bool {
        if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            as? [AVCaptureDevice] {
            return !devices.filter({ $0.hasTorch }).isEmpty
        }
        return false
    }

    static var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }

    static func requestAccess(_ completion: ((Bool) -> Void)!) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: completion)
    }

    var cameraPosition: CameraPosition {
        guard let videoInput = videoInput else {
            return .back
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

    private init() {
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

        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
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

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default
            .addObserver(self, selector: #selector(deviceOrientationDidChange),
                         name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    func previewView(_ bounds: CGRect) -> UIView {
        return previewLayer(bounds, session: session)
    }

    private func previewLayer(_ bounds: CGRect, session: AVCaptureSession?) -> UIView {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

        let view = UIView(frame: bounds)
        view.layer.addSublayer(previewLayer!)

        return view
    }

    // MARK: - Control

    func startRunning() {
        session?.startRunning()
    }

    func stopRunning() {
        session?.stopRunning()
    }

    func capture(_ completion: ((_ image: UIImage?, _ error: NSError?) -> Void)?) {
        captureStillImageOutput.captureStillImageAsynchronously(
            from: captureStillImageOutput.connection(withMediaType: AVMediaTypeVideo)) { (sampleBuffer, error) in
                guard let sampleBuffer = sampleBuffer else {
                    completion?(nil, error as NSError?)
                    return
                }

                let exifAttachment =
                    CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, nil)
                if exifAttachment != nil {
                    print("Attachment: \(String(describing: exifAttachment))")
                } else {
                    print("No attachment")
                }

                let imageData =
                    AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: imageData!)
                completion?(image, nil)
        }
    }

    private func sideWithCaptureDevice(_ videoInput: AVCaptureDeviceInput) -> CameraPosition {
        let isBackCamera = videoInput.device.position == .back
        return isBackCamera ? CameraPosition.back : CameraPosition.front
    }

    private func sideSwitchedInput(_ currentVideoInput: AVCaptureDeviceInput,
                                   captureSession session: AVCaptureSession)
        -> AVCaptureDeviceInput? {
            guard CameraHelper.frontCameraAvailable else {
                return nil
            }

            var newVideoInput: AVCaptureDeviceInput?

            session.stopRunning()
            session.removeInput(currentVideoInput)

            if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
                as? [AVCaptureDevice] {
                for device in devices {
                    if device.hasMediaType(AVMediaTypeVideo) {
                        if currentVideoInput.device.position == .back {
                            if device.position == .front {
                                do {
                                    try newVideoInput = AVCaptureDeviceInput(device: device)
                                    break
                                } catch {
                                    print("Failed to create input")
                                }
                            }
                        } else {
                            if device.position == .back {
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

    private func torchWithCaptureDevice(_ device: AVCaptureDevice) -> Bool {
        if device.hasTorch {
            return device.torchMode == .on
        }
        return false
    }

    private func setTorch(_ enable: Bool, withCaptureDevice device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if enable {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {}
    }

    private func focusWithCaptureDevice(_ device: AVCaptureDevice) -> CGPoint {
        if device.isFocusPointOfInterestSupported {
            return device.focusPointOfInterest
        }
        return CGPoint.zero
    }

    private func setFocus(_ pointOfInterest: CGPoint, withCaptureDevice device: AVCaptureDevice) {
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = pointOfInterest
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
            } catch {}
        }
    }

    func switchCamera() {
        guard let videoInput = videoInput, let session = session else {
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
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = .portrait
        case .portraitUpsideDown:
            orientation = .portrait
        case .landscapeLeft:
            orientation = .landscapeRight
        case .landscapeRight:
            orientation = .landscapeLeft
        default:
            orientation = .portrait
        }

        session.beginConfiguration()

        if let connection = captureStillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = orientation
            }
        }

        session.commitConfiguration()
    }

}
