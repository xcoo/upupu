//
//  HUDUtil.h
//  Upupu
//
//  Created by Takashi AOKI on 10/5/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD/MBProgressHUD.h"

@interface HUDUtil : NSObject

+ (MBProgressHUD *) showWithText:(NSString *)text forView:(UIView *)view whileExecuting:(SEL)method onTarget:(id)target;

@end
