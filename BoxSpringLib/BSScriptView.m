//
//  BSScriptView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSString+JavaScriptCoreString.h"
#import "NSObject+JavaScriptCoreObject.h"
#import "NSData+JavaScriptCore.h"

// bindings
#import "BSScriptView.h"
#import "BSBinding.h"
#import "BSConsoleBinding.h"
#import "BSWindowBinding.h"
#import "BSViewBinding.h"
#import "BSWindow.h"
#import "BSView.h"

static NSMutableDictionary* jsPrimeClasses = nil;
static NSMutableDictionary* jsBoundClasses = nil;

@implementation BSScriptView

@synthesize jsGlobalContext;
@synthesize jsGlobalObject;
@synthesize jsUndefinedValue;
@synthesize jsNullValue;
@synthesize jsTrueValue;
@synthesize jsFalseValue;
@synthesize bindings;

typedef struct {
    NSString* name;
    BSScriptView* view;
} JSConstructorData;


JSObjectRef BSBindingCallAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    JSConstructorData* data = JSObjectGetPrivate(jsObject);

    NSString* primeClassName = data->name;
    NSString* boundClassName = [BSScriptView binding:primeClassName];

    Class class = NSClassFromString(boundClassName);
    if (class == nil) {
        [NSException raise:@"Bound class does not exists" format:@"The class %@ does not exists", boundClassName];
    }

    BSBinding* binding;
    
    JSObjectRef jsParentObject = [[jsPrimeClasses objectForKey:primeClassName] jsObject];
    if (jsParentObject) {
        binding = [(BSBinding*)[class alloc] initWithScriptView:data->view inherits:jsParentObject argc:argc argv:argv];
    } else {
        binding = [(BSBinding*)[class alloc] initWithScriptView:data->view];
    }

    [data->view bind:binding];
    JSObjectRef jsBoundObject = binding.jsBinding;
    [binding release];
    
    return jsBoundObject;
}

JSValueRef BSBindingCallAsFunction(JSContextRef jsContext, JSObjectRef jsFunction, JSObjectRef jsThis, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    NSLog(@"Called as function");
    return NULL;
}

void BSBindingFinalize(JSObjectRef object)
{
    NSLog(@"binding fini");
}

bool BSBindingManagerSetClass(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    NSString* name = [NSString stringWithJSString:jsKey];
    NSString* class = [BSScriptView binding:name];

    [jsPrimeClasses setObject:[NSData dataWithJSValueRef:jsVal] forKey:name];
    
    if (class) {

        JSClassDefinition jsBoundConstructorClassDef = kJSClassDefinitionEmpty;
        jsBoundConstructorClassDef.className = [[class stringByAppendingString:@"Constructor"] UTF8String];
        jsBoundConstructorClassDef.callAsConstructor = BSBindingCallAsConstructor;
        jsBoundConstructorClassDef.callAsFunction = BSBindingCallAsFunction;
        jsBoundConstructorClassDef.finalize = BSBindingFinalize;
        JSClassRef jsBoundConstructorClass = JSClassCreate(&jsBoundConstructorClassDef);

        JSConstructorData* data = malloc(sizeof(JSConstructorData));
		data->name = name;
		data->view = JSObjectGetPrivate(jsObject);

        JSObjectRef jsBoundConstructor = JSObjectMake(jsContext, jsBoundConstructorClass, data);
        JSCopyProperties(jsContext, jsBoundConstructor, (JSObjectRef) jsVal);
        [jsBoundClasses setObject:[NSData dataWithJSObjectRef:jsBoundConstructor] forKey:name];
       
        return jsBoundConstructor;
    }
    
    return true;
}

JSValueRef BSBindingManagerGetClass(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    NSString* name = [NSString stringWithJSString:jsKey];
    JSObjectRef binding = [[jsBoundClasses objectForKey:name] jsObject];
    return binding ? binding : [[jsPrimeClasses objectForKey:name] jsObject];
}

JSValueRef __log__(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    NSLog(@"Log");
    return NULL;
}


void testFinalized(JSContextRef jsContext, JSObjectRef jsObject)
{

}

void testInitialized(JSContextRef jsContext, JSObjectRef jsObject)
{
    NSLog(@"initialized");
//    return JSValueMakeUndefined(jsContext);
}

JSObjectRef testCallAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    return (JSObjectRef)JSValueMakeUndefined(jsContext);
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

        if (jsPrimeClasses == nil) {
            jsPrimeClasses = [NSMutableDictionary new];
        }
        
        if (jsBoundClasses == nil) {
            jsBoundClasses = [NSMutableDictionary new];
        }
        
        // define the javascript object responsible for detecting bindings
        JSClassDefinition jsBindingManagerClassDef = kJSClassDefinitionEmpty;
        jsBindingManagerClassDef.getProperty = BSBindingManagerGetClass;
        jsBindingManagerClassDef.setProperty = BSBindingManagerSetClass;
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
        BSConsoleBinding* consoleBinding = [[BSConsoleBinding alloc] initWithScriptView:self];
        [self bind:consoleBinding toKey:@"console"];
        [consoleBinding release];
        
        //
        // TESTS
        //
        /*
        JSStaticFunction* jsFunctions = calloc(1 + 1, sizeof(JSStaticFunction));
        jsFunctions[0].name = [@"log" UTF8String];
        jsFunctions[0].attributes = kJSClassAttributeNone;
        jsFunctions[0].callAsFunction = __log__;

        JSClassDefinition jsBindingClassDef = kJSClassDefinitionEmpty;
        jsBindingClassDef.className = [@"TestClass" UTF8String];
        jsBindingClassDef.staticFunctions = jsFunctions;
        jsBindingClassDef.initialize = testInitialized;
        JSClassRef jsBindingClass = JSClassCreate(&jsBindingClassDef);
        
        JSObjectRef jsObject = JSObjectMake(self.jsGlobalContext, jsBindingClass, self);
        
        */
        
        
        JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
        jsClassDef.className = [@"TestClass" UTF8String];
        JSClassRef jsClass = JSClassCreate(&jsClassDef);
        
//        JSObjectRef jsObject = JSObjectMakeConstructor(self.jsGlobalContext, jsClass, testCallAsConstructor);
  
        JSObjectRef jsObject = JSObjectMakeFunction(self.jsGlobalContext, JSStringCreateWithUTF8CString("thafunc"), 0, NULL, JSStringCreateWithUTF8CString(""), NULL, 0, NULL);
  
        
        JSObjectSetProperty(self.jsGlobalContext, self.jsGlobalObject, JSStringCreateWithUTF8CString("testigne"), jsObject, kJSClassAttributeNone, NULL);
       
      
       //JSLogProps(self.jsGlobalContext, jsObject);
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
  
    [jsPrimeClasses release];
    [jsBoundClasses release];
  
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

- (void)bind:(BSBinding *)binding
{
    [bindings addObject:binding];
}

- (void)bind:(BSBinding *)binding toKey:(NSString*)key
{
    [self bind:binding toKey:key ofObject:self.jsGlobalObject];
}

- (void)bind:(BSBinding *)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject
{
    JSObjectSetProperty(self.jsGlobalContext, jsObject, [key jsStringValue], [binding jsBinding], kJSClassAttributeNone, NULL);
    [self bind:binding];
}

+ (NSString*)binding:(NSString*)name
{
    static NSDictionary* bindings = nil;
    
    if (bindings == nil) {
        bindings = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"BSViewBinding",   @"boxspring.View",
            @"BSWindowBinding", @"boxspring.Window",
        nil];
    }
    
    return [bindings objectForKey:name];
}

@end

