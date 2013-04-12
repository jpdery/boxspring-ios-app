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

- (void)evalString:(NSString *)string
{
    JSValueRef jsException = NULL;
	JSEvaluateScript(self.jsGlobalContext, JSStringCreateWithCFString((CFStringRef)string), NULL, NULL, 0, &jsException);
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

- (void)bind:(BSBinding *)binding toKey:(NSString *)key
{
    [self bind:binding toKey:key ofObject:self.jsGlobalObject];
}

- (void)bind:(BSBinding *)binding toKey:(NSString *)key ofObject:(JSObjectRef)jsObject
{
    JSObjectSetProperty(self.jsGlobalContext, jsObject, [key jsStringValue], [binding jsBoundObject], kJSPropertyAttributeDontDelete, NULL);
    [boundInstances addObject:binding];
}

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
            Class class = NSClassFromString([bindings objectForKey:name]);
            BSBinding* binding = [(BSBinding*)[class alloc] initWithScriptView:self andPrototypeObject:jsProtoOwner];
            [boundInstances addObject:binding];
            JSObjectRef ret = binding.jsBoundObject;
            [binding constructor:self.jsGlobalContext argc:argc argv:argv];
            [binding release];
            return ret;
        }
        
        jsProtoOwner = jsProto;
        jsProto = (JSObjectRef)JSObjectGetPrototype(self.jsGlobalContext, jsProto);
    }
    
    return NULL;
}

- (JSObjectRef)didCallObjectAsConstructor:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    JSObjectRef jsBindingConstructor = [[boundConstructors objectForKey:name] jsObject];
    JSObjectRef jsBindingConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBindingConstructor);
    Class class = NSClassFromString([bindings objectForKey:name]);
    BSBinding* binding = [(BSBinding*)[class alloc] initWithScriptView:self andPrototypeObject:jsBindingConstructorPrototype];
    [boundInstances addObject:binding];
    JSObjectRef ret = binding.jsBoundObject;
    [binding constructor:self.jsGlobalContext argc:argc argv:argv];
    [binding release];
    return ret;
}

- (void)didCreateBinding:(BSBinding*)binding
{

}

/*
 * C Bindings
 */

typedef struct {
    NSString* name;
    BSScriptView* view;
} BSBindingData;

static bool
BSScriptViewClassSet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    BSScriptView* view = JSObjectGetPrivate(jsObject);
    [view didDefineObject:(JSObjectRef)jsVal name:[NSString stringWithJSString:jsKey]];
    return true;
}

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

static JSValueRef
BSScriptViewObjectCallAsFunction(JSContextRef jsContext, JSObjectRef jsFunction, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    BSBindingData* data = JSObjectGetPrivate(jsFunction);
    return [data->view didCallObjectAsFunction:jsObject name:data->name argc:argc argv:argv];
}

static JSObjectRef
BSScriptViewObjectCallAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    BSBindingData* data = JSObjectGetPrivate(jsObject);
    return [data->view didCallObjectAsConstructor:jsObject name:data->name argc:argc argv:argv];
}

@end
