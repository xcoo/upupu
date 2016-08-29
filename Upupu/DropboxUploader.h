//
//  Dropbox.h
//  Upupu
//
//  Created by T. Takeuchi on 1/24/12.
//  Copyright 2012 Xcoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropboxUploader : NSObject

@property (nonatomic, readonly) BOOL success;

+ (id) sharedInstance;

- (void) linkFromController:(UIViewController *)controller;
- (BOOL) isLinked;

- (void) uploadWithName:(NSString *)filename imageData:(NSData *)imageData;

- (BOOL) handleURL:(NSURL *)url;

@end
