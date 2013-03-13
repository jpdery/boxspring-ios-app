//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"
#import "BSScriptView.h"

@implementation BSBinding

@synthesize scriptView;

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (id)initWithScriptView:(BSScriptView *)theScriptView
{
    self = [super init];
    if (self) {
        scriptView = [theScriptView retain];
    }
    return self;
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
+ (JSClassRef)jsClass
{
    NSMutableArray* funcs = [[NSMutableArray alloc] init];
    NSMutableArray* props = [[NSMutableArray alloc] init];

    Class this = [self class];
    Class base = BSBinding.class;

    for (Class supr = this; supr != base && [base isSubclassOfClass:base]; supr = supr.superclass) {
        
        u_int count;
        Method* methods = class_copyMethodList(object_getClass(supr), &count);
        
        for (int i = 0; i < count; i++) {

            NSString *name = NSStringFromSelector(method_getName(methods[i]));
            
			if ([name hasPrefix:@"_ptr_to_function_"]) {
                [funcs addObject:[name substringFromIndex:sizeof("_ptr_to_function_") - 1]];
                continue;
            }
            
            if ([name hasPrefix:@"_ptr_to_getter_"]) {
                [props addObject:[name substringFromIndex:sizeof("_ptr_to_getter_") - 1]];
                continue;
            }        
        }

        free(methods);
    }

    JSStaticValue *jsStaticValues = calloc(props.count + 1, sizeof(JSStaticValue));
    JSStaticFunction* jsStaticFunctions = calloc(funcs.count + 1, sizeof(JSStaticFunction));
    
    for (int i = 0; i < props.count; i++) {
        
        NSString* name = props[i];
        jsStaticValues[i].name = name.UTF8String;
        jsStaticValues[i].attributes = kJSPropertyAttributeDontDelete;
		
        SEL get = NSSelectorFromString([@"_ptr_to_getter_" stringByAppendingString:name]);
        SEL set = NSSelectorFromString([@"_ptr_to_setter_" stringByAppendingString:name]);
        jsStaticValues[i].getProperty = (JSObjectGetPropertyCallback)[this performSelector:get];
		if ([this respondsToSelector:set]) {
			jsStaticValues[i].setProperty = (JSObjectSetPropertyCallback)[this performSelector:set];
		} else {
			jsStaticValues[i].attributes |= kJSPropertyAttributeReadOnly;
		}        
    }
       	
	for (int i = 0; i < funcs.count; i++) {
		
        NSString *name = funcs[i];
		jsStaticFunctions[i].name = name.UTF8String;
		jsStaticFunctions[i].attributes = kJSPropertyAttributeDontDelete;
		
        SEL call = NSSelectorFromString([@"_ptr_to_function_" stringByAppendingString:name]);
		jsStaticFunctions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[this performSelector:call];
	}
	
	JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
    jsClassDef.className = class_getName(this) + sizeof("BSBinding") - 1;
	//jsClassDef.finalize = EJBindingBaseFinalize;
	jsClassDef.staticValues = jsStaticValues;
	jsClassDef.staticFunctions = jsStaticFunctions;
    JSClassRef jsClass = JSClassCreate(&jsClassDef);
	
	free(jsStaticValues);
	free(jsStaticFunctions);
	
	[funcs release];
	[props release];

	return jsClass;
}

@end
