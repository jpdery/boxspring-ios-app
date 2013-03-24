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

@synthesize view;

BG_DEFINE_BOUND_FUNCTION(addChildAt, addChildAt);
BG_DEFINE_BOUND_FUNCTION(draw, draw);
BG_DEFINE_BOUND_FUNCTION(redraw, redraw);
BG_DEFINE_BOUND_FUNCTION(reflow, reflow);

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Calling view constructor");

//    if (argc != 4) {
//        NSLog(@"View must be instantiated with its size and coordinates");
//    }
    
  //  double x = JSValueToNumber(jsContext, argv[0], NULL);
//    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[0], NULL);
    double h = JSValueToNumber(jsContext, argv[1], NULL);
    
    
    
    view = [[BGView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    view.backgroundColor = [UIColor redColor];

    [self.scriptView addSubview:view];
    
//   const JSValueRef []

    JSValueRef* jsValues = calloc(2, sizeof(JSValueRef));
    jsValues[0] = JSValueMakeNumber(self.jsContext, 1.0);
    jsValues[1] = JSValueMakeNumber(self.jsContext, 2.0);
    
    [self callJSFunction:@"marde" argc:2 argv:jsValues];
    
    free(jsValues);
    
    return NULL;
}

- (JSValueRef)addChildAt:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSAssert(argc == 2, @"This method must be called with two arguments");
  
    
    int index = JSValueToNumber(jsContext, argv[1], NULL);
    BGView* childView = ((BGViewBinding*)JSObjectGetPrivate((JSObjectRef)argv[0])).view;

    [self.view insertSubview:childView atIndex:index];
    
    return [self callJSFunction:@"addChildAt" argc:argc argv:argv];
}

- (JSValueRef)draw:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"ViewBindingDraw");

    return [self callJSFunction:@"draw" argc:argc argv:argv];
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
