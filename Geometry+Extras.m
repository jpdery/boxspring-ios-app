//
//  Geometry.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-24.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "Geometry+Extras.h"

CGPoint
CGPointFromJSObject(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSValueRef jsX = JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("x"), NULL);
    JSValueRef jsY = JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("y"), NULL);
    return CGPointMake(
        JSValueToNumber(jsContext, jsX, NULL),
        JSValueToNumber(jsContext, jsY, NULL)
    );
}

CGSize
CGSizeFromJSObject(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSValueRef jsX = JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("x"), NULL);
    JSValueRef jsY = JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("y"), NULL);
    return CGSizeMake(
        JSValueToNumber(jsContext, jsX, NULL),
        JSValueToNumber(jsContext, jsY, NULL)
    );
}

CGRect
CGRectFromJSObject(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSObjectRef jsOrigin = (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("origin"), NULL);
    JSObjectRef jsSize = (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("size"), NULL);
    CGPoint origin = CGPointFromJSObject(jsContext, jsOrigin);
    CGSize size = CGSizeFromJSObject(jsContext, jsSize);
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}
