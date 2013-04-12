//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//


#import "JavaScriptCore+Extras.h"
#import "Geometry+Extras.h"
#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"

#import "BSBinding.h"
#import "BSScriptView.h"

@implementation BSBinding

@synthesize scriptView;
@synthesize jsContext;
@synthesize jsBoundObject;
@synthesize jsBoundObjectPrototype;

/*
 * Initialization
 */

- (id)initWithScriptView:(BSScriptView*)theScriptView
{
    if (self = [self init]) {

        scriptView = [theScriptView retain];

        jsContext = theScriptView.jsGlobalContext;

        JSClassDefinition jsBindingClassDef = JSClassDefinitionFrom(self.class);
        jsBindingClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
        JSClassRef jsBindingClass = JSClassCreate(&jsBindingClassDef);

        jsBoundObject = JSObjectMake(self.jsContext, jsBindingClass, self);
        jsBoundObjectPrototype = (JSObjectRef)JSObjectGetPrototype(self.jsContext, jsBoundObject);
        JSObjectInheritObject(self.jsContext, jsBoundObject);
        JSObjectSetBoundObject(self.jsContext, jsBoundObject, self);
    }

    return self;
}

- (id)initWithScriptView:(BSScriptView *)theScriptView andPrototypeObject:(JSObjectRef)jsPrototypeObject;
{
    if (self = [self initWithScriptView:theScriptView]) {
        jsBoundObjectPrototype = jsPrototypeObject;
        JSObjectSetPrototype(self.jsContext, self.jsBoundObject, self.jsBoundObjectPrototype);
    }
    
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

/*
 * Bridge
 */

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    return [self call:name argc:argc argv:argv ofObject:self.jsBoundObjectPrototype];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv ofObject:(JSObjectRef)jsObject
{
    return JSObjectCallAsFunction(
        self.jsContext,
        (JSObjectRef) JSObjectGetProperty(self.jsContext, jsObject, [name jsStringValue], NULL),
        self.jsBoundObject,
        argc,
        argv,
        NULL
    );
}

 /*
  * Bound Methods
  */

BS_DEFINE_BOUND_FUNCTION(__constructor, constructor)

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return [self call:@"__constructor" argc:argc argv:argv];
}

@end
