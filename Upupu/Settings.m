//
//  Settings.m
//  Upupu
//
//  Created by T. Takeuchi on 1/24/12.
//  Copyright 2012 Xcoo, Inc. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+ (BOOL)isWebDAVEnabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"webdav_enabled_pref"];
}

+ (NSString *)webDAVURL
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"webdav_url_pref"];
}

+ (NSString *)webDAVUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"webdav_user_pref"];
}

+ (NSString *)webDAVPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"webdav_pass_pref"];
}

+ (BOOL)isDropboxEnabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"dropbox_enabled_pref"];
}

+ (void)setDropboxEnabled:(BOOL)enabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:@"dropbox_enabled_pref"];
}

+ (NSString *)dropboxAccount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"dropbox_account_pref"];
}

+ (void)dropboxAccount:(NSString *)account
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account forKey:@"dropbox_account_pref"];
}

+ (NSString *)dropboxLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"dropbox_location_pref"];
}

+ (NSInteger)photoQuality
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"photo_quality_pref"];
}

+ (NSInteger)photoResolution
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"photo_resolution_pref"];
}

@end
