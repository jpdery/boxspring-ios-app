//
//  NSData+JavaScriptCore.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"
#import "JavaScriptCore+Extras.h"
#import "BSBinding.h"

/* 
 * Setting Properties 
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
 * Creating Objects
 */

JSObjectRef
JSObjectCreate(JSContextRef jsContext, JSObjectRef jsPrototype)
{
    JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
    jsClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    JSClassRef jsClass = JSClassCreate(&jsClassDef);
    JSObjectRef jsObject = JSObjectMake(jsContext, jsClass, NULL);
    JSObjectSetPrototype(jsContext, jsObject, (JSValueRef)jsPrototype);
    return jsObject;
}

/*
 *
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
 * Creating Classes
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
