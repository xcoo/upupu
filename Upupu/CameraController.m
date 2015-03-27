//
//  CameraController.m
//  Upupu
//
//  Created by Takashi AOKI on 4/22/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import "CameraController.h"

#import "CameraViewController.h"
#import "UploadViewController.h"
#import "IASKAppSettingsViewController.h"

#import "DropboxUploader.h"

@interface CameraController() <CameraViewControllerDelegate, UploadViewControllerDelegate, IASKSettingsDelegate>

@property (nonatomic, retain) CameraViewController *cameraViewController;
@property (nonatomic, retain) UploadViewController *uploadViewController;

@end

@implementation CameraController

- (id)init
{
    self = [super init];
    
    if ( !self ) {
        return nil;
    }
    
    self.cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController"
                                                                       bundle:nil];
    _cameraViewController.delegate = self;
    
    self.uploadViewController = [[UploadViewController alloc] initWithNibName:@"UploadViewController"
                                                                       bundle:nil];
    _uploadViewController.delegate = self;
        
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationBar.hidden = YES;
    
    [self pushViewController:_cameraViewController animated:NO];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    SAFE_RELEASE(_cameraViewController)
    SAFE_RELEASE(_uploadViewController)
    
    [super viewDidUnload];
}

- (void) dealloc
{
    SAFE_RELEASE(_cameraViewController)
    SAFE_RELEASE(_uploadViewController)
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - CameraViewControllerDelegate -

-(void) cameraViewController:(UIViewController *)viewController didFinishedWithImage:(UIImage *)image
{
    _uploadViewController.image = image;
    
    CameraViewController *cameraViewController = (CameraViewController *)viewController;
    _uploadViewController.savePhotoAlbum = !cameraViewController.isSourcePhotoLibrary;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self pushViewController:_uploadViewController animated:YES];
}

#pragma mark - UploadViewControllerDelegate -

- (void) uploadViewControllerDidReturn:(UIViewController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self popViewControllerAnimated:YES];
}

- (void) uploadViewControllerDidFinished:(UIViewController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self popViewControllerAnimated:YES];
}

- (void) uploadViewControllerDidSetup:(UIViewController *)controller
{
    IASKAppSettingsViewController *settingsController = [[IASKAppSettingsViewController alloc] init];
    settingsController.delegate = self;
    settingsController.showCreditsFooter = NO;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    [navController release];
    [settingsController release];
}

#pragma mark - IASKSettingsDelegate -

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender 
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [sender dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForKey:(NSString *)key 
{
	if ([key isEqualToString:@"dropbox_link_pref"]) {
        [[DropboxUploader sharedInstance] linkFromController:sender];
    }
    
    [sender dismissViewControllerAnimated:YES completion:nil];
}

@end
