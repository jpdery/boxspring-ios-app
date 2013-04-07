//
//  BSBindingManager.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-04.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBindingManager.h"
#import "BSBinding.h"
#import "BSScriptView.h"
#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"
#import "JavaScriptCore+Extras.h"

static NSMutableDictionary* jsObjectMapptings;

@implementation BSBindingManager

@synthesize definitions;
@synthesize primeConstructorObjects;
@synthesize boundConstructorObjects;
@synthesize scriptView;
@synthesize jsGlobalContext;
@synthesize jsGlobalObject;

- (id)init
{
    if (self = [super init]) {
        
        primeConstructorObjects = [NSMutableDictionary new];
        boundConstructorObjects = [NSMutableDictionary new];
        
        if (definitions == nil) {
            definitions = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"BSViewBinding",   @"boxspring.View",
                @"BSWindowBinding", @"boxspring.Window",
            nil];
        }
    }
    
    return self;
}

- (id)initWithScriptView:(BSScriptView *)theScriptView
{
    if (self = [self init]) {
        
        scriptView = [theScriptView retain];
        jsGlobalContext = theScriptView.jsGlobalContext;
        jsGlobalObject = theScriptView.jsGlobalObject;
        
        JSClassDefinition jsClassesManagerClassDef = kJSClassDefinitionEmpty;
        jsClassesManagerClassDef.setProperty = BSBindingManagerClassSet;
        jsClassesManagerClassDef.getProperty = BSBindingManagerClassGet;
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
    }
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [primeConstructorObjects release];
    [boundConstructorObjects release];
    [super dealloc];
}

- (NSString*)boundNameFromPrimeName:(NSString*)name
{
    return [definitions objectForKey:name];
}

- (NSString*)primeNameFromBoundName:(NSString*)name
{
    return [[definitions allKeysForObject:name] objectAtIndex:0];
}

- (void)storePrimeConstructorObject:(JSObjectRef)jsPrimeConstructor as:(NSString*)name
{
    [primeConstructorObjects setValue:[NSData dataWithJSObjectRef:jsPrimeConstructor] forKey:name];
}

- (void)storeBoundConstructorObject:(JSObjectRef)jsBoundConstructor as:(NSString*)name
{
    [boundConstructorObjects setValue:[NSData dataWithJSObjectRef:jsBoundConstructor] forKey:name];
}

- (JSObjectRef)retrievePrimeConstructorObject:(NSString*)name
{
    NSData* data = [primeConstructorObjects objectForKey:name];
    return data ? [data jsObject] : NULL;
}

- (JSObjectRef)retrieveBoundConstructorObject:(NSString*)name
{
    NSData* data = [boundConstructorObjects objectForKey:name];
    return data ? [data jsObject] : NULL;
}

- (JSObjectRef)retrieveProperConstructorObject:(NSString*)name;
{
    return [boundConstructorObjects objectForKey:name]
        ? [[boundConstructorObjects objectForKey:name] jsObject]
        : [[primeConstructorObjects objectForKey:name] jsObject];
}

- (BSBinding*)createBindingWithClass:(Class)class;
{
    NSString* name = NSStringFromClass(class);

    JSClassDefinition jsBindingClassDef = JSClassDefinitionFrom(class);
    jsBindingClassDef.className = name.UTF8String;
    jsBindingClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    JSClassRef jsBindingClass = JSClassCreate(&jsBindingClassDef);

    JSObjectRef jsBound = JSObjectMake(self.jsGlobalContext, jsBindingClass, self);
    JSObjectInheritObject(self.jsGlobalContext, jsBound);

    return [[(BSBinding*)[class alloc] initWithScriptView:self.scriptView andBoundObject:jsBound] autorelease];
}

- (BSBinding*)createBindingWithPrimeClassName:(NSString*)name
{
    JSObjectRef jsBindingConstructor = [self retrieveBoundConstructorObject:name];
    JSObjectRef jsBindingConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBindingConstructor);
 
    Class class = NSClassFromString([self boundNameFromPrimeName:name]);
 
    JSClassDefinition jsBindingClassDef = JSClassDefinitionFrom(class);
    jsBindingClassDef.className = name.UTF8String;
    jsBindingClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    JSClassRef jsBindingClass = JSClassCreate(&jsBindingClassDef);
    
    JSObjectRef jsBound = JSObjectMake(self.jsGlobalContext, jsBindingClass, NULL);
    JSObjectSetPrototype(self.jsGlobalContext, jsBound, jsBindingConstructorPrototype);
 
    return [[(BSBinding*)[class alloc] initWithScriptView:self.scriptView andBoundObject:jsBound] autorelease];
}

- (BSBinding*)createBindingWithBoundClassName:(NSString*)name
{   
    return [self createBindingWithPrimeClassName:[self primeNameFromBoundName:name]];
}

- (void)destroyBinding:(BSBinding*)binding
{
    // TODO
}

- (void)didDefineManagedObject:(JSObjectRef)jsObject name:(NSString*)name
{

    [self storePrimeConstructorObject:jsObject as:name];
   
    NSString* boundName = [self boundNameFromPrimeName:name];
    if (boundName) {

        //
        // Basically (using boxspring.View as example)
        //
        //     ViewBinding = function(){}
        //	   ViewBinding.[[PROTO]] = Function.prototype
        //     Copy all properties from boxpsring.View to ViewBinding
        //     ViewBinding.prototype.__constructor = boxspring.View.prototype.constructor
        //

        Class boundClass = NSClassFromString(boundName);
        if (boundClass == nil) {
            NSLog(@"Error: The prime object %@ is bound to %@ but this class does not exists", name, boundName);
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
        data->manager = self;
        
        JSClassDefinition jsBindingConstructorClassDef = kJSClassDefinitionEmpty;
        jsBindingConstructorClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
        jsBindingConstructorClassDef.callAsFunction = BSBindingManagerCallAsFunction;
        jsBindingConstructorClassDef.callAsConstructor = BSBindingManagerCallAsConstructor;
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

        [self storeBoundConstructorObject:jsBindingConstructor as:name];
    }
}

- (JSObjectRef)didCallManagedObjectAsFunction:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    BSBinding* instance = [BSBindingManager bindingAssociatedToObject:jsObject ofContext:self.jsGlobalContext];
    if (instance) {
        JSObjectRef jsBoundConstructor = [self retrieveBoundConstructorObject:name];
        JSObjectRef jsBoundConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBoundConstructor);
        JSObjectRef jsConstructor = (JSObjectRef)JSObjectGetProperty(self.jsGlobalContext, jsBoundConstructorPrototype, JSStringCreateWithUTF8CString("__constructor"), NULL);
        JSObjectRef ret = (JSObjectRef)JSObjectCallAsFunction(self.jsGlobalContext, jsConstructor, jsObject, argc, argv, NULL);
        return ret ? ret : jsObject;
    }

    JSObjectRef jsBoundConstructor = [self retrieveBoundConstructorObject:name];
    JSObjectRef jsBoundConstructorPrototype = JSObjectGetPrototypeProperty(self.jsGlobalContext, jsBoundConstructor);
    JSObjectRef jsProto = (JSObjectRef)JSObjectGetPrototype(self.jsGlobalContext, jsObject);
    JSObjectRef jsProtoOwner = jsObject;

    while (jsProto) {
    
        if (jsProto == jsBoundConstructorPrototype) {
            BSBinding* binding = [self createBindingWithPrimeClassName:name];
            JSObjectSetPrototype(self.jsGlobalContext, jsProtoOwner, binding.jsBoundObject);
            [BSBindingManager associateBinding:binding toObject:binding.jsBoundObject ofContext:self.jsGlobalContext];
            return (JSObjectRef)[binding constructor:self.jsGlobalContext argc:argc argv:argv];
        }
        
        jsProtoOwner = jsProto;
        jsProto = (JSObjectRef)JSObjectGetPrototype(self.jsGlobalContext, jsProto);
    }
    
    return NULL;
}

- (JSObjectRef)didCallManagedObjectAsConstructor:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    BSBinding* binding = [self createBindingWithPrimeClassName:name];
    [binding constructor:self.jsGlobalContext argc:argc argv:argv];
    return binding.jsBoundObject;
}

+ (BSBinding*)bindingAssociatedToObject:(JSObjectRef)jsObject ofContext:(JSContextRef)jsContext
{
    if (jsObjectMapptings == nil)
        return nil;

    JSValueRef jsIntanceId = JSObjectGetProperty(jsContext, jsObject, JSStringCreateWithUTF8CString("__instance_id"), NULL);
    if (jsIntanceId == NULL)
        return nil;

    return [jsObjectMapptings objectForKey:[NSString stringWithJSString:JSValueToStringCopy(jsContext, jsIntanceId, NULL)]];

    return nil;
}

+ (void)associateBinding:(BSBinding *)binding toObject:(JSObjectRef)jsObject ofContext:(JSContextRef)jsContext
{
    static int instances = 0;

    if (jsObjectMapptings == nil) {
        jsObjectMapptings = [NSMutableDictionary new];
    }

    NSString* identifier = [NSString stringWithFormat:@"instance#%i", instances++];

    JSObjectSetProperty(
        jsContext,
        jsObject,
        JSStringCreateWithUTF8CString("__instance_id"),
        JSValueMakeString(jsContext, [identifier jsStringValue]),
        kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly,
        NULL
    );
    
    [jsObjectMapptings setObject:binding forKey:identifier];
}

/* C Bindings */

typedef struct {
    NSString* name;
    BSBindingManager* manager;
} BSBindingData;

static bool
BSBindingManagerClassSet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef jsVal, JSValueRef* jsException)
{
    BSBindingManager* manager = JSObjectGetPrivate(jsObject);
    [manager didDefineManagedObject:(JSObjectRef)jsVal name:[NSString stringWithJSString:jsKey]];
    return true;
}

static JSValueRef
BSBindingManagerClassGet(JSContextRef jsContext, JSObjectRef jsObject, JSStringRef jsKey, JSValueRef* jsException)
{
    BSBindingManager* manager = JSObjectGetPrivate(jsObject);
    return [manager retrieveProperConstructorObject:[NSString stringWithJSString:jsKey]];
}

static JSValueRef
BSBindingManagerCallAsFunction(JSContextRef jsContext, JSObjectRef jsFunction, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    BSBindingData* data = JSObjectGetPrivate(jsFunction);
    return [data->manager didCallManagedObjectAsFunction:jsObject name:data->name argc:argc argv:argv];
}

static JSObjectRef
BSBindingManagerCallAsConstructor(JSContextRef jsContext, JSObjectRef jsObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    BSBindingData* data = JSObjectGetPrivate(jsObject);
    return [data->manager didCallManagedObjectAsConstructor:jsObject name:data->name argc:argc argv:argv];
}

@end
