//
//  AlertUtil.h
//  Upupu
//
//  Created by Takashi AOKI on 3/11/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertUtil : NSObject

+ (void) showWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (void) showWithTitle:(NSString *)title andMessage:(NSString *)message andDelegate:(id)delegate;

@end
