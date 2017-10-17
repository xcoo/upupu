//
//  CameraViewController.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

protocol CameraViewControllerDelegate: class {

    func cameraViewController(_ cameraViewController: CameraViewController, didFinishedWithImage image: UIImage?)

}

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UIAccelerometerDelegate {

    weak var delegate: CameraViewControllerDelegate?

    var isSourcePhotoLibrary = false

    private var orientation: UIInterfaceOrientation = .portrait
    private var focusLayer: CALayer!
    private var shutterLayer: CALayer!
    private var inFocusProcess = false

    private var cameraView: CameraView!

    private var isCameraInitialized = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AccelerometerOrientationDidChange, object: nil)
        AccelerometerOrientation.current.endGeneratingDeviceOrientationNotifications()

        if let gestureRecognizers = cameraView.overlayView.gestureRecognizers {
            for gesture in gestureRecognizers {
                cameraView.overlayView.removeGestureRecognizer(gesture)
            }
        }
    }

    override func loadView() {
        cameraView = CameraView()
        view = cameraView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.cameraButton.action = #selector(takePicture)
        cameraView.clipsButton.action = #selector(clips)

        cameraView.switchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        cameraView.torchButton.addTarget(self, action: #selector(switchTorch), for: .touchUpInside)

        focusLayer = CALayer()
        let focusImage = UIImage(named: "Camera/Focus")
        focusLayer.contents = focusImage?.cgImage
        cameraView.overlayView.layer.addSublayer(focusLayer)

        shutterLayer = CALayer()
        shutterLayer.frame = cameraView.overlayView.frame
        shutterLayer.backgroundColor = UIColor.white.cgColor
        shutterLayer.opacity = 0
        cameraView.overlayView.layer.addSublayer(shutterLayer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isCameraInitialized {
            startCamera()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CameraHelper.shared.stopRunning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isSourcePhotoLibrary {
            prepareCamera()
        }
    }

    override var shouldAutorotate: Bool {
        return UIDevice.current.orientation == .portrait
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPreview))
        cameraView.overlayView.addGestureRecognizer(tapGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(overlayViewPinched))
        cameraView.overlayView.addGestureRecognizer(pinchGesture)

        AccelerometerOrientation.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceOrientationDidChange),
                                               name: .AccelerometerOrientationDidChange,
                                               object: nil)
    }

    private func resetButtons() {
        cameraView.switchButton.isHidden = true
        cameraView.torchButton.isHidden = true
        cameraView.cameraButton.isEnabled = false
    }

    private func setupButtons() {
        cameraView.switchButton.isHidden = !CameraHelper.frontCameraAvailable
        cameraView.torchButton.isHidden =
            !CameraHelper.torchAvailable || !CameraHelper.shared.torchAvailable
        cameraView.cameraButton.isEnabled = true
    }

    private func prepareCamera() {
        resetButtons()

        if CameraHelper.cameraAvailable {
            switch CameraHelper.authorizationStatus {
            case .authorized:
                startCamera()
            case .notDetermined:
                CameraHelper.requestAccess {[weak self] granted in
                    if granted {
                        self?.prepareCamera()
                    }
                }
            case .denied, .restricted:
                UIAlertController.showSettingsAlertIn(self, title: nil, message: "Allow access to Camera")
            }
        } else {
            cameraView.messageLabel.text = "Camera is unavailable."
            cameraView.messageLabel.isHidden = false
        }
    }

    private func startCamera() {
        if isCameraInitialized {
            setupButtons()
            CameraHelper.shared.startRunning()
        } else {
            DispatchQueue.main.async {[weak self] in
                guard let self_ = self else {
                    return
                }

                self_.setupButtons()

                self_.cameraView.previewView.isHidden = true
                for view in self_.cameraView.previewView.subviews {
                    view.removeFromSuperview()
                }

                var rect = UIScreen.main.bounds
                rect.size.height -= self_.cameraView.toolbar.frame.size.height
                let preview = CameraHelper.shared.previewView(rect)
                CameraHelper.shared.startRunning()
                self_.cameraView.previewView.addSubview(preview)
                self_.cameraView.previewView.isHidden = false
                self_.setup()
                self_.isCameraInitialized = true
            }
        }
    }

    // MARK: - Action

    @objc private func clips(_ sender: UIBarButtonItem) {
        CameraHelper.shared.stopRunning()

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalTransitionStyle = .flipHorizontal
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func takePicture(_ sender: UIBarButtonItem) {
        CATransaction.begin()

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 0.5
        opacityAnimation.repeatCount = 0
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        shutterLayer.add(opacityAnimation, forKey: "opacity")

        CATransaction.commit()

        CameraHelper.shared.capture {[weak self] (image, error) in
            guard error == nil else {
                print(error!)
                if let self_ = self {
                    UIAlertController.showSimpleAlertIn(self_.navigationController,
                                                        title: "Error",
                                                        message: "Failed to capture image")
                }
                return
            }

            guard let image = image else {
                print("No image")
                if let self_ = self {
                    UIAlertController.showSimpleAlertIn(self_.navigationController,
                                                        title: "Error",
                                                        message: "Failed to capture image")
                }
                return
            }

            self?.isSourcePhotoLibrary = false
            self?.afterTaken(image)
        }
    }

    private func afterTaken(_ image: UIImage) {
        delegate?.cameraViewController(self, didFinishedWithImage: image)
    }

    @objc private func switchCamera(_ sender: UIButton) {
        CameraHelper.shared.switchCamera()
        cameraView.torchButton.isHidden = !CameraHelper.shared.torchAvailable
    }

    @objc private func switchTorch(_ sender: UIButton) {
        let cameraHelper = CameraHelper.shared
        if cameraHelper.torch {
            cameraHelper.torch = false
            cameraView.torchButton.setImage(UIImage(named: "Camera/TorchOff.png"), for: [])
        } else {
            cameraHelper.torch = true
            cameraView.torchButton.setImage(UIImage(named: "Camera/TorchOn.png"), for: [])
        }
    }

    // MARK: - Rotation

    @objc private func rotateView() {
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            if let orientation = self?.orientation {
                switch orientation {
                case .portrait:
                    self?.cameraView.switchButton.transform = CGAffineTransform(rotationAngle: 0)
                    self?.cameraView.torchButton.transform = CGAffineTransform(rotationAngle: 0)
                case .portraitUpsideDown:
                    self?.cameraView.switchButton.transform = CGAffineTransform(rotationAngle: .pi)
                    self?.cameraView.torchButton.transform = CGAffineTransform(rotationAngle: .pi)
                case .landscapeLeft:
                    self?.cameraView.switchButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
                    self?.cameraView.torchButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
                case .landscapeRight:
                    self?.cameraView.switchButton.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                    self?.cameraView.torchButton.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                default:
                    break
                }
            }
            })
    }

    // MARK: - Focus

    @objc private func finishFocusProcess() {
        inFocusProcess = false
    }

    func tapPreview(_ sender: UITapGestureRecognizer) {
        if sender.state != .ended || inFocusProcess {
            return
        }

        inFocusProcess = true

        let p = sender.location(in: cameraView.previewView)
        let viewSize = cameraView.previewView.frame.size
        let focusPoint = CGPoint.init(x: 1 - p.x / viewSize.width, y: p.y / viewSize.height)

        CameraHelper.shared.focus = focusPoint

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        focusLayer.frame = CGRect.init(x: p.x - 50, y: p.y - 50, width: 100, height: 100)
        focusLayer.opacity = 0

        CATransaction.commit()

        let opacityValues = [0, 0.2, 0.4, 0.6, 0.8, 1, 0.6, 1, 0.6]

        CATransaction.begin()

        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = 0.8
        opacityAnimation.values = opacityValues
        opacityAnimation.calculationMode = kCAAnimationCubic
        opacityAnimation.repeatCount = 0
        focusLayer.add(opacityAnimation, forKey: "opacity")

        let scaleXAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        scaleXAnimation.duration = 0.4
        scaleXAnimation.repeatCount = 0
        scaleXAnimation.fromValue = 3
        scaleXAnimation.toValue = 1
        focusLayer.add(scaleXAnimation, forKey: "transform.scale.x")

        let scaleYAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleYAnimation.duration = 0.4
        scaleYAnimation.repeatCount = 0
        scaleYAnimation.fromValue = 3
        scaleYAnimation.toValue = 1
        focusLayer.add(scaleYAnimation, forKey: "transform.scale.y")

        CATransaction.commit()

        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(finishFocusProcess),
                             userInfo: nil,
                             repeats: false)
    }

    // MARK: - Zoom

    private var baseScale: CGFloat = 1

    func overlayViewPinched(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            baseScale = CameraHelper.shared.zoomFactor
        }
        CameraHelper.shared.zoomFactor = baseScale * gesture.scale
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: Any]) {
        if let origImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            isSourcePhotoLibrary = true
            picker.dismiss(animated: true) {[weak self] in
                self?.afterTaken(origImage)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Orientation

    func deviceOrientationDidChange() {
        switch AccelerometerOrientation.current.orientation {
        case .portrait:
            orientation = .portrait
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        case .landscapeLeft:
            orientation = .landscapeLeft
        case .landscapeRight:
            orientation = .landscapeRight
        default:
            break
        }

        performSelector(onMainThread: #selector(rotateView), with: nil, waitUntilDone: true)
    }

}
