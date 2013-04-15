//
//  BSCoreWindowBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-13.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"

@interface BSTimerInfo : NSObject
    @property(nonatomic) JSValueRef jsCallback;
    @property(nonatomic) JSValueRef jsInterval;
    @property(nonatomic, assign) int identifier;
    @property(nonatomic, assign) BOOL repeat;
@end

@interface BSCoreWindowBinding : BSBinding {
    NSMutableDictionary* timers;
    int lastTimerId;
    int lastIntervalId;
}

- (void)tick:(NSTimer*)timer;

- (JSValueRef)setInterval:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSValueRef)clearInterval:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSValueRef)setTimeout:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSValueRef)clearTimeout:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv;

@end
