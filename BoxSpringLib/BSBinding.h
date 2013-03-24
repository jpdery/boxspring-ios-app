//
//  BSBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "BSScriptView.h"

#define _BS_CREATE_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}

/**
 * Macro to define a setter binding as:
 * - (void)binding:(JSContextRef)jsContext value:(JSValueRef)jsValue
 */
#define BS_DEFINE_BOUND_SETTER(name, context_name, value_name) \
	static bool _setter_##name( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef value, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		objc_msgSend(instance, @selector(_setter_##name:value:), ctx, value); \
		return true; \
	} \
	_BS_CREATE_POINTER_TO(_setter_##name) \
    - (void)_setter_##name:(JSContextRef)context_name value:(JSValueRef)value_name

/**
 * Macro to define a getter binding as:
 * - (JSValueRef)binding:(JSContextRef)jsContext
 */
#define BS_DEFINE_BOUND_GETTER(name, context_name) \
	static JSValueRef _getter_##name( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(_getter_##name:), ctx); \
	} \
	_BS_CREATE_POINTER_TO(_getter_##name)\
    - (JSValueRef)_get_##name:(JSContextRef)context_name

/**
 * Macro to define a function binding as:
 * (Replace BOUND_NAME with the name of your objective-c method)
 * - (JSValueRef)BOUND_NAME:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
 */
#define BS_DEFINE_BOUND_FUNCTION(FUNCTION_NAME, BOUND_NAME) \
	static JSValueRef _function_##FUNCTION_NAME( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		JSValueRef ret = (JSValueRef)objc_msgSend(instance, @selector(BOUND_NAME:argc:argv:), ctx, argc, argv); \
        return ret ? ret : ((BSBinding*)instance).scriptView.jsUndefinedValue; \
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


@interface BSBinding : NSObject

@property (nonatomic, readonly) NSMutableArray* boundSetters;
@property (nonatomic, readonly) NSMutableArray* boundGetters;
@property (nonatomic, readonly) NSMutableArray* boundFunctions;

@property (nonatomic, readonly) BSScriptView* scriptView;
@property (nonatomic, readonly) JSContextRef jsContext;
@property (nonatomic, readonly) JSObjectRef jsObject;
@property (nonatomic, readonly) JSObjectRef jsParentObject;
@property (nonatomic, readonly) JSObjectRef jsParentPrototype;
@property (nonatomic, readonly) JSObjectRef jsParentConstructor;

- (id)initWithContext:(JSContextRef)theJSContext;
- (id)initWithScriptView:(BSScriptView*)theScriptView;
- (id)initWithScriptView:(BSScriptView*)theScriptView inherits:(JSObjectRef)jsParent;
- (id)initWithScriptView:(BSScriptView*)theScriptView inherits:(JSObjectRef)jsParent argc:(size_t)argc argv:(const JSValueRef[])argv;

- (JSValueRef)invoke:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSValueRef)parent:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)destructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

@end