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

@implementation BSTimerInfo
    @synthesize jsCallback;
    @synthesize jsInterval;
    @synthesize identifier;
    @synthesize repeat;
@end

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
    JSValueRef jsCallback = argv[0];
    JSValueRef jsInterval = argv[1];
    double interval = JSValueToNumber(jsContext, jsInterval, NULL);

    lastIntervalId++;

    BSTimerInfo* infos = [BSTimerInfo new];
    infos.jsCallback = jsCallback;
    infos.jsInterval = jsInterval;
    infos.identifier = lastIntervalId;
    infos.repeat = YES;

    JSValueProtect(jsContext, jsCallback);
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:(interval / 1000) target:self selector:@selector(tick:) userInfo:infos repeats:YES];
    [timers setObject:timer forKey:@(lastIntervalId)];
   
    return JSValueMakeNumber(jsContext, lastTimerId);
}

- (JSValueRef)clearInterval:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    int identifier = JSValueToNumber(jsContext, argv[0], NULL);

    NSTimer* timer = [timers objectForKey:@(identifier)];
    [timer invalidate];
    [timers removeObjectForKey:@(identifier)];

    return NULL;
}

- (JSValueRef)setTimeout:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsCallback = argv[0];
    JSValueRef jsInterval = argv[1];
    double interval = JSValueToNumber(jsContext, jsInterval, NULL);

    lastIntervalId++;

    BSTimerInfo* infos = [BSTimerInfo new];
    infos.jsCallback = jsCallback;
    infos.jsInterval = jsInterval;
    infos.identifier = lastIntervalId;
    infos.repeat = NO;

    JSValueProtect(jsContext, jsCallback);
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:(interval / 1000) target:self selector:@selector(tick:) userInfo:infos repeats:YES];
    [timers setObject:timer forKey:@(lastIntervalId)];
   
    return JSValueMakeNumber(jsContext, lastTimerId);
}

- (JSValueRef)clearTimeout:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    int identifier = JSValueToNumber(jsContext, argv[0], NULL);

    NSTimer* timer = [timers objectForKey:@(identifier)];
    [timer invalidate];
    [timers removeObjectForKey:@(identifier)];
    
    return NULL;
}

- (void)tick:(NSTimer*)timer
{
    BSTimerInfo* info = (BSTimerInfo*)[timer userInfo];

    JSObjectRef jsCallback = (JSObjectRef)info.jsCallback;

    JSObjectCallAsFunction(
        self.jsContext,
        jsCallback,
        NULL, 0, NULL, NULL
    );

    if (info.repeat == NO) {
        [timer invalidate];
        [timers removeObjectForKey:@(info.identifier)];
    }
}

@end
