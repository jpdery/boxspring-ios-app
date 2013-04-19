//
//  BSRWindowBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-19.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBoundWindow.h"
#import "BSWindowBinding.h"

@implementation BSWindowBinding

- (void)loadViewWithRect:(CGRect)rect
{
    self.view = [[BSBoundWindow alloc] initWithFrame:rect binding:self];
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
