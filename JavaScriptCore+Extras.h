//
//  JavaScriptCore+Extras
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <objc/message.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BSBinding;

JSStringRef
NSStringToJSString(NSString* string);

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
JSStringCreateWithNSString(NSString* string);

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
JSStringToNSString(JSContextRef jsContext, JSStringRef jsString);

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
JSValueToNSString(JSContextRef jsContext, JSValueRef jsValue);

/**
 * TODO
 */
NSArray*
JSValueToNSArray(JSContextRef jsContext, JSValueRef jsValue);

/**
 * TODO
 */
NSDictionary*
JSValueToNSDictionary(JSContextRef jsContext, JSValueRef jsValue);

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
JSValueToCGColor(JSContextRef ctx, JSValueRef value);

/**
 * Convenience method to set the prototype property of an object
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
JSObjectSetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype);

/**
 * Convenience method to return the prototype property of an object
 *
 * @param jsContext The javascript context
 * @param jsObject The javascript to retrieve the prototype property from  
 * @return The value of the prototype property
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
JSObjectRef
JSObjectGetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject);

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
JSObjectSetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype);

/**
 * Convenience method to return the constructor property of an object
 *
 * @param jsContext The javascript context
 * @param jsObject The javascript to retrieve the constructor property from  
 * @return The value of the constructor property
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
JSObjectRef
JSObjectGetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject);

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
JSObjectSetParentProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsParent);

/**
 * Convenience method to return the parent property of an object
 *
 * @param jsContext The javascript context
 * @param jsObject The javascript to retrieve the parent property from 
 * @return The value of the parent property
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1 
 */
JSObjectRef
JSObjectGetParentProperty(JSContextRef jsContext, JSObjectRef jsObject);

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
JSObjectCopyProperties(JSContextRef jsContext, JSObjectRef jsFrom, JSObjectRef jsDest);

void
JSObjectSetBoundObject(JSContextRef jsContext, JSObjectRef jsObject, BSBinding* binding);

BSBinding*
JSObjectGetBoundObject(JSContextRef jsContext, JSObjectRef jsObject);

JSClassDefinition
JSClassDefinitionFromClass(Class class);

/*
 * Logging
 */

void
JSObjectLogProperties(JSContextRef jsContext, JSObjectRef jsObject);


