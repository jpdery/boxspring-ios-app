//
//  NSData+JavaScriptCore.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <JavaScriptCore/JavaScript.h>

JSObjectRef JSObjectCreate(JSContextRef jsContext, JSObjectRef jsPrototype);
void JSObjectInherit(JSContextRef jsContext, JSObjectRef jsObject, NSString* inherit);
void JSObjectSetParentProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsParent);
void JSObjectSetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsPrototype);
JSObjectRef JSObjectGetPrototypeProperty(JSContextRef jsContext, JSObjectRef jsObject);

void JSCopyProperties(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsObjectFrom);
void JSLogProps(JSContextRef jsContext, JSObjectRef jsObject);

//void JSObjectInspect(JSContextRef jsContext, JSObjectRef jsObject, int depth); TODO
