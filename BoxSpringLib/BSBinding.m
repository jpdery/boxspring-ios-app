//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//


#import "JavaScriptCore+Extras.h"
#import "Geometry+Extras.h"

#import "BSBinding.h"
#import "BSScriptView.h"

@implementation BSBinding

@synthesize scriptView;
@synthesize jsContext;
@synthesize jsThisObject;
@synthesize jsBoundObject;
@synthesize jsBoundObjectPrototype;

- (id)initWithScriptView:(BSScriptView*)theScriptView
{
    if (self = [self init]) {
       
        scriptView = [theScriptView retain];
        
        jsContext = theScriptView.jsGlobalContext;

        JSClassDefinition jsBindingClassDef = JSClassDefinitionFromClass(self.class);
        jsBindingClassDef.className = NSStringFromClass(self.class).UTF8String;
        jsBindingClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
        JSClassRef jsBindingClass = JSClassCreate(&jsBindingClassDef);

        jsBoundObject = JSObjectMake(self.jsContext, jsBindingClass, self);
        jsBoundObjectPrototype = (JSObjectRef) JSObjectGetPrototype(self.jsContext, jsBoundObject);

        // make sure the binding object inherits the object prototype
        JSStringRef jsObjectString = JSStringCreateWithUTF8CString("Object");
        JSObjectRef jsObjectConstruct = (JSObjectRef) JSObjectGetProperty(jsContext, theScriptView.jsGlobalObject, jsObjectString, NULL);
        JSObjectRef jsObjectPrototype = JSObjectGetPrototypeProperty(jsContext, jsObjectConstruct);
        JSObjectSetPrototype(jsContext, jsBoundObject, jsObjectPrototype);
        JSStringRelease(jsObjectString);
        
        JSObjectSetBoundObject(self.jsContext, jsBoundObject, self);

        jsThisObject = jsBoundObject;
        
        JSValueProtect(self.jsContext, jsBoundObject);
    }

    return self;
}

- (id)initWithScriptView:(BSScriptView *)theScriptView prototype:(JSObjectRef)theJSPrototypeObject;
{
    if (self = [self initWithScriptView:theScriptView]) {
        
        jsBoundObjectPrototype = theJSPrototypeObject;
        
        JSObjectSetPrototype(
            self.jsContext,
            self.jsBoundObject,
            self.jsBoundObjectPrototype
        );
    }
    
    return self;
}

- (id)initWithScriptView:(BSScriptView *)theScriptView prototype:(JSObjectRef)theJSPrototypeObject this:(JSObjectRef)theJSSelfObject
{
    if (self = [self initWithScriptView:theScriptView prototype:theJSPrototypeObject]) {
        jsThisObject = theJSSelfObject;
    }
    return self;
}

- (void)dealloc
{
    JSValueUnprotect(self.jsContext, self.jsBoundObject);
    [scriptView release];
    [super dealloc];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    return [self call:name argc:argc argv:argv from:kBSBindingContextObjectParent];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv from:(BSBindingContextObject)context
{
    JSObjectRef jsContextObject;

    switch (context) {
        case kBSBindingContextObjectParent:
            jsContextObject = self.jsBoundObjectPrototype;
            break;
        case kBSBindingContextObjectSelf:
            jsContextObject = self.jsThisObject;
            break;
    }

    return JSObjectCallAsFunction(
        self.jsContext,
        (JSObjectRef) JSObjectGetProperty(self.jsContext, jsContextObject, NSStringToJSString(name), NULL),
        self.jsThisObject,
        argc,
        argv,
        NULL
    );
}

BS_DEFINE_BOUND_FUNCTION(__constructor, constructor)

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return [self call:@"__constructor" argc:argc argv:argv];
}

@end
