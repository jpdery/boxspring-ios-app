//
//  BSRWindowBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-19.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGWindowBinding.h"

@implementation BGWindowBinding

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Init window");
    [super constructor:jsContext argc:argc argv:argv];
    [self.scriptView addSubview:self.view];
    return NULL;
}

@end
