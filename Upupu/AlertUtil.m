//
//  AlertUtil.m
//  Upupu
//
//  Created by Takashi AOKI on 3/11/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import "AlertUtil.h"


@implementation AlertUtil

+(void) showWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil] autorelease];

    [alert show];
}

+(void) showWithTitle:(NSString *)title andMessage:(NSString *)message andDelegate:(id)delegate
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil] autorelease];
    
    [alert show];
}

@end
