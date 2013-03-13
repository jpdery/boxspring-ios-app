//
//  BSBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSScriptView.h"

#define _BS_CREATE_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}

/**
 * Macro to define a setter binding as:
 * - (void)binding:(JSContextRef)context value:(JSValueRef)value
 */
#define BS_DEFINE_SETTER(name, binding) \
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
	_BS_CREATE_POINTER_TO(_set_##name) \

/**
 * Macro to define a getter binding as:
 * - (JSValueRef)binding:(JSContextRef)context
 */
#define BS_DEFINE_GETTER(name, binding) \
	static JSValueRef _getter_##name( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(binding:), ctx); \
	} \
	_BS_CREATE_POINTER_TO(_getter_##name)\

/**
 * Macro to define a function binding as:
 * - (JSValueRef)binding:(JSContextRef)context argc:(size_t)argc argv:(const JSValueRef [])argv
 */
#define BS_DEFINE_FUNCTION(name, binding) \
	static JSValueRef _function_##name( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
        NSLog(@"Pointer to %@", NSStringFromSelector(@selector(binding:argc:argv:))); \
		JSValueRef ret = (JSValueRef)objc_msgSend(instance, @selector(binding:argc:argv:), ctx, argc, argv); \
        return ret ? ret : ((BSBinding*)instance).scriptView.jsUndefinedValue; \
	} \
	_BS_CREATE_POINTER_TO(_function_##name)

/**
 * Macro to define a non implemented function
 */
#define BS_DEFINE_MISSING_FUNCTION(name) \
	static JSValueRef _func_##name( \
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
		return ((BSBinding*)instance).scriptView.jsUndefinedValue; \
	} \
	_BS_CREATE_POINTER_TO(_func_##name)

@interface BSBinding : NSObject {
    @public BSScriptView* scriptView;
}

@property (nonatomic, readonly) BSScriptView* scriptView;

- (id) initWithScriptView:(BSScriptView*)theScriptView;

+ (JSClassRef)jsClass;

@end