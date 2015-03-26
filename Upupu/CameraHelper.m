//
//  CameraHelper.m
//  Upupu
//
//  Created by Takashi Aoki on 9/07/10.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#import "CameraHelper.h"

@interface CameraHelper()
{
    AVCaptureSession *_session;
    
    AVCaptureDeviceInput *_videoInput;
    AVCaptureStillImageOutput *_captureStillImageOutput;
}

- (CameraSide) sideWithCaptureDeviceInput:(AVCaptureDeviceInput *)videoInput;
- (AVCaptureDeviceInput *) switchSideWithCaptureDeviceInput:(AVCaptureDeviceInput *)currentVideoInput captureSession:(AVCaptureSession*)session;

- (BOOL) torchWithCaptureDevice:(AVCaptureDevice *)device;
- (void) setTorch:(BOOL)val withCaptureDevice:(AVCaptureDevice *)device;

- (UIView *) previewLayerWithBounds:(CGRect) bounds session:(AVCaptureSession *)session;

- (CGPoint) focusWithCaptureDevice:(AVCaptureDevice *)device;
- (void) setFocus:(CGPoint)p withCaptureDevice:(AVCaptureDevice *)device;

@end

@implementation CameraHelper

@synthesize capturedImage = _capturedImage;
@synthesize isCaptured = _isCaptured;

#pragma mark - Support -

+ (BOOL) support
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) supportFrontCamera
{
    BOOL result = NO;
    
    @autoreleasepool {
	
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *device in videoDevices) {
            if (device.position == AVCaptureDevicePositionFront) {
                result = YES;
            }
        }

    }
    
    return result;
}

+ (BOOL) supportTorch
{
    BOOL result = NO;
    
    @autoreleasepool {
	
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *device in videoDevices) {
            if ( device.hasTorch ) {
                result = YES;
                break;
            }
        }
        
    }
    
    return result;
}

#pragma mark - Private -

- (CameraSide) sideWithCaptureDeviceInput:(AVCaptureDeviceInput *)videoInput
{
    BOOL isBackCamera = [videoInput.device position] == AVCaptureDevicePositionBack;
    
    return isBackCamera ? CameraSideBack : CameraSideFront;
}

- (AVCaptureDeviceInput *) switchSideWithCaptureDeviceInput:(AVCaptureDeviceInput *)currentVideoInput captureSession:(AVCaptureSession*)session
{
    if( ![CameraHelper supportFrontCamera] ) {
        return nil;
    }
    
    AVCaptureDeviceInput *newVideoInput = nil;
    
    @autoreleasepool {

        BOOL isBackCamera = [currentVideoInput.device position] == AVCaptureDevicePositionBack;
        
        [session stopRunning];
        
        [session removeInput:currentVideoInput];
        currentVideoInput = nil;
        
        
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *device in devices) 
        {
            if ([device hasMediaType:AVMediaTypeVideo]) 
            {
                if (isBackCamera)
                {
                    if ([device position] == AVCaptureDevicePositionFront) 
                    {
                        newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                        break;
                    }
                }
                else 
                {
                    if ([device position] == AVCaptureDevicePositionBack) 
                    {
                        newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                        break;
                    }
                }
            }
        }
        
        if (newVideoInput != nil)
        {
            [session addInput:newVideoInput];
            [session startRunning];
        } else {
            NSLog(@"Failed to switch camera");
        }

    }
    
    return newVideoInput;
}

- (BOOL) torchWithCaptureDevice:(AVCaptureDevice *)device
{
    if( device.hasTorch ) {
        return device.torchMode == AVCaptureTorchModeOn;
    } else {
        return NO;
    }
}

- (void) setTorch:(BOOL)val withCaptureDevice:(AVCaptureDevice *)device
{
    NSError *error;
    
    if( [device lockForConfiguration:&error] ) {
        
        if( val ) {
            device.torchMode = AVCaptureTorchModeOn;
        } else {
            device.torchMode = AVCaptureTorchModeOff;
        }
        
        [device unlockForConfiguration];
    }
}

- (CGPoint) focusWithCaptureDevice:(AVCaptureDevice *)device
{
    if( device.focusPointOfInterestSupported ) {
        return device.focusPointOfInterest;
    }    
    
    return CGPointMake(0, 0);
}

- (void) setFocus:(CGPoint)p withCaptureDevice:(AVCaptureDevice *)device
{
    NSError *error;
    
    if( device.focusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ) {
        if( [device lockForConfiguration:&error] ) {
            
            device.focusPointOfInterest = p;
            
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - Life cycle -

- (void) capture
{
    if( _session == nil ) {
        return;
    }
    
    if( _isCaptured == NO ) {
        return;
    }
    
    _isCaptured = NO;
        
    if( _capturedImage != nil ) {
        [_capturedImage release];
    }
    _capturedImage = nil;
    
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [_captureStillImageOutput connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { 
            break; 
        }
	}
    
	[_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection 
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             
                                                             if (imageSampleBuffer != NULL) {
                                                                 
                                                                 CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                                 if (exifAttachments) {
                                                                     NSLog(@"attachements: %@", exifAttachments);
                                                                 } else { 
                                                                     NSLog(@"no attachments");
                                                                 }
                                                                                                                          
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];    
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                 _capturedImage = image;
                                                                 
                                                                 [self setValue:[NSNumber numberWithBool:YES] forKey:CAMERA_HELPER_CAPTURE_REQUEST_KEY];
                                                             }
                                                         }];
}

- (void) initialize
{
    _session = [[AVCaptureSession alloc] init];
    
    if ([_session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];	
    
	if (videoDevice == nil) {
        [_session release];
        _session = nil;
        
        NSLog(@"Couldn't create video capture device");
        
        return;
    }
    
    
    NSError *error;
    _videoInput = [[AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error] retain];
    
    if (!error) {
        if ([_session canAddInput:_videoInput]) {
            [_session addInput:_videoInput];
        } else {
            NSLog(@"Couldn't add video input");		
        }
    } else {
        NSLog(@"Couldn't create video input");
    }

    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [_captureStillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
    
    [_session addOutput:_captureStillImageOutput];
    
    _isCaptured = YES;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (id) init
{
    self = [super init];
    
	if ( !self ) {
        return nil;
    }
    
    _session = nil;
    _captureStillImageOutput = nil;
    
    if ( [CameraHelper support] ) {
        [self initialize];
    }
	
	return self;
}

- (void) dealloc
{
    if (_session != nil) {
        [_session release];
        _session = nil;
    }
    
    if (_videoInput != nil ) {
        [_videoInput release];
        _videoInput = nil;
    }
    
    if ( _captureStillImageOutput != nil ) {
        [_captureStillImageOutput release];
        _captureStillImageOutput = nil;
    }
     
	[super dealloc];
}

#pragma mark - Accessor -

- (void) switchCamera
{
    _videoInput = [self switchSideWithCaptureDeviceInput:_videoInput captureSession:_session];
}

- (BOOL) torch
{
    return [self torchWithCaptureDevice:_videoInput.device];
}

- (void) setTorch:(BOOL)torch
{
    if ([self availableTorch]) {
        [self setTorch:torch withCaptureDevice:_videoInput.device];
    }
}
     
- (CameraSide) side
{
    return [self sideWithCaptureDeviceInput:_videoInput];
}

- (BOOL) availableTorch
{
    return _videoInput.device.hasTorch;
}

- (CGPoint) focus
{
    if ([CameraHelper support]) {
        return [self focusWithCaptureDevice:_videoInput.device];
    } else {
        return CGPointMake(0, 0);
    }
}

- (void) setFocus:(CGPoint)focus
{
    if ([CameraHelper support]) {
        [self setFocus:focus withCaptureDevice:_videoInput.device];
    }
}

#pragma mark - Start and Stop -

- (void) startRunning
{
    if( _session != nil ) {
        [_session startRunning];	
    }
}

- (void) stopRunning
{
    if( _session != nil ) {
        [_session stopRunning];
    }
}

#pragma mark - Preview -

- (UIView *) previewViewWithBounds: (CGRect) bounds
{
    return [self previewLayerWithBounds:bounds session:_session];
}

#pragma mark - Key Value Observation -

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key
{
	if ([key isEqualToString:@"isCaptured"] )
    {
		return YES;
	}
	
	return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark - Orientation -

- (void)deviceOrientationDidChange
{	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    
	if (deviceOrientation == UIDeviceOrientationPortrait) {
		orientation = AVCaptureVideoOrientationPortrait;
	} else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	} else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		orientation = AVCaptureVideoOrientationLandscapeRight;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
		orientation = AVCaptureVideoOrientationLandscapeLeft;
	}
    
    [_session beginConfiguration];
    
    {
        AVCaptureConnection *videoConnection = NULL;
        
        for ( AVCaptureConnection *connection in [_captureStillImageOutput connections] ) 
        {
            for ( AVCaptureInputPort *port in [connection inputPorts] ) 
            {
                if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) 
                {
                    videoConnection = connection;
                }
            }
        }
        
        if ([videoConnection isVideoOrientationSupported])
            [videoConnection setVideoOrientation:orientation];
        
    }
    
    [_session commitConfiguration];
}

#pragma mark - Preview -

- (UIView *) previewLayerWithBounds:(CGRect) bounds session:(AVCaptureSession *)session
{
    UIView *view = [[[UIView alloc] initWithFrame:bounds] autorelease];
    
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
	
	previewLayer.frame = bounds;
	previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[view.layer addSublayer:previewLayer];
    
	return view;
}

#pragma mark - Singleton -

static CameraHelper *instance;

+(CameraHelper *) sharedInstance
{
    @synchronized(self)
    {
        if( instance == nil ) {
            instance = [[self alloc] init];
        }
    }

    return instance;
}

+(id) allocWithZone:(NSZone*)zone
{
    @synchronized(self)
    {
		if (instance == nil) {
			instance = [super allocWithZone:zone];
			return instance;
		}
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

-(oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

@end
