//
//  Settings.h
//  Upupu
//
//  Created by T. Takeuchi on 1/24/12.
//  Copyright 2012 Xcoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

// WebDAV
+ (BOOL)isWebDAVEnabled;
+ (NSString *)webDAVURL;
+ (NSString *)webDAVUser;
+ (NSString *)webDAVPassword;

// Dropbox
+ (BOOL)isDropboxEnabled;
+ (void)setDropboxEnabled:(BOOL)enabled;
+ (NSString *)dropboxAccount;
+ (void)dropboxAccount:(NSString *)account;

// Photo
+ (int)photoQuality;
+ (int)photoResolution;

@end
