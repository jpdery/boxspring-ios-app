//
//  BSViewBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "Geometry+Extras.h"
#import "BSContextBinding.h"
#import "BSBoundView.h"
#import "BSViewBinding.h"

@implementation BSViewBinding

@synthesize view;
@synthesize viewContextBinding;

- (void)loadViewWithRect:(CGRect)rect
{
    self.view = [[BSBoundView alloc] initWithFrame:rect andViewBinding:self];
}

- (void)viewDidDraw:(BSBoundView*)view inRect:(CGRect)rect
{
    if (self.viewContextBinding == nil) {
        self.viewContextBinding = [[BSContextBinding alloc] initWithScriptView:self.scriptView];
    }

    JSObjectRef jsRectConstructor = [[self.scriptView.primeConstructors objectForKey:@"boxspring.Rect"] jsObject];
    
    JSValueRef argv[4];
    argv[0] = JSValueMakeNumber(self.jsContext, rect.origin.x);
    argv[1] = JSValueMakeNumber(self.jsContext, rect.origin.y);
    argv[2] = JSValueMakeNumber(self.jsContext, rect.size.width);
    argv[3] = JSValueMakeNumber(self.jsContext, rect.size.height);

    JSObjectRef jsRect = JSObjectCallAsConstructor(self.jsContext, jsRectConstructor, 4, argv, NULL);
    
    self.viewContextBinding.context = UIGraphicsGetCurrentContext();

    JSValueRef drawArgv[2];
    drawArgv[0] = self.viewContextBinding.jsBoundObject;
    drawArgv[1] = jsRect;

    [self call:@"draw" argc:2 argv:drawArgv from:kBSBindingContextObjectSelf];
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
    NSLog(@"BSViewBinding constructor called");

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
        rect = self.view.bounds;
    }

    [self.view setNeedsDisplayInRect:rect];

    return NULL;
}
@end
