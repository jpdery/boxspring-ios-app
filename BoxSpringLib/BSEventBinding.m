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
        events = [NSMutableDictionary new];
    }
    
    return self;
}

-(JSValueRef)addEventListener:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsType = argv[0];
    JSValueRef jsListener = argv[1];
    
    NSString* type = JSValueToNSString(jsContext, jsType);
    
    NSMutableArray* listeners = [events objectForKey:type];
    if (listeners == nil) {
        listeners = [NSMutableArray new];
    }

//    NSData* listener = [NSData dataWithJSValueRef:jsListener];
//    if ([listeners containsObject:listener] == NO) {
  //      [listeners addObject:listener];
   // }

    return NULL;
}

-(JSValueRef)removeEventListener:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSValueRef jsType = argv[0];
    JSValueRef jsListener = argv[1];
    
    NSString* type = JSValueToNSString(jsContext, jsType);
    
    NSMutableArray* listeners = [events objectForKey:type];
    if (listeners == nil)
        return NULL;

//    NSData* listener = [NSData dataWithJSValueRef:jsListener];
//    [listeners removeObject:listener];
    
    return NULL;
}

-(JSValueRef)dispatchEvent:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef[])argv
{
    return NULL;
}

@end
