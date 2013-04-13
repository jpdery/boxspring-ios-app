//
//  NSData+JavaScriptCore.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "UIColor+HTMLColors.h"
#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"
#import "JavaScriptCore+Extras.h"
#import "BSBinding.h"

/* 
 * Properties
 */

void
JSObjectSetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsVal)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("prototype");
    JSObjectSetProperty(jsContext, jsObject, jsKey, jsVal, kJSPropertyAttributeDontDelete, NULL);
    JSStringRelease(jsKey);
}

JSObjectRef
JSObjectGetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("prototype");
    JSObjectRef jsVal = (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, jsKey, NULL);
    JSStringRelease(jsKey);
    return jsVal;
}

void
JSObjectSetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsVal)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("constructor");
    JSObjectSetProperty(jsContext, jsObject, jsKey, jsVal, kJSPropertyAttributeDontDelete, NULL);
    JSStringRelease(jsKey);
}

JSObjectRef
JSObjectGetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("constructor");
    JSObjectRef jsVal = (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, jsKey, NULL);
    JSStringRelease(jsKey);
    return jsVal;
}

void
JSObjectSetParentProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsVal)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("parent");
    JSObjectSetProperty(jsContext, jsObject, jsKey, jsVal, kJSPropertyAttributeDontDelete, NULL);
    JSStringRelease(jsKey);
}

JSObjectRef
JSObjectGetParentProperty(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("parent");
    JSObjectRef jsVal = (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, jsKey, NULL);
    JSStringRelease(jsKey);
    return jsVal;
}

void
JSObjectCopyProperties(JSContextRef jsContext, JSObjectRef jsFrom, JSObjectRef jsDest)
{
    JSPropertyNameArrayRef jsProperties = JSObjectCopyPropertyNames(jsContext, jsFrom);

    size_t count = JSPropertyNameArrayGetCount(jsProperties);

    for (int i = 0; i < count; i++) {
        JSStringRef jsProperty = JSPropertyNameArrayGetNameAtIndex(jsProperties, i);
        JSObjectSetProperty(
            jsContext,
            jsDest,
            jsProperty,
            JSObjectGetProperty(jsContext, jsFrom, jsProperty, NULL),
            kJSPropertyAttributeNone,
            NULL
        );
    }
}

/* 
 * Bindings
 */

static NSMutableDictionary* jsObjectMapping = nil;

void
JSObjectSetBoundObject(JSContextRef jsContext, JSObjectRef jsObject, BSBinding* binding)
{
    static int instances = 0;

    if (jsObjectMapping == nil) {
        jsObjectMapping = [NSMutableDictionary new];
    }

    NSString* identifier = [NSString stringWithFormat:@"instance#%i", instances++];

    JSObjectSetProperty(
        jsContext,
        jsObject,
        JSStringCreateWithUTF8CString("__instance_id"),
        JSValueMakeString(jsContext, [identifier jsStringValue]),
        kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly,
        NULL
    );
    
    [jsObjectMapping setObject:binding forKey:identifier];
}

BSBinding*
JSObjectGetBoundObject(JSContextRef jsContext, JSObjectRef jsObject)
{
    if (jsObjectMapping == nil)
        return nil;

    JSValueRef jsIntanceId = JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("__instance_id"), NULL);
    if (jsIntanceId == NULL)
        return nil;

    return [jsObjectMapping objectForKey:[NSString stringWithJSString:JSValueToStringCopy(jsContext, jsIntanceId, NULL)]];
}

/*
 * Convenience 
 */

void
JSObjectInheritFunction(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSObjectRef jsGlobalObject = JSContextGetGlobalObject(jsContext);
    JSStringRef jsFunctionString = JSStringCreateWithUTF8CString("Function");
    JSObjectRef jsFunctionConstruct = (JSObjectRef) JSObjectGetProperty(jsContext, jsGlobalObject, jsFunctionString, NULL);
    JSObjectRef jsFunctionPrototype = JSObjectGetPrototypeProperty(jsContext, jsFunctionConstruct);
    JSObjectSetPrototype(jsContext, jsObject, jsFunctionPrototype);
    JSStringRelease(jsFunctionString);
}

void
JSObjectInheritObject(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSObjectRef jsGlobalObject = JSContextGetGlobalObject(jsContext);
    JSStringRef jsFunctionString = JSStringCreateWithUTF8CString("Object");
    JSObjectRef jsFunctionConstruct = (JSObjectRef) JSObjectGetProperty(jsContext, jsGlobalObject, jsFunctionString, NULL);
    JSObjectRef jsFunctionPrototype = JSObjectGetPrototypeProperty(jsContext, jsFunctionConstruct);
    JSObjectSetPrototype(jsContext, jsObject, jsFunctionPrototype);
    JSStringRelease(jsFunctionString);
}

/* 
 * Classes
 */

JSClassDefinition
JSClassDefinitionFrom(Class binding)
{
    NSMutableArray* boundSetters = [NSMutableArray new];
    NSMutableArray* boundGetters = [NSMutableArray new];
    NSMutableArray* boundFunctions = [NSMutableArray new];

    Class class = binding;

    while (class && [class isSubclassOfClass:BSBinding.class]) {
        u_int count;
        Method* methods = class_copyMethodList(object_getClass(class), &count);
        for (u_int i = 0; i < count; i++) {
            NSString *name = NSStringFromSelector(method_getName(methods[i]));
            if ([name hasPrefix:@"_ptr_to_setter_"]) {
                [boundSetters addObject:[name substringFromIndex:sizeof("_ptr_to_setter_") - 1]];
                continue;
            }
            if ([name hasPrefix:@"_ptr_to_getter_"]) {
                [boundGetters addObject:[name substringFromIndex:sizeof("_ptr_to_getter_") - 1]];
                continue;
            }
            if ([name hasPrefix:@"_ptr_to_function_"]) {
                [boundFunctions addObject:[name substringFromIndex:sizeof("_ptr_to_function_") - 1]];
                continue;
            }
        }
        free(methods);
        class = [class superclass];
    }
    
    JSStaticFunction* jsFunctions = calloc(boundFunctions.count + 1, sizeof(JSStaticFunction));
    for (int i = 0; i < boundFunctions.count; i++) {
        NSString *name = [boundFunctions objectAtIndex:i];
        jsFunctions[i].name = name.UTF8String;
        jsFunctions[i].attributes = kJSPropertyAttributeDontDelete;
        jsFunctions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[binding performSelector:NSSelectorFromString([@"_ptr_to_function_" stringByAppendingString:name])];
    }

    JSStaticValue *jsValues = calloc(boundGetters.count + 1, sizeof(JSStaticValue));
    for (int i = 0; i < boundGetters.count; i++) {
        NSString* name = [boundGetters objectAtIndex:i];
        jsValues[i].name = name.UTF8String;
        jsValues[i].attributes = kJSPropertyAttributeDontDelete;
        jsValues[i].getProperty = (JSObjectGetPropertyCallback)[binding performSelector:NSSelectorFromString([@"_ptr_to_getter_" stringByAppendingString:name])];
        if ([boundSetters containsObject:name]) {
            jsValues[i].setProperty = (JSObjectSetPropertyCallback)[binding performSelector:NSSelectorFromString([@"_ptr_to_setter_" stringByAppendingString:name])];
        } else {
            jsValues[i].attributes |= kJSPropertyAttributeReadOnly;
        }
    }

    JSClassDefinition jsBindingClassDef = kJSClassDefinitionEmpty;
    jsBindingClassDef.className = class_getName(class);
    jsBindingClassDef.staticValues = jsValues;
    jsBindingClassDef.staticFunctions = jsFunctions;
    jsBindingClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    
    return jsBindingClassDef;
}

/* 
 * Log
 */
 
void
JSObjectLogProperties(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSPropertyNameArrayRef jsProperties = JSObjectCopyPropertyNames(jsContext, jsObject);
    size_t count = JSPropertyNameArrayGetCount(jsProperties);
    for (int i = 0; i < count; i++) {
        JSStringRef jsProperty = JSPropertyNameArrayGetNameAtIndex(jsProperties, i);
        NSLog(@"Property: %@", [NSString stringWithJSString:jsProperty]);
    }
}

/* 
 * Color
 */

CGColorRef JSValueToCGColor(JSContextRef jsContext, JSValueRef jsVal)
{
    NSString* name = [NSString stringWithJSString:JSValueToStringCopy(jsContext, jsVal, NULL)];
    UIColor* color = [UIColor colorWithCSS:name];
    return [color CGColor];    
}