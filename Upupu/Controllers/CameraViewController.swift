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

    @IBOutlet private weak var previewView: UIView!
    @IBOutlet private weak var overlayView: UIView!

    @IBOutlet private weak var cameraButton: UIBarButtonItem!
    @IBOutlet private weak var clipsButton: UIBarButtonItem!

    @IBOutlet private weak var switchButton: UIButton!
    @IBOutlet private weak var torchButton: UIButton!

    @IBOutlet private weak var toolBar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()

        switchButton.hidden = !CameraHelper.supportFrontCamera()
        torchButton.hidden = !CameraHelper.supportTorch() ||
            !CameraHelper.sharedInstance.availableTorch()

        switchButton.addTarget(self, action: #selector(switchCamera),
                               forControlEvents: .TouchUpInside)
        torchButton.addTarget(self, action: #selector(switchTorch),
                              forControlEvents: .TouchUpInside)

        focusLayer = CALayer()
        let focusImage = UIImage(named: "camera_focus.png")
        focusLayer.contents = focusImage?.CGImage
        overlayView.layer.addSublayer(focusLayer)

        shutterLayer = CALayer()
        shutterLayer.frame = overlayView.frame
        shutterLayer.backgroundColor = UIColor.whiteColor().CGColor
        shutterLayer.opacity = 0
        overlayView.layer.addSublayer(shutterLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        view.frame = view.bounds
        overlayView.frame = view.frame
        shutterLayer.frame = overlayView.frame

        if CameraHelper.support() {
            previewView.hidden = true
            for view in previewView.subviews {
                view.removeFromSuperview()
            }

            var rect = UIScreen.mainScreen().applicationFrame
            rect.size.height -= toolBar.frame.size.height
            let preview = CameraHelper.sharedInstance.previewView(rect)

            CameraHelper.sharedInstance.startRunning()

            previewView.addSubview(preview)
            previewView.hidden = false
            setup()
        } else {
            UIAlertController.showSimpleAlertIn(navigationController, title: "Error",
                                                message: "Camera is unavailable")
            setup()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        CameraHelper.sharedInstance.stopRunning()

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func shouldAutorotate() -> Bool {
        return UIDevice.currentDevice().orientation == .Portrait
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPreview))
        overlayView.addGestureRecognizer(tapGesture)

        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(deviceOrientationDidChange),
                                                         name: UIDeviceOrientationDidChangeNotification,
                                                         object: nil)
    }

    // MARK: - Action

    @IBAction private func clips(sender: UIBarButtonItem) {
        CameraHelper.sharedInstance.stopRunning()

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.modalTransitionStyle = .FlipHorizontal
        imagePicker.allowsEditing = false

        CameraHelper.sharedInstance.addObserver(self,
                                                forKeyPath: CameraHelper.kCameraHelperCaptureRequestKey,
                                                options: .New, context: nil)
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction private func takePicture(sender: UIBarButtonItem) {
        CATransaction.begin()

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 0.5
        opacityAnimation.repeatCount = 0
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        shutterLayer.addAnimation(opacityAnimation, forKey: "opacity")

        CATransaction.commit()

        CameraHelper.sharedInstance.addObserver(self,
                                                forKeyPath: CameraHelper.kCameraHelperCaptureRequestKey,
                                                options: .New,
                                                context: nil)
        CameraHelper.sharedInstance.capture()
    }

    private func afterTaken(image: UIImage) {
        CameraHelper.sharedInstance.stopRunning()

        delegate?.cameraViewController(self, didFinishedWithImage: image)
    }

    @objc private func switchCamera(sender: UIButton) {
        CameraHelper.sharedInstance.switchCamera()
        torchButton.hidden = !CameraHelper.sharedInstance.availableTorch()
    }

    @objc private func switchTorch(sender: UIButton) {
        let cameraHelper = CameraHelper.sharedInstance
        if cameraHelper.torch {
            cameraHelper.torch = false
            torchButton.setImage(UIImage(named: "camera_icon_light_off.png"), forState: .Normal)
        } else {
            cameraHelper.torch = true
            torchButton.setImage(UIImage(named: "camera_icon_light_on.png"), forState: .Normal)
        }
    }

    // MARK: - Rotation

    @objc private func rotateView() {
        UIView.animateWithDuration(0.5, animations: {[weak self] in
            if let orientation = self?.orientation {
                switch orientation {
                case .Portrait:
                    self?.switchButton.transform = CGAffineTransformMakeRotation(0)
                    self?.torchButton.transform = CGAffineTransformMakeRotation(0)
                case .PortraitUpsideDown:
                    self?.switchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    self?.torchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                case .LandscapeLeft:
                    self?.switchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
                    self?.torchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
                case .LandscapeRight:
                    self?.switchButton.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI) / 2)
                    self?.torchButton.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI) / 2)
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

        let p = sender.locationInView(previewView)
        let viewSize = previewView.frame.size
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
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
                self?.afterTaken(origImage)
            }
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        }
    }

    // MARK: - Key value observation

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?,
                                         context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath {
            object?.removeObserver(self, forKeyPath: keyPath)
        }

        if object?.dynamicType === CameraHelper.self &&
            keyPath == CameraHelper.kCameraHelperCaptureRequestKey {
            if let origImage = CameraHelper.sharedInstance.capturedImage {
                isSourcePhotoLibrary = false
                afterTaken(origImage)
            }
        }
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
