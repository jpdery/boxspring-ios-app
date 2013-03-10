//
//  NSString+BSStringExtras.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface NSString (JavaScriptCoreString)
+ (NSString*)stringWithJSString:(JSStringRef)jsStringValue;
+ (NSString*)stringWithJSValue:(JSValueRef)jsValue fromContext:(JSContextRef)ctx;
- (JSStringRef)jsStringValue;
@end
