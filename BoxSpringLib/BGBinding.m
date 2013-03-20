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
@synthesize jsObject;

BG_DEFINE_BOUND_FUNCTION(constructor, constructor)
BG_DEFINE_BOUND_FUNCTION(destroy, destroy)

- (id)initWithScriptView:(BGScriptView *)theScriptView
{
    self = [super init];
    if (self) {
        
        scriptView = theScriptView;
        
        // bind the class methods
        NSMutableArray* methods = [[NSMutableArray alloc] init];
        NSMutableArray* properties = [[NSMutableArray alloc] init];

        Class class = [self class];
        Class base = BGBinding.class;

        for (Class sc = class; sc != base && [sc isSubclassOfClass:base]; sc = sc.superclass) {

            u_int count;
            Method* methodList = class_copyMethodList(object_getClass(sc), &count);

            for (int i = 0; i < count; i++) {

                NSString *name = NSStringFromSelector(method_getName(methodList[i]));

                if ([name hasPrefix:@"_ptr_to_function_"]) {
                    [methods addObject:[name substringFromIndex:sizeof("_ptr_to_function_") - 1]];
                    continue;
                }

                if ([name hasPrefix:@"_ptr_to_getter_"]) {
                    [properties addObject:[name substringFromIndex:sizeof("_ptr_to_getter_") - 1]];
                    continue;
                }
            }

            free(methodList);
        }

        JSStaticValue *jsStaticValues = calloc(properties.count + 1, sizeof(JSStaticValue));
        JSStaticFunction* jsStaticFunctions = calloc(methods.count + 1, sizeof(JSStaticFunction));

        for (int i = 0; i < properties.count; i++) {
            NSString* name = properties[i];
            jsStaticValues[i].name = name.UTF8String;
            jsStaticValues[i].attributes = kJSPropertyAttributeDontDelete;
            SEL get = NSSelectorFromString([@"_ptr_to_getter_" stringByAppendingString:name]);
            SEL set = NSSelectorFromString([@"_ptr_to_setter_" stringByAppendingString:name]);
            jsStaticValues[i].getProperty = (JSObjectGetPropertyCallback)[class performSelector:get];
            if ([class respondsToSelector:set]) {
                jsStaticValues[i].setProperty = (JSObjectSetPropertyCallback)[class performSelector:set];
            } else {
                jsStaticValues[i].attributes |= kJSPropertyAttributeReadOnly;
            }
        }

        for (int i = 0; i < methods.count; i++) {
            NSString *name = methods[i];
            jsStaticFunctions[i].name = name.UTF8String;
            jsStaticFunctions[i].attributes = kJSPropertyAttributeDontDelete;
            SEL call = NSSelectorFromString([@"_ptr_to_function_" stringByAppendingString:name]);
            jsStaticFunctions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[class performSelector:call];
        }

        JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
        jsClassDef.className = class_getName(class);
        //jsClassDef.finalize = EJBindingBaseFinalize;
        jsClassDef.staticValues = jsStaticValues;
        jsClassDef.staticFunctions = jsStaticFunctions;
        JSClassRef jsClass = JSClassCreate(&jsClassDef);

        free(jsStaticValues);
        free(jsStaticFunctions);

        [methods release];
        [properties release];

        jsObject = JSObjectMake(self.scriptView.jsGlobalContext, jsClass, self);        
    }
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

/**
 * @binding
 * @since 0.0.1
 */
- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Calling constructor");
    return NULL;
}

/**
 * @binding
 * @since 0.0.1
 */
- (JSValueRef)destroy:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Calling destroy");
    return NULL;
}

@end
