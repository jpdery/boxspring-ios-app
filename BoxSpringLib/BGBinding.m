//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGBinding.h"

@implementation BGBinding

@synthesize scriptView;
@synthesize jsObject;
@synthesize jsConstructor;

- (id)initWithScriptView:(BGScriptView *)theScriptView
{
    NSLog(@"Initializing bindng %@", [self class]);

    self = [super init];
    if (self) {
        scriptView = theScriptView;
    }
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

- (JSObjectRef)jsInstanceObject
{
    static JSObjectRef jsInstanceObject = nil;
    
    if (jsInstanceObject == nil) {
    
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

        jsInstanceObject = JSObjectMake(self.scriptView.jsGlobalContext, jsClass, self);
    }
    
    return jsInstanceObject;
}

@end
