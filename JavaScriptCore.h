//
//  NSData+JavaScriptCore.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <JavaScriptCore/JavaScript.h>

JSObjectRef JSObjectCreate(JSContextRef jsContext, JSObjectRef jsPrototype);
void JSCopyProperties(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsObjectFrom);
void JSLogProps(JSContextRef jsContext, JSObjectRef jsObject);