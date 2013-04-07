//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"
#import "JavaScriptCore+extras.h"
#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"
#import "Geometry+Extras.h"

@implementation BSBinding

@synthesize scriptView;
@synthesize jsGlobalContext;
@synthesize jsGlobalObject;
@synthesize jsBoundObject;
@synthesize jsBoundObjectPrototype;

BS_DEFINE_BOUND_FUNCTION(__constructor, constructor)

- (id)initWithScriptView:(BSScriptView*)theScriptView
{
    if (self = [self init]) {
        scriptView = [theScriptView retain];
        jsGlobalObject = theScriptView.jsGlobalObject;
        jsGlobalContext = theScriptView.jsGlobalContext;
    }
    return self;
}

- (id)initWithScriptView:(BSScriptView*)theScriptView andBoundObject:(JSObjectRef)theJSBoundObject
{
    if (self = [self initWithScriptView:theScriptView]) {
       jsBoundObject = theJSBoundObject;
       jsBoundObjectPrototype = (JSObjectRef)JSObjectGetPrototype(self.jsGlobalContext, jsBoundObject);
       [BSBindingManager associateBinding:self toObject:jsBoundObject ofContext:self.jsGlobalContext];
    }
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    return [self call:name argc:argc argv:argv ofObject:self.jsBoundObject];
}

- (JSValueRef)call:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv ofObject:(JSObjectRef)jsObject
{
    if ([name isEqualToString:@"constructor"]) name = @"__constructor";

    JSObjectRef jsFunction = (JSObjectRef) JSObjectGetProperty(self.jsGlobalContext, jsObject, [name jsStringValue], NULL);
    if (jsFunction == NULL) {
        return NULL;
    }

    return JSObjectCallAsFunction(self.jsGlobalContext, jsFunction, self.jsBoundObject, argc, argv, NULL);
}

- (JSValueRef)callParent:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv
{
    return [self call:name argc:argc argv:argv ofObject:self.jsBoundObjectPrototype];
}

/* Bindings */

- (JSValueRef)constructor:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    [self call:@"constructor" argc:argc argv:argv ofObject:self.jsBoundObjectPrototype];
    return NULL;
}


@end
