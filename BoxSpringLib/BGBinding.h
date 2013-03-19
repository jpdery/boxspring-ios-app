//
//  BSBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "BGScriptView.h"

#define _BG_CREATE_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}

/**
 * Macro to define a setter binding as:
 * - (void)binding:(JSContextRef)jsContext value:(JSValueRef)jsValue
 */
#define BG_BIND_SETTER(name, binding) \
	static bool _setter_##name( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef value, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		objc_msgSend(instance, @selector(binding:value:), ctx, value); \
		return true; \
	} \
	_BG_CREATE_POINTER_TO(_setter_##name) \

/**
 * Macro to define a getter binding as:
 * - (JSValueRef)binding:(JSContextRef)jsContext
 */
#define BSS_BIND_GETTER(name, binding) \
	static JSValueRef _getter_##name( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(binding:), ctx); \
	} \
	_BG_CREATE_POINTER_TO(_getter_##name)\

/**
 * Macro to define a function binding as:
 * - (JSValueRef)binding:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
 */
#define BG_BIND_FUNCTION(name, binding) \
	static JSValueRef _function_##name( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		JSValueRef ret = (JSValueRef)objc_msgSend(instance, @selector(binding:argc:argv:), ctx, argc, argv); \
        return ret ? ret : ((BGBinding*)instance).scriptView.jsUndefinedValue; \
	} \
	_BG_CREATE_POINTER_TO(_function_##name)

/**
 * Macro to define a non implemented function
 */
#define BG_DEFINE_MISSING_FUNCTION(name) \
	static JSValueRef _function_##name( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		static bool didShowWarning; \
		if(!didShowWarning) { \
			NSLog(@"Warning: method " @ #name @" is not yet implemented!"); \
			didShowWarning = true; \
		} \
		id instance = (id)JSObjectGetPrivate(object); \
		return ((BGBinding*)instance).scriptView.jsUndefinedValue; \
	} \
	_BG_CREATE_POINTER_TO(_function_##name)


@interface BGBinding : NSObject

@property (nonatomic, readonly) BGScriptView* scriptView;
@property (nonatomic, readonly) JSObjectRef jsObject;

- (id)initWithScriptView:(BGScriptView*)theScriptView;

@end