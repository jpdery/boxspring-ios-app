//
//  BSViewBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGViewBinding.h"

@implementation BGViewBinding

BG_BIND_FUNCTION(draw, draw)
- (JSValueRef)draw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"CAlling draw");
    return NULL;
}



@end
