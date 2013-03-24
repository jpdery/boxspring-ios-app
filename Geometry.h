//
//  Geometry.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-24.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScript.h>

CGPoint CGPointFromJSObject(JSContextRef jsContext, JSObjectRef jsObject);
CGSize CGSizeFromJSObject(JSContextRef jsContext, JSObjectRef jsObject);
CGRect CGRectFromJSObject(JSContextRef jsContext, JSObjectRef jsObject);
