//
//  BSViewBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSViewBinding.h"
#import "BSView.h"

@implementation BSViewBinding

@synthesize view;

BS_DEFINE_BOUND_FUNCTION(addChildAt, addChildAt);
BS_DEFINE_BOUND_FUNCTION(draw, draw);
BS_DEFINE_BOUND_FUNCTION(redraw, redraw);
BS_DEFINE_BOUND_FUNCTION(reflow, reflow);

- (void)loadViewWithRect:(CGRect)rect
{
    self.view = [[BSView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor redColor];
}

/**
 * Bound Method
 */
- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"CAlling BSViewBinding constructor");

    double w = 0;
    double h = 0;
    double x = 0;
    double y = 0;

    if (argc >= 2) {
        w = JSValueToNumber(jsContext, argv[0], NULL);
        h = JSValueToNumber(jsContext, argv[1], NULL);
    }

    if (argc == 4) {
        x = JSValueToNumber(jsContext, argv[0], NULL);
        y = JSValueToNumber(jsContext, argv[1], NULL);
    }
    
    [self loadViewWithRect:CGRectMake(x, y, w, h)];

    return [super constructor:jsContext argc:argc argv:argv];
}

/**
 * Bound Method
 */
- (JSValueRef)addChildAt:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    int index = JSValueToNumber(jsContext, argv[1], NULL);
    
    BSViewBinding* childViewBinding = JSObjectGetPrivate((JSObjectRef)argv[0]);
    
    [self.view
        insertSubview:childViewBinding.view
        atIndex:index];
    
    return [self parent:@"addChildAt" argc:argc argv:argv];
}

/**
 * Bound Method
 */
- (JSValueRef)draw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"ViewBindingDraw");

    return [self parent:@"draw" argc:argc argv:argv];
}


- (JSValueRef)reflow:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

- (JSValueRef)redraw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}
@end