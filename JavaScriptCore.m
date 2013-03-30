//
//  NSData+JavaScriptCore.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "JavaScriptCore.h"


JSObjectRef JSObjectCreate(JSContextRef jsContext, JSObjectRef jsPrototype)
{
    JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
    jsClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    JSClassRef jsClass = JSClassCreate(&jsClassDef);
    JSObjectRef jsObject = JSObjectMake(jsContext, jsClass, NULL);
    JSObjectSetPrototype(jsContext, jsObject, (JSValueRef)jsPrototype);
    return jsObject;
}

void JSCopyProperties(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsObjectFrom)
{
    JSPropertyNameArrayRef jsProperties = JSObjectCopyPropertyNames(jsContext, jsObjectFrom);
        
    size_t count = JSPropertyNameArrayGetCount(jsProperties);
    
    for (int i = 0; i < count; i++) {
        JSStringRef jsProperty = JSPropertyNameArrayGetNameAtIndex(jsProperties, i);
        JSObjectSetProperty(
            jsContext,
            jsObject,
            jsProperty,
            JSObjectGetProperty(jsContext, jsObjectFrom, jsProperty, NULL),
            kJSPropertyAttributeNone,
            NULL
        );
    }
}

void JSLogProps(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSPropertyNameArrayRef jsProperties = JSObjectCopyPropertyNames(jsContext, jsObject);
        
    size_t count = JSPropertyNameArrayGetCount(jsProperties);
    NSLog(@"Properties : (%zu)", count);
    for (int i = 0; i < count; i++) {
        JSStringRef jsProperty = JSPropertyNameArrayGetNameAtIndex(jsProperties, i);
        NSLog(@"Property %@", [NSString stringWithJSString:jsProperty]);
    }
}