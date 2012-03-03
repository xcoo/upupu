//
//  CameraHelper.h
//  Upupu
//
//  Created by Takashi AOKI on 9/07/10.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CameraSideFront,
    CameraSideBack,
} CameraSide;

#define CAMERA_HELPER_CAPTURE_REQUEST_KEY @"isCaptured"

@interface CameraHelper : NSObject

+ (CameraHelper *) sharedInstance;

@property (nonatomic, readonly) UIImage *capturedImage;

@property (nonatomic) BOOL isCaptured;

@property (nonatomic, readonly) CameraSide side;
@property (nonatomic) BOOL torch;
@property (nonatomic) CGPoint focus;

- (void) startRunning;
- (void) stopRunning;

- (void) capture;

- (void) switchCamera; // switch front camera and back camera
- (BOOL) availableTorch;

- (UIView *) previewViewWithBounds: (CGRect) bounds;

+ (BOOL) support;
+ (BOOL) supportFrontCamera;
+ (BOOL) supportTorch;

@end
