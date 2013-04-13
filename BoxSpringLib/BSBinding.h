//
//  BSBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JavaScriptCore+Extras.h"
#import "BSScriptView.h"

#define _BS_CREATE_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}

/**
 * Macro to define a setter binding as:
 * - (void)BOUND_NAME:(JSContextRef)jsContext value:(JSValueRef)jsValue
 */
#define BS_DEFINE_BOUND_SETTER(SETTER_NAME, BOUND_NAME) \
	static bool _setter_##SETTER_NAME( \
		JSContextRef jsContext, \
		JSObjectRef jsObject, \
		JSStringRef jsKey, \
		JSValueRef jsVal, \
		JSValueRef* jsException \
	) { \
		BSBinding* instance = JSObjectGetBoundObject(jsContext, jsObject); \
		objc_msgSend(instance, @selector(BOUND_NAME:value:), jsContext, jsVal); \
		return true; \
	} \
	_BS_CREATE_POINTER_TO(_setter_##SETTER_NAME) \

/**
 * Macro to define a getter binding as:
 * - (JSValueRef)BOUND_NAME:(JSContextRef)jsContext
 */
#define BS_DEFINE_BOUND_GETTER(GETTER_NAME, BOUND_NAME) \
	static JSValueRef _getter_##GETTER_NAME( \
		JSContextRef jsContext, \
		JSObjectRef jsObject, \
		JSStringRef jsKey, \
		JSValueRef* jsException \
	) { \
		BSBinding* instance = JSObjectGetBoundObject(jsContext, jsObject); \
		return (JSValueRef)objc_msgSend(instance, @selector(BOUND_NAME:), jsContext); \
	} \
	_BS_CREATE_POINTER_TO(_getter_##GETTER_NAME)\

/**
 * Macro to define a function binding as:
 * - (JSValueRef)BOUND_NAME:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
 */
#define BS_DEFINE_BOUND_FUNCTION(FUNCTION_NAME, BOUND_NAME) \
	static JSValueRef _function_##FUNCTION_NAME( \
		JSContextRef jsContext, \
		JSObjectRef jsFunction, \
		JSObjectRef jsObject, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		BSBinding* instance = JSObjectGetBoundObject(jsContext, jsObject); \
		JSValueRef ret = (JSValueRef)objc_msgSend(instance, @selector(BOUND_NAME:argc:argv:), jsContext, argc, argv); \
        return ret ? ret : instance.scriptView.jsUndefinedValue; \
	} \
	_BS_CREATE_POINTER_TO(_function_##FUNCTION_NAME) \

/**
 * Macro to define a non implemented function
 */
#define BS_DEFINE_MISSING_FUNCTION(name) \
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
		return ((BSBinding*)instance).scriptView.jsUndefinedValue; \
	} \
	_BS_CREATE_POINTER_TO(_function_##name)


enum BSBindingContextObject {
   kBSBindingContextObjectSelf,
   kBSBindingContextObjectParent
};

typedef enum BSBindingContextObject BSBindingContextObject;

@interface BSBinding : NSObject

@property (nonatomic, readonly) BSScriptView* scriptView;
@property (nonatomic, readonly) JSContextRef jsContext;
@property (nonatomic, readonly) JSObjectRef jsThisObject;
@property (nonatomic, readonly) JSObjectRef jsBoundObject;
@property (nonatomic, readonly) JSObjectRef jsBoundObjectPrototype;
@property (nonatomic) JSObjectRef jsPrimeConstructor;
@property (nonatomic) JSObjectRef jsBoundConstructor;

- (id)initWithScriptView:(BSScriptView*)theScriptView;
- (id)initWithScriptView:(BSScriptView*)theScriptView prototype:(JSObjectRef)theJSPrototypeObject;
- (id)initWithScriptView:(BSScriptView*)theScriptView prototype:(JSObjectRef)theJSPrototypeObject this:(JSObjectRef)theJSThisObject;

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv from:(BSBindingContextObject)context;

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

@end