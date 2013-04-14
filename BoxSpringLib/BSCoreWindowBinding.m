//
//  BSCoreWindowBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-13.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"
#import "BSCoreWindowBinding.h"

@implementation BSCoreWindowBinding

BS_DEFINE_BOUND_FUNCTION(setInterval, setInterval);
BS_DEFINE_BOUND_FUNCTION(clearInterval, clearInterval);
BS_DEFINE_BOUND_FUNCTION(setTimeout, setTimeout);
BS_DEFINE_BOUND_FUNCTION(clearTimeout, clearTimeout);

- (id)init
{
    if (self = [super init]) {
        timers = [NSMutableDictionary new];
    }
    
    return self;
}

- (JSValueRef)setInterval:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    NSLog(@"Set Interval");

    JSValueRef jsFunction = argv[0];
    JSValueRef jsDelay = argv[1];
    double delay = JSValueToNumber(jsContext, jsDelay, NULL);

    JSValueProtect(jsContext, jsFunction);

    lastTimerId++;

    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSData dataWithJSObjectRef:(JSObjectRef)jsFunction], @"callback",
        [NSNumber numberWithInt:lastTimerId], @"identifier",
        nil];

    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:(delay / 1000) target:self selector:@selector(tick:) userInfo:data repeats:YES];
    [timers setObject:timer forKey:@(lastTimerId)];



    return JSValueMakeNumber(jsContext, lastTimerId);
}

- (JSValueRef)clearInterval:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    NSLog(@"Clear Interval");
    JSValueRef jsIdentifier = argv[0];
    
    int identifier = JSValueToNumber(jsContext, jsIdentifier, NULL);
    
    NSTimer* timer = [timers objectForKey:@(identifier)];
    [timer invalidate];
    [timers removeObjectForKey:@(identifier)];

    return NULL;
}


- (JSValueRef)setTimeout:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsFunction = argv[0];
    JSValueRef jsDelay = argv[1];
    double delay = JSValueToNumber(jsContext, jsDelay, NULL);

    JSValueProtect(jsContext, jsFunction);

    lastTimerId++;

    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSData dataWithJSObjectRef:(JSObjectRef)jsFunction], @"callback",
        [NSNumber numberWithInt:lastTimerId], @"identifier",
        nil];

    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:(delay / 1000) target:self selector:@selector(tick:) userInfo:data repeats:NO];
    [timers setObject:timer forKey:@(lastTimerId)];

    return JSValueMakeNumber(jsContext, lastTimerId);
}


- (JSValueRef)clearTimeout:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsIdentifier = argv[0];
    
    int identifier = JSValueToNumber(jsContext, jsIdentifier, NULL);
    
    NSTimer* timer = [timers objectForKey:@(identifier)];
    [timer invalidate];
    [timers removeObjectForKey:@(identifier)];
    
    return NULL;
}

- (void)tick:(NSTimer*)timer
{
//    static int count = 0;
    
//    NSLog(@"Tick %i", ++count);

    NSDictionary* data = [timer userInfo];
    JSObjectRef jsCallback = [[data objectForKey:@"callback"] jsObject];
    //NSNumber* identifier = [data objectForKey:@"identifier"];
   // int ident = [identifier intValue];
    
    //[timers removeObjectForKey:@(ident)];
    
//    NSLog(@"Callback %@", jsCallback ? @"Yes" : @"no");
    
    JSObjectCallAsFunction(self.jsContext, jsCallback, NULL, 0, NULL, NULL);
    
}

@end
