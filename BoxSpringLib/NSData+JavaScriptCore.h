//
//  NSData+JavaScriptCore.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-19.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface NSData (JavaScriptCore)

+ (NSData*)dataWithJSValueRef:(JSValueRef)jsValue;
+ (NSData*)dataWithJSObjectRef:(JSObjectRef)jsObject;

- (JSValueRef)jsValue;
- (JSObjectRef)jsObject;

@end
