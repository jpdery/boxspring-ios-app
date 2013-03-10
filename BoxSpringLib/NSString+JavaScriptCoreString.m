//
//  NSString+BSStringExtras.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSString+JavaScriptCoreString.h"

@implementation NSString (JavaScriptCoreString)

+ (NSString*)stringWithJSString:(JSStringRef)jsString
{
	return [((NSString*)JSStringCopyCFString(kCFAllocatorDefault, jsString)) autorelease];
}

+ (NSString *)stringWithJSValue:(JSValueRef)jsValue fromContext:(JSContextRef)context
{
	NSString* string = nil;
	
	JSStringRef stringValue = JSValueToStringCopy(context, jsValue, NULL);
	if (stringValue != NULL) {
		string = [NSString stringWithJSString: stringValue];
		JSStringRelease(stringValue);
	}
	
    return string;
}

- (JSStringRef)jsStringValue
{
	return JSStringCreateWithCFString((CFStringRef)self);
}


@end
