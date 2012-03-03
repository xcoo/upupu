//
//  UpupuAppDelegate.m
//  Upupu
//
//  Created by David Ott on 11/23/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import "UpupuAppDelegate.h"

#import "CameraController.h"
#import "DropboxUploader.h"

#import "Settings.h"

@implementation UpupuAppDelegate

@synthesize window = _window;

#pragma mark - Application lifecycle -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    CameraController *controller = [[CameraController alloc] init];
    [[self window] setRootViewController:controller];
    [controller release];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [[DropboxUploader sharedInstance] handleURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    SAFE_RELEASE(_window)
    
    [super dealloc];
}

@end
