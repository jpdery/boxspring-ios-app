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
#import "JavaScriptCore.h"

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
    NSString* primeName;
    NSString* boundName;
    BSScriptView* view;
} BSBindingData;


static NSMutableDictionary* jsBindings = nil;

void JSStoreBindingByObject(JSObjectRef jsObject, BSBinding* binding)
{
    if (jsBindings == nil) {
        jsBindings = [NSMutableDictionary new];
    }
    
    [jsBindings setObject:binding forKey:[NSValue valueWithPointer:jsObject]];
}

BSBinding* JSRetrieveBindingByObject(JSObjectRef jsObject)
{
    if (jsBindings == nil) {
        return nil;
    }
    
    return [jsBindings objectForKey:[NSValue valueWithPointer:jsObject]];
}

JSValueRef BSBindingConstructorCalledAsFunction(JSContextRef jsContext, JSObjectRef jsObject, JSObjectRef jsThis, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    NSLog(@"Constructor called as function");
    BSBindingData* data = JSObjectGetPrivate(jsObject);
    
    JSObjectRef jsBinding = [[jsBoundClasses objectForKey:data->primeName] jsObject];
    JSObjectRef jsBindingPrototype = JSObjectGetPrototypeProperty(jsContext, jsBinding);
    JSObjectRef jsContructor = (JSObjectRef) JSObjectGetProperty(jsContext, jsBindingPrototype, JSStringCreateWithUTF8CString("constructor"), NULL);
    JSObjectRef jsInstance = JSObjectCreate(jsContext, jsBindingPrototype);
  
    Class boundClass = NSClassFromString(data->boundName);
    BSBinding* binding = [(BSBinding*)[boundClass alloc] initWithScriptView:data->view andObject:jsInstance argc:argc argv:argv];

    JSStoreBindingByObject(jsThis, binding);

    return jsThis;
}

JSObjectRef BSBindingConstructorCalledAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    NSLog(@"Constructor new");
    
    BSBindingData* data = JSObjectGetPrivate(jsObject);
    
    JSObjectRef jsBinding = [[jsBoundClasses objectForKey:data->primeName] jsObject];
    JSObjectRef jsBindingPrototype = JSObjectGetPrototypeProperty(jsContext, jsBinding);
    JSObjectRef jsContructor = (JSObjectRef) JSObjectGetProperty(jsContext, jsBindingPrototype, JSStringCreateWithUTF8CString("constructor"), NULL);
    JSObjectRef jsInstance = JSObjectCreate(jsContext, jsBindingPrototype);
    JSObjectCallAsFunction(jsContext, jsContructor, jsInstance, argc, argv, NULL);

    Class boundClass = NSClassFromString(data->boundName);
    BSBinding* binding = [(BSBinding*)[boundClass alloc] initWithScriptView:data->view andObject:jsInstance argc:argc argv:argv];
   
    JSStoreBindingByObject(jsInstance, binding);
    
    return jsInstance;
}

bool BSClassesSet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    NSString* primeName = [NSString stringWithJSString:jsKey];
    NSString* boundName = [BSScriptView binding:primeName];
    
    [jsPrimeClasses setObject:[NSData dataWithJSValueRef:jsVal] forKey:primeName];
    
    if (boundName) {

        Class boundClass = NSClassFromString(boundName);
        if (boundClass == nil) {
            return false;
        }
        
        //
        // Basically (using boxspring.View as example)
        //
        //     ViewBinding = function(){}
        //     ViewBinding.prototype = {
        //         (Methods that are defined within each bindings plus)
        //          [[PROTO]] = boxspring.View.prototype
        //	   ViewBinding.[[PROTO]] = Function.prototype
        //
        
        JSObjectRef jsPrimeConstructor = (JSObjectRef) jsVal;
        JSObjectRef jsPrimePrototype = (JSObjectRef) JSObjectGetProperty(jsContext, jsPrimeConstructor, JSStringCreateWithUTF8CString("prototype"), NULL);
                
        BSBindingData* BSBindingData = malloc(sizeof(BSBindingData));
        BSBindingData->boundName = boundName;
        BSBindingData->primeName = primeName;
        BSBindingData->view = JSObjectGetPrivate(jsObject);

        JSClassDefinition jsBindingPrototypeClassDef = [boundClass jsBoundClassDefinition];
        jsBindingPrototypeClassDef.className = [[boundName stringByAppendingString:@"Constructor"] UTF8String];
        jsBindingPrototypeClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
        JSClassRef jsBindingPrototypeClass = JSClassCreate(&jsBindingPrototypeClassDef);
               
        JSObjectRef jsBindingPrototype = JSObjectMake(jsContext, jsBindingPrototypeClass, BSBindingData);
        JSObjectSetPrototype(jsContext, jsBindingPrototype, jsPrimePrototype);

        JSClassDefinition jsBindingConstructorClassDef = kJSClassDefinitionEmpty;
        jsBindingConstructorClassDef.className = [[boundName stringByAppendingString:@"Object"] UTF8String];
        jsBindingConstructorClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
        jsBindingConstructorClassDef.callAsFunction = BSBindingConstructorCalledAsFunction;
        jsBindingConstructorClassDef.callAsConstructor = BSBindingConstructorCalledAsConstructor;
        JSClassRef jsBindingConstructorClass = JSClassCreate(&jsBindingConstructorClassDef);

        JSObjectRef jsBindingConstructor = JSObjectMake(jsContext, jsBindingConstructorClass, BSBindingData);
        JSObjectSetProperty(jsContext, jsBindingConstructor, JSStringCreateWithUTF8CString("parent"), jsPrimePrototype, kJSPropertyAttributeDontDelete, NULL);
        JSObjectSetProperty(jsContext, jsBindingConstructor, JSStringCreateWithUTF8CString("prototype"), jsBindingPrototype, kJSPropertyAttributeDontDelete, NULL);
        JSObjectSetProperty(jsContext, jsBindingPrototype, JSStringCreateWithUTF8CString("constructor"), jsBindingConstructor, kJSPropertyAttributeDontDelete, NULL);
        JSObjectInherit(jsContext, jsBindingConstructor, @"Function");

        [jsBoundClasses setObject:[NSData dataWithJSObjectRef:jsBindingConstructor] forKey:primeName];
    }
    
    return true;
}

JSValueRef BSClassesGet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    return [jsBoundClasses objectForKey:[NSString stringWithJSString:jsKey]]
        ? [[jsBoundClasses objectForKey:[NSString stringWithJSString:jsKey]] jsObject]
        : [[jsPrimeClasses objectForKey:[NSString stringWithJSString:jsKey]] jsObject];
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
        
        JSClassDefinition jsClassesManagerClassDef = kJSClassDefinitionEmpty;
        jsClassesManagerClassDef.setProperty = BSClassesSet;
        jsClassesManagerClassDef.getProperty = BSClassesGet;
        JSClassRef jsClassesManagerClass = JSClassCreate(&jsClassesManagerClassDef);
    
        JSObjectRef jsClassesManager = JSObjectMake(self.jsGlobalContext, jsClassesManagerClass, self);

        JSObjectSetProperty(
            jsGlobalContext,
            jsGlobalObject,
            JSStringCreateWithUTF8CString("__classes__"),
            jsClassesManager,
            kJSPropertyAttributeNone,
            NULL
        );
        
        // load common bindings
        [self bind:[[BSConsoleBinding alloc] initWithScriptView:self] toKey:@"console"]; // memory leak!
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
    JSObjectSetProperty(self.jsGlobalContext, jsObject, [key jsStringValue], [binding jsBoundObject], kJSClassAttributeNone, NULL);
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

