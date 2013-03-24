//
//  BSRWindowBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-19.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSWindowBinding.h"
#import "BSWindow.h"

@implementation BSWindowBinding

- (void)loadViewWithRect:(CGRect)rect
{
    self.view = [[BSWindow alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
}

/**
 * Bound Method
 */
- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    JSValueRef this = [super constructor:jsContext argc:argc argv:argv];
    [self.scriptView addSubview:self.view];
    return this;
}

@end
