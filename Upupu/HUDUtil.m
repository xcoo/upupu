//
//  HUDUtil.m
//  Upupu
//
//  Created by Takashi AOKI on 10/5/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import "HUDUtil.h"

@interface HUDUtilSupport : NSObject <MBProgressHUDDelegate>
@end

@implementation HUDUtilSupport

#pragma mark - MBProgressHUDDelegate -

- (void) hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
}

@end

static HUDUtilSupport *support = nil;

@implementation HUDUtil

+ (MBProgressHUD *) showWithText:(NSString *)text forView:(UIView *)view whileExecuting:(SEL)method onTarget:(id)target
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    
    if( support == nil ) {
        support = [[HUDUtilSupport alloc] init];
    }
    
    hud.delegate = support;
    hud.labelText = text;
    
    [view addSubview:hud];
	[hud showWhileExecuting:method onTarget:target withObject:nil animated:YES];

    return hud;
}

@end
