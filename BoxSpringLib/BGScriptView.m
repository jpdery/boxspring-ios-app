//
//  BSScriptView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGSCriptView.h"
#import "NSString+JavaScriptCoreString.h"
#import "NSObject+JavaScriptCoreObject.h"
#import "NSData+JavaScriptCore.h"

// bindings
#import "BGBinding.h"
#import "BGConsoleBinding.h"
#import "BGWindowBinding.h"
#import "BGViewBinding.h"

static NSMutableDictionary* jsClasses = nil;
static NSMutableDictionary* jsConstructors = nil;

@implementation BGScriptView

@synthesize jsGlobalContext;
@synthesize jsGlobalObject;
@synthesize jsUndefinedValue;
@synthesize jsNullValue;
@synthesize jsTrueValue;
@synthesize jsFalseValue;
@synthesize bindings;

typedef struct {
    NSString* name;
    BGScriptView* view;
} JSConstructorData;

JSObjectRef BGBindingCallAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    JSConstructorData* data = JSObjectGetPrivate(jsObject);

    Class class = NSClassFromString([BGScriptView binding:data->name]);

    // TODO: check if class exists

    BGBinding* binding;
    
    JSObjectRef jsPrototypeObject = (JSObjectRef) JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("prototype"), NULL);
    if (jsPrototypeObject) {
        binding = [(BGBinding*)[class alloc] initWithScriptView:data->view inherits:jsPrototypeObject argc:argc argv:argv];
    } else {
        binding = [(BGBinding*)[class alloc] initWithScriptView:data->view];
    }

    JSObjectRef jsBoundObject = binding.jsObject;
    
    [data->view bind:binding];
    
    [binding release];
    
    return jsBoundObject;
}

void BGBindingFinalize(JSObjectRef object)
{
    NSLog(@"binding fini");
}

JSValueRef BGBindingManagerGetClass(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    return [[jsClasses objectForKey:[NSString stringWithJSString:jsKey]] jsValue];
}

bool BGBindingManagerSetClass(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    NSString* bindingName = [NSString stringWithJSString:jsKey];
    NSString* bindingClass = [BGScriptView binding:bindingName];

    if (bindingClass) {
        
        if ([jsConstructors objectForKey:bindingName]) {
            NSLog(@"JS Binding for %@ already exists", bindingName);
            return false;
        }

        NSLog(@"Setting binding to %@ for %@", bindingName, bindingClass);

        JSClassDefinition jsBoundConstructorClassDef = kJSClassDefinitionEmpty;
        jsBoundConstructorClassDef.className = [[bindingClass stringByAppendingString:@"Constructor"] UTF8String];
        jsBoundConstructorClassDef.callAsConstructor = BGBindingCallAsConstructor;
        jsBoundConstructorClassDef.finalize = BGBindingFinalize;
        JSClassRef jsBoundConstructorClass = JSClassCreate(&jsBoundConstructorClassDef);

        JSConstructorData* data = malloc(sizeof(JSConstructorData));
		data->name = bindingName;
		data->view = JSObjectGetPrivate(jsObject);

        JSObjectRef jsBoundConstructor = JSObjectMake(jsContext, jsBoundConstructorClass, data);
        
        // free(data); ?
        
        // force this constructor to have the object it replaces' prototype
        JSObjectRef jsPrototypeClass = (JSObjectRef) jsVal;
        JSObjectRef jsPrototypeObject = (JSObjectRef) JSObjectGetProperty(jsContext, jsPrototypeClass, JSStringCreateWithUTF8CString("prototype"), NULL);
        
        JSObjectSetProperty(
            jsContext,
            jsBoundConstructor,
            JSStringCreateWithUTF8CString("prototype"),
            jsPrototypeObject,
            kJSPropertyAttributeNone,
            NULL
        );
        
        [jsClasses setObject:[NSData dataWithJSValueRef:jsBoundConstructor] forKey:bindingName];
        
        return jsBoundConstructor;
    }
    
    [jsClasses setObject:[NSData dataWithJSValueRef:jsVal] forKey:bindingName];
        
    return true;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // create the global context and some default values
        jsGlobalContext = JSGlobalContextCreate(NULL);
        jsGlobalObject = JSContextGetGlobalObject(jsGlobalContext);
        jsNullValue = JSValueMakeNull(jsGlobalContext);
        jsTrueValue = JSValueMakeBoolean(jsGlobalContext, true);
        jsFalseValue = JSValueMakeBoolean(jsGlobalContext, false);
        jsUndefinedValue = JSValueMakeUndefined(jsGlobalContext);
        JSValueProtect(jsGlobalContext, jsNullValue);
        JSValueProtect(jsGlobalContext, jsTrueValue);
        JSValueProtect(jsGlobalContext, jsFalseValue);
        JSValueProtect(jsGlobalContext, jsUndefinedValue);

        bindings = [NSMutableArray new];

        if (jsClasses == nil) {
            jsClasses = [NSMutableDictionary new];
        }
        
        if (jsConstructors == nil) {
            jsConstructors = [NSMutableDictionary new];
        }
        
        // define the javascript object responsible for detecting bindings
        JSClassDefinition jsBindingManagerClassDef = kJSClassDefinitionEmpty;
        jsBindingManagerClassDef.getProperty = BGBindingManagerGetClass;
        jsBindingManagerClassDef.setProperty = BGBindingManagerSetClass;
        JSClassRef jsBindingManagerClass = JSClassCreate(&jsBindingManagerClassDef);

        // create this javascript object
        JSObjectRef jsBindingManager = JSObjectMake(self.jsGlobalContext, jsBindingManagerClass, self);

        JSObjectSetProperty(
            jsGlobalContext,
            jsGlobalObject,
            JSStringCreateWithUTF8CString("__classes__"),
            jsBindingManager,
            kJSPropertyAttributeNone,
            NULL
        );
        
        // load common bindings
        BGConsoleBinding* consoleBinding = [[BGConsoleBinding alloc] initWithScriptView:self];
        [self bind:consoleBinding toKey:@"console"];
        [consoleBinding release];
    }
    
    return self;
}

- (void)dealloc
{
    JSValueUnprotect(jsGlobalContext, jsNullValue);
    JSValueUnprotect(jsGlobalContext, jsTrueValue);
    JSValueUnprotect(jsGlobalContext, jsFalseValue);
    JSValueUnprotect(jsGlobalContext, jsUndefinedValue);
    JSGlobalContextRelease(jsGlobalContext);
  
    [super dealloc];
}

- (void)loadScript:(NSString *)path
{
    path = [NSString stringWithFormat:@"%@/App/%@", [[NSBundle mainBundle] resourcePath], path];

    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (script == nil) {
        NSLog(@"Error: Script at path %@ cannot be loaded.", path);
        return;
    }
    
    [self evalScript:script];
}

- (void)evalScript:(NSString *)source
{
    JSValueRef jsException = NULL;
	JSEvaluateScript(self.jsGlobalContext, JSStringCreateWithCFString((CFStringRef)source), NULL, NULL, 0, &jsException);
    [self log:jsException];
}

- (void)log:(JSValueRef)jsException
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

- (void)bind:(BGBinding *)binding
{
    [bindings addObject:binding];
}

- (void)bind:(BGBinding *)binding toKey:(NSString*)key
{
    [self bind:binding toKey:key ofObject:self.jsGlobalObject];
}

- (void)bind:(BGBinding *)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject
{
    JSObjectSetProperty(self.jsGlobalContext, jsObject, [key jsStringValue], [binding jsObject], kJSClassAttributeNone, NULL);
    [self bind:binding];
}

+ (NSString*)binding:(NSString*)name
{
    static NSDictionary* bindings = nil;
    
    if (bindings == nil) {
        bindings = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"BGViewBinding",   @"boxspring.View",
            @"BGWindowBinding", @"boxspring.Window",
        nil];
    }
    
    return [bindings objectForKey:name];
}

@end
