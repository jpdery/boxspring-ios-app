//
//  BSScriptView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"
#import "JavaScriptCore+Extras.h"
#import "BSScriptView.h"
#import "BSViewBinding.h"
#import "BSWindowBinding.h"
#import "BSConsoleBinding.h"
#import "BSBinding.h"

@implementation BSScriptView

@synthesize bindings;
@synthesize primeConstructors;
@synthesize boundConstructors;
@synthesize boundInstances;
@synthesize jsGlobalObject;
@synthesize jsGlobalContext;
@synthesize jsUndefinedValue;
@synthesize jsNullValue;

/**
 * Initialize the view, create the javascript context and monitors class 
 * definitions
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        jsGlobalContext = JSGlobalContextCreate(NULL);
        jsGlobalObject = JSContextGetGlobalObject(jsGlobalContext);
        jsUndefinedValue = JSValueMakeUndefined(jsGlobalContext);
        jsNullValue = JSValueMakeNull(jsGlobalContext);
        JSValueProtect(jsGlobalContext, jsUndefinedValue);
        JSValueProtect(jsGlobalContext, jsNullValue);

        bindings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Bindings" ofType:@"plist"]];
        boundInstances = [NSMutableArray new];
        boundConstructors = [NSMutableDictionary new];
        primeConstructors = [NSMutableDictionary new];

        JSClassDefinition jsClassesManagerClassDef = kJSClassDefinitionEmpty;
        jsClassesManagerClassDef.setProperty = BSScriptViewClassSet;
        jsClassesManagerClassDef.getProperty = BSScriptViewClassGet;
        JSClassRef jsClassesManagerClass = JSClassCreate(&jsClassesManagerClassDef);
    
        JSObjectRef jsClassesManager = JSObjectMake(self.jsGlobalContext, jsClassesManagerClass, self);

        JSObjectSetProperty(
            jsGlobalContext,
            JSContextGetGlobalObject(jsGlobalContext),
            JSStringCreateWithUTF8CString("__classes__"),
            jsClassesManager,
            kJSPropertyAttributeNone,
            NULL
        );
        
        BSConsoleBinding* console = [[BSConsoleBinding alloc] initWithScriptView:self];
        [self bind:console toKey:@"console"];
        [console release];
    }
    
    return self;
}

/**
 * Executed when the view is deallocated
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)dealloc
{
    JSValueUnprotect(jsGlobalContext, jsNullValue);
    JSValueUnprotect(jsGlobalContext, jsUndefinedValue);
    JSGlobalContextRelease(jsGlobalContext);

    [bindings release];
    [boundInstances release];
    [boundConstructors release];
    [primeConstructors release];

    [super dealloc];
}

/**
 * Load and evaluate a script at a specified path within the app folder
 *
 * @param  source The file to evaluate
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)loadScript:(NSString *)source
{
    source = [NSString stringWithFormat:@"%@/App/%@", [[NSBundle mainBundle] resourcePath], source];

    NSString *script = [NSString stringWithContentsOfFile:source encoding:NSUTF8StringEncoding error:NULL];
    if (script == nil) {
        NSLog(@"Error: Script at path %@ cannot be loaded.", source);
        return;
    }
    
    [self evalString:script];
}

/**
 * Execute a string of javascript
 *
 * @param  string The string to evaluate
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)evalString:(NSString *)string
{
    JSValueRef jsException = NULL;
	JSEvaluateScript(self.jsGlobalContext, JSStringCreateWithCFString((CFStringRef)string), NULL, NULL, 0, &jsException);
    [self log:jsException];
}

/**
 * Log an exception to the console
 *
 * @param  jsException The javascript exception object.
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
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

/**
 * Binds a binding instance to a given key of the global object
 *
 * @param  binding The binding instance
 * @param  key The key of the global object used to store the binding
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)bind:(BSBinding *)binding toKey:(NSString *)key
{
    [self bind:binding toKey:key ofObject:self.jsGlobalObject];
}

- (BSBinding*)newBindingNamed:(NSString*)name
{
    JSObjectRef jsBoundConstructor = [[boundConstructors objectForKey:name] jsObject];
    JSObjectRef jsBoundConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBoundConstructor);
    return [self newBindingNamed:name withPrototypeObject:jsBoundConstructorPrototype];
}

- (BSBinding*)newBindingNamed:(NSString*)name withPrototypeObject:(JSObjectRef)jsPrototype
{
    Class class = NSClassFromString([bindings objectForKey:name]);
    BSBinding* binding = [(BSBinding*)[class alloc] initWithScriptView:self andPrototypeObject:jsPrototype];
    [boundInstances addObject:binding];
    return [binding autorelease];
}

/**
 * Binds a binding instance to a given key of a specified object
 *
 * @param  binding The binding instance
 * @param  key The key of the specified object used to store the binding
 * @param  jsObject The javascript object the binding will be assigned to
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)bind:(BSBinding *)binding toKey:(NSString *)key ofObject:(JSObjectRef)jsObject
{
    JSObjectSetProperty(self.jsGlobalContext, jsObject, [key jsStringValue], [binding jsBoundObject], kJSPropertyAttributeDontDelete, NULL);
    [boundInstances addObject:binding];
}

/**
 * Called when an javascript class object is defined using boxspring.define
 *
 * @param  jsObject The javascript object that has been defined
 * @param  name The name of the javascript class object
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)didDefineObject:(JSObjectRef)jsObject name:(NSString*)name
{
    [primeConstructors setValue:[NSData dataWithJSObjectRef:jsObject] forKey:name];
   
    NSString* bindingName = [bindings objectForKey:name];
    if (bindingName) {

        //
        // Basically (using boxspring.View as example)
        //
        //     ViewBinding = function(){}
        //	   ViewBinding.[[PROTO]] = Function.prototype
        //     Copy all properties from boxpsring.View to ViewBinding
        //     ViewBinding.prototype.__constructor = boxspring.View.prototype.constructor
        //

        Class bindingClass = NSClassFromString(bindingName);
        if (bindingClass == nil) {
            NSLog(@"Error: The prime object %@ is bound to %@ but this class does not exists", name, bindingName);
            return;
        }
        
        JSObjectRef jsPrimeConstructor = jsObject;
        JSObjectRef jsPrimePrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsPrimeConstructor);
        JSObjectRef JSPrimePrototypeConstructor = JSObjectGetConstructorProperty(self.jsGlobalContext, jsPrimePrototype);
 
        JSObjectSetProperty(
            self.jsGlobalContext,
            jsPrimePrototype,
            JSStringCreateWithUTF8CString("__constructor"),
            JSPrimePrototypeConstructor,
            kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly,
            NULL
        );
 
        BSBindingData* data = malloc(sizeof(BSBindingData));
        data->name = name;
        data->view = self;
        
        JSClassDefinition jsBindingConstructorClassDef = kJSClassDefinitionEmpty;
        jsBindingConstructorClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
        jsBindingConstructorClassDef.callAsFunction = BSScriptViewObjectCallAsFunction;
        jsBindingConstructorClassDef.callAsConstructor = BSScriptViewObjectCallAsConstructor;
        JSClassRef jsBindingConstructorClass = JSClassCreate(&jsBindingConstructorClassDef);

        JSObjectRef jsBindingConstructor = JSObjectMake(self.jsGlobalContext, jsBindingConstructorClass, data);
        JSObjectCopyProperties(self.jsGlobalContext, jsPrimeConstructor, jsBindingConstructor);
        JSObjectInheritFunction(self.jsGlobalContext, jsBindingConstructor);

        JSObjectSetProperty(
            self.jsGlobalContext,
            JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBindingConstructor),
            JSStringCreateWithUTF8CString("constructor"),
            jsBindingConstructor,
            kJSPropertyAttributeDontDelete,
            NULL
        );

        [boundConstructors setValue:[NSData dataWithJSObjectRef:jsBindingConstructor] forKey:name];
    }
}

/**
 * Called when a javascript class object is called as a function
 *
 * @param  jsObject The javascript object that has been called
 * @param  name The name of the javascript class object
 * @param  argc The ammount of arguments given to the function
 * @param  argv The values of each arguments
 * @return The object the function returns
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSObjectRef)didCallObjectAsFunction:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    BSBinding* instance = (BSBinding*)JSObjectGetBoundObject(self.jsGlobalContext, jsObject);
    if (instance) {
        JSObjectRef jsBoundConstructor = [[boundConstructors objectForKey:name] jsObject];
        JSObjectRef jsBoundConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBoundConstructor);
        JSObjectRef jsConstructor = (JSObjectRef)JSObjectGetProperty(self.jsGlobalContext, jsBoundConstructorPrototype, JSStringCreateWithUTF8CString("__constructor"), NULL);
        JSObjectRef ret = (JSObjectRef)JSObjectCallAsFunction(self.jsGlobalContext, jsConstructor, jsObject, argc, argv, NULL);
        return ret ? ret : jsObject;
    }

    JSObjectRef jsBoundConstructor = [[boundConstructors objectForKey:name] jsObject];
    JSObjectRef jsBoundConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBoundConstructor);
    JSObjectRef jsProto = (JSObjectRef)JSObjectGetPrototype(self.jsGlobalContext, jsObject);
    JSObjectRef jsProtoOwner = jsObject;

    while (jsProto) {
    
        if (jsProto == jsBoundConstructorPrototype) {
            BSBinding* binding = [self newBindingNamed:name withPrototypeObject:jsBoundConstructorPrototype];
            JSObjectSetPrototype(self.jsGlobalContext, jsProtoOwner, binding.jsBoundObject);
            JSObjectRef ret = (JSObjectRef)[binding constructor:self.jsGlobalContext argc:argc argv:argv];
            return ret ? ret : binding.jsBoundObject;
        }
        
        jsProtoOwner = jsProto;
        jsProto = (JSObjectRef)JSObjectGetPrototype(self.jsGlobalContext, jsProto);
    }
    
    return NULL;
}

/**
 * Called when a javascript class object is called as a constructor using the 
 * new keyword
 *
 * @param  jsObject The javascript object that has been called
 * @param  name The name of the javascript class object
 * @param  argc The ammount of arguments given to the function
 * @param  argv The values of each arguments
 * @return The object the function returns
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSObjectRef)didCallObjectAsConstructor:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    BSBinding* binding = [self newBindingNamed:name];
    [binding constructor:self.jsGlobalContext argc:argc argv:argv];
    return binding.jsBoundObject;
}

/**
 * Data structure passed to bound javascript objects.
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
typedef struct {
    NSString* name;
    BSScriptView* view;
} BSBindingData;

/**
 * JavaScriptCore callback
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
static bool
BSScriptViewClassSet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    BSScriptView* view = JSObjectGetPrivate(jsObject);
    [view didDefineObject:(JSObjectRef)jsVal name:[NSString stringWithJSString:jsKey]];
    return true;
}

/**
 * JavaScriptCore callback
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
static JSValueRef
BSScriptViewClassGet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    NSString* name = [NSString stringWithJSString:jsKey];

    BSScriptView* view = JSObjectGetPrivate(jsObject);
    NSMutableDictionary* primeConstructors = view.primeConstructors;
    NSMutableDictionary* boundConstructors = view.boundConstructors;
    
    return [boundConstructors objectForKey:name]
        ? [[boundConstructors objectForKey:name] jsObject]
        : [[primeConstructors objectForKey:name] jsObject];
}

/**
 * JavaScriptCore callback
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
static JSValueRef
BSScriptViewObjectCallAsFunction(JSContextRef jsContext, JSObjectRef jsFunction, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    BSBindingData* data = JSObjectGetPrivate(jsFunction);
    return [data->view didCallObjectAsFunction:jsObject name:data->name argc:argc argv:argv];
}

/**
 * JavaScriptCore callback
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
static JSObjectRef
BSScriptViewObjectCallAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    BSBindingData* data = JSObjectGetPrivate(jsObject);
    return [data->view didCallObjectAsConstructor:jsObject name:data->name argc:argc argv:argv];
}

@end
