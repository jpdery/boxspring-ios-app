//
//  BSViewBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSViewBinding.h"
#import "Geometry+Extras.h"

@implementation BSViewBinding

@synthesize view;

- (void)loadViewWithRect:(CGRect)rect
{
    self.view = [[BSView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor redColor];
}

/*
 * Bound Methods
 */

BS_DEFINE_BOUND_FUNCTION(addChildAt, addChildAt);
BS_DEFINE_BOUND_FUNCTION(redraw, redraw);
BS_DEFINE_BOUND_FUNCTION(reflow, reflow);

/**
 * Bound Method
 */
- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    JSValueRef jsThis = [super constructor:jsContext argc:argc argv:argv];
    
    double w = 0;
    double h = 0;
    double x = 0;
    double y = 0;

    if (argc >= 2) {
        w = JSValueToNumber(jsContext, argv[0], NULL);
        h = JSValueToNumber(jsContext, argv[1], NULL);
    }

    if (argc == 4) {
        x = JSValueToNumber(jsContext, argv[2], NULL);
        y = JSValueToNumber(jsContext, argv[3], NULL);
    }
    
    [self loadViewWithRect:CGRectMake(x, y, w, h)];
    
    return jsThis;
}

/**
 * Bound Method
 */
- (JSValueRef)addChildAt:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    int index = JSValueToNumber(jsContext, argv[1], NULL);
    
    BSViewBinding* childViewBinding = (BSViewBinding*)JSObjectGetBoundObject(jsContext, (JSObjectRef)argv[0]);

    [self.view
        insertSubview:childViewBinding.view
        atIndex:index];
    
    return [self call:@"addChildAt" argc:argc argv:argv];
}

/**
 * Bound Method
 */
- (JSValueRef)reflow:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

/**
 * Bound Method
 */
- (JSValueRef)redraw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGRect rect;
    if (argc == 1) {
        rect = CGRectFromJSObject(jsContext, (JSObjectRef)argv[0]);
    } else {
        rect = self.view.frame;
    }

    [self.view setNeedsDisplayInRect:rect];

    return NULL;
}
@end
