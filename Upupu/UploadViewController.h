//
//  UploadViewControllerDelegate.h
//  Upupu
//
//  Created by David Ott on 11/23/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UploadViewControllerDelegate <NSObject>
@optional
- (void) uploadViewControllerDidReturn:(UIViewController *)controller;
- (void) uploadViewControllerDidFinished:(UIViewController *)controller;
- (void) uploadViewControllerDidSetup:(UIViewController *)controller;
@end

@interface UploadViewController : UIViewController

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) id<UploadViewControllerDelegate> delegate;
@property (nonatomic) BOOL savePhotoAlbum;

@end
