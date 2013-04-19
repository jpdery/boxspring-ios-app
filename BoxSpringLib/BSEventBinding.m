//
//  BSEventBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-16.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSEventBinding.h"

@implementation BSEventBinding

BS_DEFINE_BOUND_FUNCTION(addEventListener, addEventListener)
BS_DEFINE_BOUND_FUNCTION(removeEventListener, removeEventListener)
BS_DEFINE_BOUND_FUNCTION(dispatchEvent, dispatchEvent)

- (id)init
{
    if (self = [super init]) {
        listeners = [NSMutableDictionary new];
        callbacks = [NSMutableDictionary new];
    }
    return self;
}

- (void)setEventCallback:(NSString*)event callback:(JSObjectRef)jsCallback
{

}

- (void)getEventCallback:(NSString*)event
{

}

- (void)triggerEvent:(NSString*)event argc:(size_t)argc argv:(const JSValueRef[])argv
{
    NSMutableArray* events = [listeners objectForKey:event];
    if (events == nil)
        return;
    
    for (int i = 0; i < events.count; i++) {
        JSValueRef jsFunction = (JSValueRef) [[events objectAtIndex:i] pointerValue];
        JSObjectCallAsFunction(self.jsContext, (JSObjectRef) jsFunction, self.jsThisObject, argc, argv, NULL);
    }
}

-(JSValueRef)addEventListener:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsType = argv[0];
    JSValueRef jsListener = argv[1];
    
    NSString* type = JSValueToNSString(jsContext, jsType);
    
    NSMutableArray* events = [listeners objectForKey:type];
    if (events == nil) {
        events = [NSMutableArray new];
        [listeners setObject:events forKey:type];
    }

    NSValue* jsListenerValue = [NSValue valueWithPointer:jsListener];
    if ([events containsObject:jsListenerValue] == NO) {
        [events addObject:jsListenerValue];
    }

    return NULL;
}

-(JSValueRef)removeEventListener:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsType = argv[0];
    JSValueRef jsListener = argv[1];
    
    NSString* type = JSValueToNSString(jsContext, jsType);
    
    NSMutableArray* events = [listeners objectForKey:type];
    if (events == nil)
        return NULL;
    
    for (int i = 0; i < events.count; i++) {
        if (JSValueIsStrictEqual(self.jsContext, [[events objectAtIndex:i] pointerValue], jsListener)) {
            [events removeObjectAtIndex:i];
            return NULL;
        }
    }
    
    return NULL;
}

@end
