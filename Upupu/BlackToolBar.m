//
//  BlackToolBar.m
//  Upupu
//
//  Created by Takashi Aoki on 3/2/12.
//  Copyright 2012 Xcoo, Inc. All rights reserved.
//

#import "BlackToolBar.h"

@implementation BlackToolBar

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.1 alpha:1.0].CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, self.bounds.size.width, 2.0));
    CGContextFillRect(context, CGRectMake(0.0, self.bounds.size.height - 2.0, self.bounds.size.width, self.bounds.size.height));
}

@end
