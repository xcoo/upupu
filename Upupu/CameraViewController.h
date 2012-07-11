//
//  CameraViewController.h
//  Upupu
//
//  Created by Takashi AOKI on 4/8/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewControllerDelegate <NSObject>
@optional
-(void) cameraViewController:(UIViewController *) viewController didFinishedWithImage:(UIImage *)image;
@end

@interface CameraViewController : UIViewController

@property (nonatomic, assign) id<CameraViewControllerDelegate> delegate;
@property (nonatomic) BOOL isSourcePhotoLibrary;

@end