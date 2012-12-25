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
@end

@implementation CameraController

- (id)init
{
    self = [super init];
    
    if ( !self ) {
        return nil;
    }
    
    CameraViewController *controller = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    controller.delegate = self;
        
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationBar.hidden = YES;
    
    [self pushViewController:controller animated:NO];
    [controller release];
    
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
    [super viewDidUnload];
}

- (void) dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - CameraViewControllerDelegate -

-(void) cameraViewController:(UIViewController *)viewController didFinishedWithImage:(UIImage *)image
{
    UploadViewController *controller = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
    controller.image = image;
    controller.delegate = self;
    
    CameraViewController *cameraViewController = (CameraViewController *)viewController;
    controller.savePhotoAlbum = !cameraViewController.isSourcePhotoLibrary;
    
    [self pushViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark - UploadViewControllerDelegate -

- (void) uploadViewControllerDidReturn:(UIViewController *)controller
{
    [self popViewControllerAnimated:YES];
}

- (void) uploadViewControllerDidFinished:(UIViewController *)controller
{
    [self popViewControllerAnimated:YES];
}

- (void) uploadViewControllerDidSetup:(UIViewController *)controller
{
    IASKAppSettingsViewController *settingsController = [[IASKAppSettingsViewController alloc] init];
    settingsController.delegate = self;
    settingsController.showCreditsFooter = NO;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    navController.navigationBar.tintColor = [UIColor blackColor];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navController animated:YES];
    
    [navController release];
    [settingsController release];
}

#pragma mark - IASKSettingsDelegate -

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender 
{
    [sender dismissModalViewControllerAnimated:YES];
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForKey:(NSString *)key 
{
	if ([key isEqualToString:@"dropbox_link_pref"]) {
        [[DropboxUploader sharedInstance] linkFromController:sender];
    }
    
    [sender dismissModalViewControllerAnimated:YES];
}

@end
