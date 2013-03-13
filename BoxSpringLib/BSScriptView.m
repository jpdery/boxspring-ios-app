//
//  BSScriptView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSString+JavaScriptCoreString.h"
#import "NSObject+JavaScriptCoreObject.h"
#import "BSBinding.h"
#import "BSConsoleBinding.h"

@implementation BSScriptView

@synthesize jsGlobalContext;
@synthesize jsUndefinedValue;
@synthesize jsNullValue;
@synthesize jsTrueValue;
@synthesize jsFalseValue;
@synthesize bindings;

/**
 * Initialize the script view
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        jsGlobalContext = JSGlobalContextCreate(NULL);
        
        jsNullValue = JSValueMakeNull(jsGlobalContext);
        jsTrueValue = JSValueMakeBoolean(jsGlobalContext, true);
        jsFalseValue = JSValueMakeBoolean(jsGlobalContext, false);
        jsUndefinedValue = JSValueMakeUndefined(jsGlobalContext);
        JSValueProtect(jsGlobalContext, jsNullValue);
        JSValueProtect(jsGlobalContext, jsTrueValue);
        JSValueProtect(jsGlobalContext, jsFalseValue);
        JSValueProtect(jsGlobalContext, jsUndefinedValue);
                
        bindings = [[NSMutableArray alloc] init];
        
        [self bind:BSConsoleBinding.class toKey:@"console"];
    }
    return self;
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)dealloc
{
    JSValueUnprotect(jsGlobalContext, jsNullValue);
    JSValueUnprotect(jsGlobalContext, jsTrueValue);
    JSValueUnprotect(jsGlobalContext, jsFalseValue);
    JSValueUnprotect(jsGlobalContext, jsUndefinedValue);
    JSGlobalContextRelease(jsGlobalContext);

    [bindings release];

    [super dealloc];
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)loadScript:(NSString *)path
{
    NSString *script = [NSString stringWithContentsOfFile:[self pathForResource:path] encoding:NSUTF8StringEncoding error:NULL];
    if (script) {
        [self evalScript:script];
        return;
    }

    NSLog(@"Error: Script at path %@ cannot be loaded.", path);
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)evalScript:(NSString *)source
{
    JSValueRef jsException = NULL;
	JSEvaluateScript(self.jsGlobalContext, JSStringCreateWithCFString((CFStringRef)source), NULL, NULL, 0, &jsException);
    [self handleException:jsException];
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)handleException:(JSValueRef)jsException
{
    if (!jsException)
        return;
    
    JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
    JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");

    JSObjectRef jsExceptionObject = JSValueToObject(self.jsGlobalContext, jsException, NULL);
    JSValueRef jsLine = JSObjectGetProperty(self.jsGlobalContext, jsExceptionObject, jsLinePropertyName, NULL);
    JSValueRef jsFile = JSObjectGetProperty(self.jsGlobalContext, jsExceptionObject, jsFilePropertyName, NULL);
    
    NSLog(
        @"%@ at line %@ in %@",
        [NSString stringWithJSValue:jsExceptionObject fromContext:self.jsGlobalContext],
        [NSString stringWithJSValue:jsLine fromContext:self.jsGlobalContext],
        [NSString stringWithJSValue:jsFile fromContext:self.jsGlobalContext]
     );
    
    JSStringRelease(jsLinePropertyName);
    JSStringRelease(jsFilePropertyName);
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (NSString*)pathForResource:(NSString *)resource
{
    return [NSString stringWithFormat:@"%@/App/%@", [[NSBundle mainBundle] resourcePath], resource];
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (BSBinding*)bind:(Class)class toKey:(NSString*)key
{
    return [self bind:class toKey:key ofObject:JSContextGetGlobalObject(self.jsGlobalContext)];
}

/**
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (BSBinding*)bind:(Class)class toKey:(NSString*)key ofObject:(JSObjectRef)object
{
    JSClassRef jsObjectClass = (JSClassRef)[class jsClass];
    if (jsObjectClass) {
    
        JSObjectRef jsObjectData = JSObjectMake(self.jsGlobalContext, jsObjectClass, NULL);
        JSStringRef jsObjectName = [key jsStringValue];
        JSValueProtect(self.jsGlobalContext, jsObjectData);
        JSObjectSetProperty(self.jsGlobalContext, object, jsObjectName, jsObjectData, kJSPropertyAttributeReadOnly, NULL);
        
        BSBinding* binding = [(BSBinding*)[class alloc] initWithScriptView:self];
        [bindings addObject:binding];
        JSObjectSetPrivate(jsObjectData, binding);
        [binding release];
    
    }

    return nil;
}


@end
