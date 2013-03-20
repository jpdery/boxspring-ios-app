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

static NSMutableDictionary* classes = nil;
static NSMutableDictionary* constructors = nil;

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

/**
 * Called when one of our fake constructor is initialized.
 * @since 0.0.1
 */
JSObjectRef jsConstructorCall(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    JSConstructorData* data = JSObjectGetPrivate(jsObject);
    
    Class binding = NSClassFromString([BGScriptView binding:data->name]);
    if (binding == nil) {
        NSLog(@"Binding class %@ does not exists.", binding);
        return NULL;
    }

    BGBinding* instance = [(BGBinding*)[binding alloc] initWithScriptView:data->view];
    JSObjectRef jsBinding = instance.jsObject;
    
    //
    // takes the class that the binding replaces, instantiate it and set it as
    // the replaced object prototype, this way we can still call methods that
    // are not defined in objective-c but are in javascript.
    //
    
    JSObjectSetPrototype(
        jsContext,
        jsBinding,
        JSObjectCallAsConstructor(
            jsContext,
            [[classes objectForKey:data->name] jsObject],
            argc,
            argv,
            NULL
        )
    );

    // call the binding constructor 
    objc_msgSend(instance, @selector(constructor:argc:argv:), jsContext, argc, argv);

    [data->view addBinding:instance];
    [binding release];
       
    return jsBinding;
}

/**
 * Called when a property of a constructor is set.
 * @since 0.0.1
 */
bool jsConstructorSetProperty(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    JSConstructorData* data = (JSConstructorData*)JSObjectGetPrivate(jsObject);
    
    NSData* jsClassData = [classes objectForKey:data->name];
    if (jsClassData) {
        JSObjectSetProperty(jsContext, [jsClassData jsObject], jsKey, jsVal, kJSClassAttributeNone, NULL);
        return true;
    }
    
    return false;
}

/**
 * Called when a property of a constructor is returned
 * @since 0.0.1
 */
JSValueRef jsConstructorGetProperty(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    JSConstructorData* data = JSObjectGetPrivate(jsObject);
    
    NSData* jsClassData = [classes objectForKey:data->name];
    if (jsClassData) {
        return [jsClassData jsValue];
    }
   
     return NULL;
}

/**
 * Called when an object is set within the __classes__ javascript object
 * @since 0.0.1
 */
bool jsClassSetter(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    [classes setObject:[NSData dataWithJSValueRef:jsVal] forKey:[NSString stringWithJSString:jsKey]];
    return true;
}

/**
 * Called when an object is retrieved within the __classes__ javascript object
 * @since 0.0.1
 */
JSValueRef jsClassGetter(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    NSString* name = [NSString stringWithJSString:jsKey];

    // this class has to be bound
    if ([BGScriptView binding:name]) {

        NSData* jsConstructorData = [constructors objectForKey:name];
        if (jsConstructorData) {
            return [jsConstructorData jsObject];
        }
        
        // create a new constructor class for this class binding
        JSClassDefinition jsConstructorClassDef = kJSClassDefinitionEmpty;
        jsConstructorClassDef.callAsConstructor = jsConstructorCall;
        jsConstructorClassDef.setProperty = jsConstructorSetProperty;
        jsConstructorClassDef.getProperty = jsConstructorGetProperty;
        JSClassRef jsConstructorClass = JSClassCreate(&jsConstructorClassDef);
        
        // create a struct to store the name of the class and teh script view
        JSConstructorData* data = malloc(sizeof(JSConstructorData));
		data->name = name;
		data->view = JSObjectGetPrivate(jsObject);
        
        // create the new constructor object
        JSObjectRef jsConstructorObject = JSObjectMake(jsContext, jsConstructorClass, data);
        [constructors setObject:[NSData dataWithJSObjectRef:jsConstructorObject] forKey:name];
        return jsConstructorObject;
    }

    // this class is not to be bound to anything
    NSData* jsValueData = [classes objectForKey:name];
    if (jsValueData) {
        return [jsValueData jsObject];
    }
    
    return NULL;
}

/**
 * Constructor
 * @since  0.0.1
 */
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

        if (classes == nil) {
            classes = [NSMutableDictionary new];
        }
        
        if (constructors == nil) {
            constructors = [NSMutableDictionary new];
        }
        
        // detect when a boxspring class is assigned or retrieved in order to dynamically bind some
        JSClassDefinition jsClassLoaderClassDef = kJSClassDefinitionEmpty;
        jsClassLoaderClassDef.getProperty = jsClassGetter;
        jsClassLoaderClassDef.setProperty = jsClassSetter;
        JSClassRef jsClassLoaderClass = JSClassCreate(&jsClassLoaderClassDef);

        // create the loader object and set the view as its private data
        JSObjectRef jsClassLoaderObject = JSObjectMake(self.jsGlobalContext, jsClassLoaderClass, self);

        JSObjectSetProperty(
            jsGlobalContext,
            jsGlobalObject,
            JSStringCreateWithUTF8CString(@"__classes__".UTF8String),
            jsClassLoaderObject,
            kJSPropertyAttributeNone,
            NULL
        );
        
        // load common bindings
        BGConsoleBinding* consoleBinding = [[BGConsoleBinding alloc] initWithScriptView:self];
        [self addBinding: consoleBinding toKey:@"console"];
        [consoleBinding release];
    }
    
    return self;
}

/**
 * Destructor
 * @since  0.0.1
 */
- (void)dealloc
{
    JSValueUnprotect(jsGlobalContext, jsNullValue);
    JSValueUnprotect(jsGlobalContext, jsTrueValue);
    JSValueUnprotect(jsGlobalContext, jsFalseValue);
    JSValueUnprotect(jsGlobalContext, jsUndefinedValue);
    JSGlobalContextRelease(jsGlobalContext);
  
    [super dealloc];
}

/**
 * Load script at a specified path.
 * @since 0.0.1
 */
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

/**
 * Execute script.
 * @since  0.0.1
 */
- (void)evalScript:(NSString *)source
{
    JSValueRef jsException = NULL;
	JSEvaluateScript(self.jsGlobalContext, JSStringCreateWithCFString((CFStringRef)source), NULL, NULL, 0, &jsException);
    [self log:jsException];
}

/**
 * Log an error message based on a javscript exception.
 * @since  0.0.1
 */
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

- (void)addBinding:(BGBinding *)binding
{
    [bindings addObject:binding];
}

- (void)addBinding:(BGBinding *)binding toKey:(NSString*)key
{
    [self addBinding:binding toKey:key ofObject:self.jsGlobalObject];
}

- (void)addBinding:(BGBinding *)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject
{
    [self addBinding:binding];
    
    JSObjectSetProperty(
        self.jsGlobalContext,
        jsObject,
        [key jsStringValue],
        [binding jsObject],
        kJSClassAttributeNone,
        NULL
    );
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
