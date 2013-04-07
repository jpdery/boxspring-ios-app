//
//  NSData+JavaScriptCore.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

/* 
 * Setting Properties 
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
 * Creating Objects
 */

JSObjectRef
JSObjectCreate(JSContextRef jsContext, JSObjectRef jsPrototype);

/* 
 * Creating Classes
 */

JSClassDefinition
JSClassDefinitionFrom(Class class);

/* 
 * ?
 */

void
JSObjectInheritFunction(JSContextRef jsContext, JSObjectRef jsObject);

void
JSObjectInheritObject(JSContextRef jsContext, JSObjectRef jsObject);

/* 
 * Log
 */
void
JSObjectLogProperties(JSContextRef jsContext, JSObjectRef jsObject);
