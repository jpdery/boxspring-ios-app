//
//  NSData+JavaScriptCore.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-19.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSData+JavaScriptCore.h"

@implementation NSData (JavaScriptCore)


+ (NSData*)dataWithJSValueRef:(JSValueRef)jsValue
{
    return [NSData dataWithBytes:&jsValue length:sizeof(JSValueRef)];
}

+ (NSData*)dataWithJSObjectRef:(JSObjectRef)jsObject
{
    return [NSData dataWithBytes:&jsObject length:sizeof(JSObjectRef)];
}

- (JSValueRef)jsValue
{
    JSValueRef jsValue;
    [self getBytes:&jsValue length:sizeof(JSValueRef)];
    return jsValue;
}

- (JSObjectRef)jsObject
{
    JSObjectRef jsObject;
    [self getBytes:&jsObject length:sizeof(JSObjectRef)];
    return jsObject;
}

@end
