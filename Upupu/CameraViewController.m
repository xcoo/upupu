//
//  CameraViewController.m
//  Upupu
//
//  Created by Takashi AOKI on 4/8/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import "CameraViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CameraHelper.h"
#import "AlertUtil.h"

//static const int MAX_RESOLUTION = 640;
//static const double ACCELEROMETER_THRESHOLD = 0.85;

@interface CameraViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAccelerometerDelegate> {
    UIInterfaceOrientation _orientation;
    
    CALayer *_focusLayer;
    CALayer *_shutterLayer;
    BOOL _inFocusProcess;
}

@property (nonatomic, retain) IBOutlet UIView *previewView;
@property (nonatomic, retain) IBOutlet UIView *overlayView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cameraButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *clipsButton;

@property (nonatomic, retain) IBOutlet UIButton *switchButton;
@property (nonatomic, retain) IBOutlet UIButton *torchButton;

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

@end

@implementation CameraViewController

@synthesize previewView = _previewView, overlayView = _overlayView;
@synthesize delegate = _delegate;
@synthesize cameraButton = _cameraButton, clipsButton = _clipsButton;
@synthesize switchButton = _switchButton, torchButton = _torchButton;
@synthesize toolBar = _toolBar;
@synthesize isSourcePhotoLibrary = _isSourcePhotoLibrary;

#pragma mark - Rotate -

- (void) rotateView
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:0.5];

    if( _orientation == UIInterfaceOrientationPortrait ) {
        _switchButton.transform = CGAffineTransformMakeRotation(0.0);
        _torchButton.transform = CGAffineTransformMakeRotation(0.0);
    }
    
    if( _orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        _switchButton.transform = CGAffineTransformMakeRotation(M_PI);
        _torchButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    if( _orientation == UIInterfaceOrientationLandscapeLeft ) {
        _switchButton.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
        _torchButton.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    }

    if( _orientation == UIInterfaceOrientationLandscapeRight ) {
        _switchButton.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
        _torchButton.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
    }
    
    [UIView commitAnimations];
}

#pragma mark - Focus -

- (void) _finishFocusProcess
{
    _inFocusProcess = NO;
}

- (void) tapPreview:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if( _inFocusProcess ) {
            return;
        }
        
        _inFocusProcess = YES;
        
        CGPoint p = [sender locationInView:_previewView];
        
        CGSize viewSize = _previewView.frame.size;
        
        CGPoint focusPoint = CGPointMake(1.0 - p.x / (CGFloat)viewSize.width, p.y / (CGFloat)viewSize.height);

        [[CameraHelper sharedInstance] setFocus:focusPoint];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        _focusLayer.frame = CGRectMake(p.x-50, p.y-50, 100, 100);
        _focusLayer.opacity = 0.0;
        
        [CATransaction commit];
        
        NSArray *opacityValues = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.0], 
                                  [NSNumber numberWithFloat:0.2],
                                  [NSNumber numberWithFloat:0.4],
                                  [NSNumber numberWithFloat:0.6],
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1.0],
                                  [NSNumber numberWithFloat:0.6],
                                  [NSNumber numberWithFloat:1.0],
                                  [NSNumber numberWithFloat:0.6], nil];
        

        [CATransaction begin];
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = 0.8f;
        opacityAnimation.values = opacityValues;
        opacityAnimation.calculationMode = kCAAnimationCubic;
        opacityAnimation.repeatCount = 0;
        
        [_focusLayer addAnimation:opacityAnimation forKey:@"opacity"];
        
        CABasicAnimation* scaleXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        scaleXAnimation.duration     = 0.4f;
        scaleXAnimation.repeatCount  = 0;
        scaleXAnimation.fromValue = [NSNumber numberWithDouble:3.0];
        scaleXAnimation.toValue   = [NSNumber numberWithDouble:1.0];
        [_focusLayer addAnimation:scaleXAnimation forKey:@"transform.scale.x"];
        
        CABasicAnimation* scaleYAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        scaleYAnimation.duration     = 0.4f;
        scaleYAnimation.repeatCount  = 0;
        scaleYAnimation.fromValue = [NSNumber numberWithDouble:3.0];
        scaleYAnimation.toValue   = [NSNumber numberWithDouble:1.0];
        [_focusLayer addAnimation:scaleYAnimation forKey:@"transform.scale.y"];
        
        [CATransaction commit];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(_finishFocusProcess) userInfo:nil repeats:NO];
    }
}

#pragma mark - Action -

-(IBAction) clips:(id)sender
{
    [[CameraHelper sharedInstance] stopRunning];
        
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    imagePicker.allowsEditing = NO;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    [imagePicker release];
}

-(IBAction) takePicture:(id)sender
{
    [CATransaction begin];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration     = 0.5f;
    opacityAnimation.repeatCount  = 0;
    opacityAnimation.fromValue = [NSNumber numberWithDouble:1.0];
    opacityAnimation.toValue   = [NSNumber numberWithDouble:0.0];
    [_shutterLayer addAnimation:opacityAnimation forKey:@"opacity"];
    
    [CATransaction commit];
    
    [[CameraHelper sharedInstance] addObserver:self forKeyPath:CAMERA_HELPER_CAPTURE_REQUEST_KEY options:NSKeyValueObservingOptionNew context:nil];
    [[CameraHelper sharedInstance] capture];
}

-(void) afterTaken:(UIImage *)image
{
    @try {
        [[CameraHelper sharedInstance] removeObserver:self forKeyPath:CAMERA_HELPER_CAPTURE_REQUEST_KEY];
    }
    @catch (NSException *exception) {
        // do nothing
    }
    
    [[CameraHelper sharedInstance] stopRunning];
    
    if( _delegate != nil && [_delegate respondsToSelector:@selector(cameraViewController:didFinishedWithImage:)] ) {
        [_delegate cameraViewController:self didFinishedWithImage:image];
    }
}

- (void) switchCamera:(id)sender
{
    [[CameraHelper sharedInstance] switchCamera];
    
    if( [[CameraHelper sharedInstance] availableTorch] ) {
        _torchButton.hidden = NO;        
    } else {
        _torchButton.hidden = YES;
    }
}

- (void) switchTorch:(id)sender
{
    if( [[CameraHelper sharedInstance] torch] ) {
        [[CameraHelper sharedInstance] setTorch:NO];
        [_torchButton setImage:[UIImage imageNamed:@"camera_icon_light_off.png"] forState:UIControlStateNormal]; 
    } else {
        [[CameraHelper sharedInstance] setTorch:YES];
        [_torchButton setImage:[UIImage imageNamed:@"camera_icon_light_on.png"] forState:UIControlStateNormal]; 
    }
}

#pragma mark - View lifecycle -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( [CameraHelper supportFrontCamera] == NO ) {
        _switchButton.hidden = YES;
    }

    if( [CameraHelper supportTorch] == NO || [[CameraHelper sharedInstance] availableTorch] == NO ) {
        _torchButton.hidden = YES;
    }
    
    [_switchButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_torchButton addTarget:self action:@selector(switchTorch:) forControlEvents:UIControlEventTouchUpInside];
     
    _focusLayer = [CALayer layer];
    UIImage *focusImage = [UIImage imageNamed:@"camera_focus.png"];
    _focusLayer.contents = (id) focusImage.CGImage;
    [_overlayView.layer addSublayer:_focusLayer];

    _shutterLayer = [CALayer layer];
    _shutterLayer.frame = _overlayView.frame;
    _shutterLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _shutterLayer.opacity = 0.0;
    [_overlayView.layer addSublayer:_shutterLayer];
    
    _orientation = UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
    SAFE_RELEASE(_previewView)
    SAFE_RELEASE(_overlayView)
    
    SAFE_RELEASE(_cameraButton)
    SAFE_RELEASE(_clipsButton)
    SAFE_RELEASE(_switchButton)
    SAFE_RELEASE(_torchButton)
    
    SAFE_RELEASE(_toolBar)
    
    [super viewDidUnload];
    
    Logging(@"deallocated");
}

- (void)dealloc
{
    SAFE_RELEASE(_previewView)
    SAFE_RELEASE(_overlayView)
    
    SAFE_RELEASE(_cameraButton)
    SAFE_RELEASE(_clipsButton)
    SAFE_RELEASE(_switchButton)
    SAFE_RELEASE(_torchButton)
    
    SAFE_RELEASE(_toolBar)
    
    [super dealloc];
    
    Logging(@"deallocated");
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view.frame = self.view.bounds;
    _overlayView.frame = self.view.frame;
    _shutterLayer.frame = _overlayView.frame;
   
    if ( [CameraHelper support] ) {
        [[CameraHelper sharedInstance] startRunning];

        CGRect rect = [[UIScreen mainScreen] applicationFrame];
        rect.size.height -= _toolBar.frame.size.height;
        UIView *preview = [[CameraHelper sharedInstance] previewViewWithBounds:rect];
        [_previewView addSubview:preview];

    } else {
        [AlertUtil showWithTitle:@"Error" andMessage:@"Camera is unavailable"];
    }

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPreview:)];  
    [_overlayView addGestureRecognizer:tapGesture];  
    [tapGesture release];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[CameraHelper sharedInstance] stopRunning];
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        // do nothing
    }
    
    @try {
        [[CameraHelper sharedInstance] removeObserver:self forKeyPath:CAMERA_HELPER_CAPTURE_REQUEST_KEY];
    }
    @catch (NSException *exception) {
        // do nothing
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIImagePickerControllerDelegate -
 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
 
    _isSourcePhotoLibrary = YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationFade];
        [self afterTaken:originalImage];

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [[CameraHelper sharedInstance] startRunning];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationFade];
    }];
}

#pragma mark - Key Value Observation -

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object 
                        change:(NSDictionary*)change context:(void*)context
{
    @try {
        [object removeObserver:self forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        
    }
	
    if( [object isMemberOfClass:[CameraHelper class]] &&
        [keyPath isEqualToString:@"isCaptured"] ) {
        
        UIImage *originalImage = [[CameraHelper sharedInstance] capturedImage];
        
        _isSourcePhotoLibrary = NO;
        
        [self afterTaken:originalImage];
    }
}

#pragma mark - Orientation -

- (void)deviceOrientationDidChange
{	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait) {
        _orientation = UIInterfaceOrientationPortrait;
	} else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		_orientation = UIInterfaceOrientationPortraitUpsideDown;
	} else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		_orientation = UIInterfaceOrientationLandscapeLeft;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
		_orientation = UIInterfaceOrientationLandscapeRight;
	}
    
    [self performSelectorOnMainThread:@selector(rotateView) withObject:nil waitUntilDone:YES];
}
 
@end
