//
//  NSData+JavaScriptCore.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <objc/message.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BSBinding;

/* 
 * Properties
 */

void
JSObjectSetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype);

JSObjectRef
JSObjectGetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject);

void
JSObjectSetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype);

JSObjectRef
JSObjectGetConstructorProperty(JSContextRef jsContext, JSObjectRef jsObject);

void
JSObjectSetParentProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsParent);

JSObjectRef
JSObjectGetParentProperty(JSContextRef jsContext, JSObjectRef jsObject);

void
JSObjectCopyProperties(JSContextRef jsContext, JSObjectRef jsFrom, JSObjectRef jsDest);

/* 
 * Classes
 */

JSClassDefinition
JSClassDefinitionFrom(Class class);

/* 
 * Bindings
 */

void
JSObjectSetBoundObject(JSContextRef jsContext, JSObjectRef jsObject, BSBinding* binding);

BSBinding*
JSObjectGetBoundObject(JSContextRef jsContext, JSObjectRef jsObject);

/* 
 * Convenience
 */

void
JSObjectInheritFunction(JSContextRef jsContext, JSObjectRef jsObject);

void
JSObjectInheritObject(JSContextRef jsContext, JSObjectRef jsObject);

/* 
 * Logging
 */

void
JSObjectLogProperties(JSContextRef jsContext, JSObjectRef jsObject);
