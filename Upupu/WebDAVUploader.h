//
//  Uploader.h
//  Upupu
//
//  Created by David Ott on 11/18/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMWebDAVRequest.h"


@interface WebDAVUploader : NSObject

@property (nonatomic, readonly) BOOL success;

- (id) initWithName:(NSString *)fileName imageData:(NSData *) imageData;
- (void) upload; 

@end
