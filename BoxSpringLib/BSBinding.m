//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"
#import "NSString+JavaScriptCoreString.h"
#import "NSObject+JavaScriptCoreObject.h"
#import "NSData+JavaScriptCore.h"

@implementation BSBinding

@synthesize scriptView;
@synthesize jsBoundObject;
@synthesize jsBoundPrototype;
@synthesize jsContext;

BS_DEFINE_BOUND_FUNCTION(constructor, constructor)
BS_DEFINE_BOUND_FUNCTION(destroy, destroy)

- (id)initWithScriptView:(BSScriptView*)theScriptView
{
    self = [self init];
    if (self) {
        scriptView = theScriptView;
        jsContext = scriptView.jsGlobalContext;
        JSClassDefinition jsBoundObjectClassDef = [self.class jsBoundClassDefinition];
        JSClassRef jsBoundObjectClass = JSClassCreate(&jsBoundObjectClassDef);
        jsBoundObject = JSObjectMake(jsContext, jsBoundObjectClass, self);
        jsBoundPrototype = (JSObjectRef) JSObjectGetPrototype(jsContext, (JSObjectRef)JSObjectGetPrototype(jsContext, jsBoundObject));
        JSStoreBindingByObject(jsBoundObject, self); 
    }
    return self;
}

- (id)initWithScriptView:(BSScriptView*)theScriptView andObject:(JSObjectRef)theJSBoundObject
{
    self = [self init];
    if (self) {
        scriptView = theScriptView;
        jsContext = theScriptView.jsGlobalContext;
        jsBoundObject = theJSBoundObject;
        jsBoundPrototype = (JSObjectRef) JSObjectGetPrototype(jsContext, (JSObjectRef)JSObjectGetPrototype(jsContext, jsBoundObject));
    }
    return self;
}

- (id)initWithScriptView:(BSScriptView*)theScriptView andObject:(JSObjectRef)theJSBoundObject argc:(size_t)argc argv:(const JSValueRef[])argv
{
    self = [self initWithScriptView:theScriptView andObject:theJSBoundObject];
    if (self) {
        [self constructor:self.jsContext argc:argc argv:argv];
    }
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    return [self call:name argc:argc argv:argv ofObject:self.jsBoundPrototype];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv ofObject:(JSObjectRef)jsObject
{
    JSObjectRef jsFunction = (JSObjectRef) JSObjectGetProperty(self.jsContext, jsObject, [name jsStringValue], NULL);
    if (JSObjectIsFunction(jsContext, jsFunction)) return JSObjectCallAsFunction(self.jsContext, jsFunction, self.jsBoundObject, argc, argv, NULL);
    return self.scriptView.jsUndefinedValue;
}

- (void)setProperty:(NSString*)name value:(JSValueRef)jsValue
{

}

- (void)setProperty:(NSString*)name value:(JSValueRef)jsValue ofObject:(JSObjectRef)jsObject
{

}

- (JSValueRef)getProperty:(NSString*)name
{
    return NULL;
}

- (JSValueRef)getProperty:(NSString*)name ofObject:(JSObjectRef)jsObject
{
    return NULL;
}

/* Bindings */

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"BSBinding base constructor");
    
    return [self call:@"constructor" argc:argc argv:argv];
}

- (JSValueRef)destroy:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"BSBinding base destroy");
    return NULL;
}

+ (JSClassDefinition)jsBoundClassDefinition
{
    NSMutableArray* boundSetters = [NSMutableArray new];
    NSMutableArray* boundGetters = [NSMutableArray new];
    NSMutableArray* boundFunctions = [NSMutableArray new];

    Class class = [self class];
    while (class && [class isSubclassOfClass:BSBinding.class]) {
        u_int count;
        Method* methods = class_copyMethodList(object_getClass(class), &count);
        for (u_int i = 0; i < count; i++) {
            NSString *name = NSStringFromSelector(method_getName(methods[i]));
            if ([name hasPrefix:@"_ptr_to_setter_"]) {
                [boundSetters addObject:[name substringFromIndex:sizeof("_ptr_to_setter_") - 1]];
                continue;
            }
            if ([name hasPrefix:@"_ptr_to_getter_"]) {
                [boundGetters addObject:[name substringFromIndex:sizeof("_ptr_to_getter_") - 1]];
                continue;
            }
            if ([name hasPrefix:@"_ptr_to_function_"]) {
                [boundFunctions addObject:[name substringFromIndex:sizeof("_ptr_to_function_") - 1]];
                continue;
            }
        }
        free(methods);
        class = class.superclass;
    }
    
    JSStaticFunction* jsFunctions = calloc(boundFunctions.count + 1, sizeof(JSStaticFunction));
    for (int i = 0; i < boundFunctions.count; i++) {
        NSString *name = [boundFunctions objectAtIndex:i];
        jsFunctions[i].name = name.UTF8String;
        jsFunctions[i].attributes = kJSPropertyAttributeDontDelete;
        jsFunctions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[self.class performSelector:NSSelectorFromString([@"_ptr_to_function_" stringByAppendingString:name])];
    }

    JSStaticValue *jsValues = calloc(boundGetters.count + 1, sizeof(JSStaticValue));
    for (int i = 0; i < boundGetters.count; i++) {
        NSString* name = [boundGetters objectAtIndex:i];
        jsValues[i].name = name.UTF8String;
        jsValues[i].attributes = kJSPropertyAttributeDontDelete;
        jsValues[i].getProperty = (JSObjectGetPropertyCallback)[self.class performSelector:NSSelectorFromString([@"_ptr_to_getter_" stringByAppendingString:name])];
        if ([boundSetters containsObject:name]) {
            jsValues[i].setProperty = (JSObjectSetPropertyCallback)[self.class performSelector:NSSelectorFromString([@"_ptr_to_setter_" stringByAppendingString:name])];
        } else {
            jsValues[i].attributes |= kJSPropertyAttributeReadOnly;
        }
    }

    JSClassDefinition jsBindingClassDef = kJSClassDefinitionEmpty;
    jsBindingClassDef.className = class_getName(class);
    jsBindingClassDef.staticValues = jsValues;
    jsBindingClassDef.staticFunctions = jsFunctions;
    jsBindingClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    
    return jsBindingClassDef;
}

@end
