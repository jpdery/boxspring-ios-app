//
//  BSBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSScriptView.h"

// The class method that returns a pointer to the static C callback function
#define __BS_GET_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}

// ------------------------------------------------------------------------------------
// Function - use with BS_BIND_FUNCTION( functionName, ctx, argc, argv ) { ... }

#define BS_BIND_FUNCTION(NAME, CTX_NAME, ARGC_NAME, ARGV_NAME) \
	\
	/* The C callback function for the exposed method and class method that returns it */ \
	static JSValueRef _func_##NAME( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		JSValueRef ret = (JSValueRef)objc_msgSend(instance, @selector(_func_##NAME:argc:argv:), ctx, argc, argv); \
        return ret ? ret : ((BSBinding*)instance)->scriptView->undefined; \
	} \
	__BS_GET_POINTER_TO(_func_##NAME)\
	\
	/* The actual implementation for this method */ \
	- (JSValueRef)_func_##NAME:(JSContextRef)CTX_NAME argc:(size_t)ARGC_NAME argv:(const JSValueRef [])ARGV_NAME


// ------------------------------------------------------------------------------------
// Getter - use with BS_BIND_GET( propertyName, ctx ) { ... }

#define BS_BIND_GET(NAME, CTX_NAME) \
	\
	/* The C callback function for the exposed getter and class method that returns it */ \
	static JSValueRef _get_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(_get_##NAME:), ctx); \
	} \
	__BS_GET_POINTER_TO(_get_##NAME)\
	\
	/* The actual implementation for this getter */ \
	- (JSValueRef)_get_##NAME:(JSContextRef)CTX_NAME


// ------------------------------------------------------------------------------------
// Setter - use with BS_BIND_SET( propertyName, ctx, value ) { ... }

#define BS_BIND_SET(NAME, CTX_NAME, VALUE_NAME) \
	\
	/* The C callback function for the exposed setter and class method that returns it */ \
	static bool _set_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef value, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		objc_msgSend(instance, @selector(_set_##NAME:value:), ctx, value); \
		return true; \
	} \
	__BS_GET_POINTER_TO(_set_##NAME) \
	\
	/* The actual implementation for this setter */ \
	- (void)_set_##NAME:(JSContextRef)CTX_NAME value:(JSValueRef)VALUE_NAME
		


// ------------------------------------------------------------------------------------
// Shorthand to define a function that logs a "not implemented" warning

#define BS_BIND_FUNCTION_NOT_IMPLEMENTED(NAME) \
	static JSValueRef _func_##NAME( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		static bool didShowWarning; \
		if( !didShowWarning ) { \
			NSLog(@"Warning: method " @ #NAME @" is not yet implemented!"); \
			didShowWarning = true; \
		} \
		id instance = (id)JSObjectGetPrivate(object); \
		return ((BSBinding *)instance)->scriptView->undefined; \
	} \
	__BS_GET_POINTER_TO(_func_##NAME)

@interface BSBinding : NSObject {
    @public BSScriptView* scriptView;
}

@property (nonatomic, readonly) BSScriptView* scriptView;

- (id) initWithScriptView:(BSScriptView*)theScriptView;

@end
