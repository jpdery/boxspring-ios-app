//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGBinding.h"
#import "NSString+JavaScriptCoreString.h"
#import "NSObject+JavaScriptCoreObject.h"
#import "NSData+JavaScriptCore.h"

@implementation BGBinding

@synthesize scriptView;
@synthesize jsContext;
@synthesize jsObject;
@synthesize jsPrototype;
@synthesize boundSetters;
@synthesize boundGetters;
@synthesize boundFunctions;

BG_DEFINE_BOUND_FUNCTION(constructor, constructor)
BG_DEFINE_BOUND_FUNCTION(destroy, destroy)

- (id)initWithContext:(JSContextRef)theJSContext
{
    self = [self init];
    if (self) {
    
        jsContext = theJSContext;
    
        boundSetters = [NSMutableArray new];
        boundGetters = [NSMutableArray new];
        boundFunctions = [NSMutableArray new];
    
        Class class = [self class];
        while (class && [class isSubclassOfClass:BGBinding.class]) {
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
        // jsClassDef.finalize = EJBindingBaseFinalize;
        JSClassRef jsBindingClass = JSClassCreate(&jsBindingClassDef);

        jsObject = JSObjectMake(jsContext, jsBindingClass, self);
        
        free(jsValues);
        free(jsFunctions);        
    }
    
    return self;
}

- (id)initWithScriptView:(BGScriptView*)theScriptView
{
    self = [self initWithContext:theScriptView.jsGlobalContext];
    if (self) {
        scriptView = theScriptView;
    }
    return self;
}

- (id)initWithScriptView:(BGScriptView*)theScriptView andArguments:(size_t)argc argv:(const JSValueRef[])argv forPrototype:(JSObjectRef)theJSPrototype
{
    self = [self initWithScriptView:theScriptView];
    if (self) {
    
        jsPrototype = theJSPrototype;
        
        JSObjectSetPrototype(
            self.jsContext,
            self.jsObject,
            JSObjectCallAsConstructor(
                self.jsContext,
                jsPrototype,
                argc,
                argv,
                NULL
            )
        );
        
        [self constructor:theScriptView.jsGlobalContext argc:argc argv:argv];
    }
        
    return self;
}

- (void)dealloc
{
    [self destructor:self.jsContext argc:0 argv:NULL];
    [scriptView release];
    [super dealloc];
}

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

- (JSValueRef)destructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

@end
