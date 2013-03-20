//
//  BSViewBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGViewBinding.h"
#import "BGView.h"

@implementation BGViewBinding

BG_DEFINE_BOUND_FUNCTION(draw, draw);

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    if (argc != 4) {
        NSLog(@"View must be instantiated with its size and coordinates");
    }
    
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[2], NULL);
    double h = JSValueToNumber(jsContext, argv[3], NULL);
    
    view = [[BGView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    view.backgroundColor = [UIColor redColor];

    [self.scriptView addSubview:view];
    
    return NULL;
}

- (JSValueRef)draw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"ViewBindingDraw");
    return NULL;
}

@end
