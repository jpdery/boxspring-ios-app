//
//  JavaScriptCore+Extras.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "UIColor+Hex.h"
#import "JavaScriptCore+Extras.h"
#import "BSBinding.h"

JSStringRef
NSStringToJSString(NSString* string)
{
    return JSStringCreateWithCFString((CFStringRef)string);
}

/**
 * Creates a javascript string from a NSString
 *
 * @param jsContext The javascript context
 * @param jsString The javascript string
 * @return The new string.
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
JSStringRef
JSStringCreateWithNSString(NSString* string)
{
    return JSStringCreateWithCFString((CFStringRef)string);
}

/**
 * Convert a javascript string into a NSString
 *
 * @param jsContext The javascript context
 * @param jsString The javascript string
 * @return The new string.
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
NSString*
JSStringToNSString(JSContextRef jsContext, JSStringRef jsString)
{
    NSString *string = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, jsString);
    [string autorelease];
    return string;
}

/**
 * Convert a javascript value into a NSString
 *
 * @param jsContext The javascript context
 * @param jsValue The javascript value
 * @return The new string.
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
NSString *
JSValueToNSString(JSContextRef jsContext, JSValueRef jsValue)
{
	JSStringRef jsString = JSValueToStringCopy(jsContext, jsValue, NULL);
	if (!jsString) return nil;
	
	NSString *string = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, jsString);
	[string autorelease];
	JSStringRelease(jsString);
	
	return string;
}

/**
 * TODO
 */
NSArray*
JSValueToNSArray(JSContextRef jsContext, JSValueRef jsValue)
{
    NSLog(@"JSValueToNSArray not implemented");
    return nil;
}

/**
 * TODO
 */
NSDictionary*
JSValueToNSDictionary(JSContextRef jsContext, JSValueRef jsValue)
{
    NSLog(@"JSValueToNSDictionary not implemented");
    return nil;
}

/**
 * Convert a javascript value into a CGColorRef
 *
 * @param jsContext The javascript context
 * @param jsValue The javascript value
 * @return The color
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
CGColorRef
JSValueToCGColor(JSContextRef jsContext, JSValueRef jsValue)
{
    NSString* name = JSValueToNSString(jsContext, jsValue);
    UIColor* color = [UIColor colorWithCSS:name];
    return [color CGColor];    
}

/**
 * Convenience method to set the prototype property of an object.
 *
 * @param jsContext The javascript context
 * @param jsObject The javascript object that will be assigned the prorotype property 
 * @param jsPrototype The javascript object that will be assigned as the prototype property
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
void
JSObjectSetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("prototype");
    JSObjectSetProperty(jsContext, jsObject, jsKey, jsPrototype, kJSPropertyAttributeDontDelete, NULL);
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

/**
 * Convenience method to set the constructor property of an object.
 *
 * @param jsContext The javascript context
 * @param jsObject The javascript object that will be assigned the constructor property 
 * @param jsPrototype The javascript object that will be assigned as the constructor property
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
void
JSObjectSetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsConstructor)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("constructor");
    JSObjectSetProperty(jsContext, jsObject, jsKey, jsConstructor, kJSPropertyAttributeDontDelete, NULL);
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

/**
 * Convenience method to set the parent property of an object.
 *
 * @param jsContext The javascript context
 * @param jsObject The javascript object that will be assigned the parent property 
 * @param jsPrototype The javascript object that will be assigned as the parent property
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
void
JSObjectSetParentProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsParent)
{
    JSStringRef jsKey = JSStringCreateWithUTF8CString("parent");
    JSObjectSetProperty(jsContext, jsObject, jsKey, jsParent, kJSPropertyAttributeDontDelete, NULL);
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

/**
 * Copy all properties from an object to another.
 *
 * @param jsContext The javascript context
 * @param jsFrom The javascript object all properties will be copied from
 * @param jsDest The javascript object to receive all properties
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
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
        JSValueMakeString(jsContext, NSStringToJSString(identifier)),
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

    return [jsObjectMapping objectForKey:JSValueToNSString(jsContext, jsIntanceId)];
}

JSClassDefinition
JSClassDefinitionFromClass(Class binding)
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
 
void
JSObjectLogProperties(JSContextRef jsContext, JSObjectRef jsObject)
{
    JSPropertyNameArrayRef jsProperties = JSObjectCopyPropertyNames(jsContext, jsObject);
    size_t count = JSPropertyNameArrayGetCount(jsProperties);
    for (int i = 0; i < count; i++) {
        JSStringRef jsProperty = JSPropertyNameArrayGetNameAtIndex(jsProperties, i);
        NSLog(@"Property: %@", JSStringToNSString(jsContext, jsProperty));
    }
}




