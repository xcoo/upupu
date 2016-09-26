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

    func cameraViewController(cameraViewController: CameraViewController,
                              didFinishedWithImage image: UIImage?)

}

class CameraViewController: UIViewController, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UIAccelerometerDelegate {

    weak var delegate: CameraViewControllerDelegate?

    var isSourcePhotoLibrary = false

    private var orientation: UIInterfaceOrientation = .Portrait
    private var focusLayer: CALayer!
    private var shutterLayer: CALayer!
    private var inFocusProcess = false

    private var cameraView: CameraView!

    private var isCameraInitialized = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        cameraView = CameraView()
        view = cameraView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.cameraButton.action = #selector(takePicture)
        cameraView.clipsButton.action = #selector(clips)

        cameraView.switchButton.addTarget(self, action: #selector(switchCamera),
                                          forControlEvents: .TouchUpInside)
        cameraView.torchButton.addTarget(self, action: #selector(switchTorch),
                                         forControlEvents: .TouchUpInside)

        focusLayer = CALayer()
        let focusImage = UIImage(named: "Camera/Focus")
        focusLayer.contents = focusImage?.CGImage
        cameraView.overlayView.layer.addSublayer(focusLayer)

        shutterLayer = CALayer()
        shutterLayer.frame = cameraView.overlayView.frame
        shutterLayer.backgroundColor = UIColor.whiteColor().CGColor
        shutterLayer.opacity = 0
        cameraView.overlayView.layer.addSublayer(shutterLayer)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if isCameraInitialized {
            startCamera()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        CameraHelper.sharedInstance.stopRunning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !isSourcePhotoLibrary {
            prepareCamera()
        }
    }

    override func shouldAutorotate() -> Bool {
        return UIDevice.currentDevice().orientation == .Portrait
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }

    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPreview))
        cameraView.overlayView.addGestureRecognizer(tapGesture)

        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(deviceOrientationDidChange),
                         name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    private func resetButtons() {
        cameraView.switchButton.hidden = true
        cameraView.torchButton.hidden = true
        cameraView.cameraButton.enabled = false
    }

    private func setupButtons() {
        cameraView.switchButton.hidden = !CameraHelper.frontCameraAvailable
        cameraView.torchButton.hidden =
            !CameraHelper.torchAvailable || !CameraHelper.sharedInstance.torchAvailable
        cameraView.cameraButton.enabled = true
    }

    private func prepareCamera() {
        resetButtons()

        if CameraHelper.cameraAvailable {
            switch CameraHelper.authorizationStatus {
            case .Authorized:
                startCamera()
            case .NotDetermined:
                CameraHelper.requestAccess {[weak self] granted in
                    if granted {
                        self?.prepareCamera()
                    }
                }
            case .Denied, .Restricted:
                UIAlertController.showSettingsAlertIn(self, title: nil,
                                                      message: "Allow access to Camera")
            }
        } else {
            cameraView.messageLabel.text = "Camera is unavailable."
            cameraView.messageLabel.hidden = false
        }
    }

    private func startCamera() {
        if isCameraInitialized {
            setupButtons()
            CameraHelper.sharedInstance.startRunning()
        } else {
            dispatch_async(dispatch_get_main_queue()) {[weak self] in
                guard let self_ = self else {
                    return
                }

                self_.setupButtons()

                self_.cameraView.previewView.hidden = true
                for view in self_.cameraView.previewView.subviews {
                    view.removeFromSuperview()
                }

                var rect = UIScreen.mainScreen().applicationFrame
                rect.size.height -= self_.cameraView.toolbar.frame.size.height
                let preview = CameraHelper.sharedInstance.previewView(rect)
                CameraHelper.sharedInstance.startRunning()
                self_.cameraView.previewView.addSubview(preview)
                self_.cameraView.previewView.hidden = false
                self_.setup()
                self_.isCameraInitialized = true
            }
        }
    }

    // MARK: - Action

    @objc private func clips(sender: UIBarButtonItem) {
        CameraHelper.sharedInstance.stopRunning()

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.modalTransitionStyle = .FlipHorizontal
        imagePicker.allowsEditing = false

        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @objc private func takePicture(sender: UIBarButtonItem) {
        CATransaction.begin()

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 0.5
        opacityAnimation.repeatCount = 0
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        shutterLayer.addAnimation(opacityAnimation, forKey: "opacity")

        CATransaction.commit()

        CameraHelper.sharedInstance.capture {[weak self] (image, error) in
            guard error == nil else {
                print(error)
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

    private func afterTaken(image: UIImage) {
        delegate?.cameraViewController(self, didFinishedWithImage: image)
    }

    @objc private func switchCamera(sender: UIButton) {
        CameraHelper.sharedInstance.switchCamera()
        cameraView.torchButton.hidden = !CameraHelper.sharedInstance.torchAvailable
    }

    @objc private func switchTorch(sender: UIButton) {
        let cameraHelper = CameraHelper.sharedInstance
        if cameraHelper.torch {
            cameraHelper.torch = false
            cameraView.torchButton.setImage(UIImage(named: "Camera/TorchOff.png"),
                                            forState: .Normal)
        } else {
            cameraHelper.torch = true
            cameraView.torchButton.setImage(UIImage(named: "Camera/TorchOn.png"), forState: .Normal)
        }
    }

    // MARK: - Rotation

    @objc private func rotateView() {
        UIView.animateWithDuration(0.5, animations: {[weak self] in
            if let orientation = self?.orientation {
                switch orientation {
                case .Portrait:
                    self?.cameraView.switchButton.transform = CGAffineTransformMakeRotation(0)
                    self?.cameraView.torchButton.transform = CGAffineTransformMakeRotation(0)
                case .PortraitUpsideDown:
                    self?.cameraView.switchButton.transform =
                        CGAffineTransformMakeRotation(CGFloat(M_PI))
                    self?.cameraView.torchButton.transform =
                        CGAffineTransformMakeRotation(CGFloat(M_PI))
                case .LandscapeLeft:
                    self?.cameraView.switchButton.transform =
                        CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
                    self?.cameraView.torchButton.transform =
                        CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
                case .LandscapeRight:
                    self?.cameraView.switchButton.transform =
                        CGAffineTransformMakeRotation(-CGFloat(M_PI) / 2)
                    self?.cameraView.torchButton.transform =
                        CGAffineTransformMakeRotation(-CGFloat(M_PI) / 2)
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

    func tapPreview(sender: UITapGestureRecognizer) {
        if sender.state != .Ended || inFocusProcess {
            return
        }

        inFocusProcess = true

        let p = sender.locationInView(cameraView.previewView)
        let viewSize = cameraView.previewView.frame.size
        let focusPoint = CGPoint.init(x: 1 - p.x / viewSize.width, y: p.y / viewSize.height)

        CameraHelper.sharedInstance.focus = focusPoint

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
        focusLayer.addAnimation(opacityAnimation, forKey: "opacity")

        let scaleXAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        scaleXAnimation.duration = 0.4
        scaleXAnimation.repeatCount = 0
        scaleXAnimation.fromValue = 3
        scaleXAnimation.toValue = 1
        focusLayer.addAnimation(scaleXAnimation, forKey: "transform.scale.x")

        let scaleYAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleYAnimation.duration = 0.4
        scaleYAnimation.repeatCount = 0
        scaleYAnimation.fromValue = 3
        scaleYAnimation.toValue = 1
        focusLayer.addAnimation(scaleYAnimation, forKey: "transform.scale.y")

        CATransaction.commit()

        NSTimer.scheduledTimerWithTimeInterval(1, target: self,
                                               selector: #selector(finishFocusProcess),
                                               userInfo: nil, repeats: false)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let origImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            isSourcePhotoLibrary = true
            picker.dismissViewControllerAnimated(true) {[weak self] in
                self?.afterTaken(origImage)
            }
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Orientation

    func deviceOrientationDidChange() {
        switch UIDevice.currentDevice().orientation {
        case .Portrait:
            orientation = .Portrait
        case .PortraitUpsideDown:
            orientation = .PortraitUpsideDown
        case .LandscapeLeft:
            orientation = .LandscapeLeft
        case .LandscapeRight:
            orientation = .LandscapeRight
        default:
            break
        }

        performSelectorOnMainThread(#selector(rotateView), withObject: nil, waitUntilDone: true)
    }

}
