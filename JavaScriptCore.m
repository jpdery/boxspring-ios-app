//
//  NSData+JavaScriptCore.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "JavaScriptCore.h"
#import "NSString+JavaScriptCoreString.h"


JSObjectRef JSObjectCreate(JSContextRef jsContext, JSObjectRef jsPrototype)
{
    JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
    jsClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    JSClassRef jsClass = JSClassCreate(&jsClassDef);
    JSObjectRef jsObject = JSObjectMake(jsContext, jsClass, NULL);
    JSObjectSetPrototype(jsContext, jsObject, (JSValueRef)jsPrototype);
    return jsObject;
}



void JSObjectInherit(JSContextRef jsContext, JSObjectRef jsObject, NSString* inherit)
{
    JSStringRef jsPrototypeString = JSStringCreateWithUTF8CString("prototype");
    JSObjectRef jsGlobal = JSContextGetGlobalObject(jsContext);
    JSObjectRef jsConstruct = (JSObjectRef) JSObjectGetProperty(jsContext, jsGlobal, [inherit jsStringValue], NULL);
    JSObjectRef jsPrototype = (JSObjectRef) JSObjectGetProperty(jsContext, jsConstruct, jsPrototypeString, NULL);
    JSObjectSetPrototype(jsContext, jsObject, jsPrototype);
    JSStringRelease(jsPrototypeString);
}

void JSObjectSetParentProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsParent)
{
    JSStringRef jsParentString = JSStringCreateWithUTF8CString("parent");
    JSObjectSetProperty(jsContext, jsObject, jsParentString, jsParent, kJSPropertyAttributeDontDelete, NULL);
    JSStringRelease(jsParentString);
}

void JSObjectSetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype)
{
    JSStringRef jsPrototypeString = JSStringCreateWithUTF8CString("prototype");
    JSObjectSetProperty(jsContext, jsObject, jsPrototypeString, jsPrototype, kJSPropertyAttributeDontDelete, NULL);
    JSStringRelease(jsPrototypeString);
}

JSObjectRef JSObjectGetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSStringRef jsPrototypeString = JSStringCreateWithUTF8CString("prototype");
    JSObjectRef jsPrototype =  (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, jsPrototypeString, NULL);
    JSStringRelease(jsPrototypeString);
    return jsPrototype;
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