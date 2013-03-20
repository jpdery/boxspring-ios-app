//
//  BSViewBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGViewBinding.h"

@implementation BGViewBinding

BG_DEFINE_BOUND_FUNCTION(draw, draw);

/**
 * @binding
 * @since 0.0.1
 */
- (JSValueRef)draw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

@end
