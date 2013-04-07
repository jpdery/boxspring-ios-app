//
//  BSBindingManager.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-04.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BSBinding;
@class BSScriptView;

@interface BSBindingManager : NSObject

@property (nonatomic, readonly) NSDictionary* definitions;
@property (nonatomic, readonly) BSScriptView* scriptView;
@property (nonatomic, readonly, copy) NSMutableDictionary* primeConstructorObjects;
@property (nonatomic, readonly, copy) NSMutableDictionary* boundConstructorObjects;
@property (nonatomic, readonly) JSContextRef jsGlobalContext;
@property (nonatomic, readonly) JSObjectRef jsGlobalObject;

- (id)initWithScriptView:(BSScriptView*)theScriptView;

- (NSString*)boundNameFromPrimeName:(NSString*)name;
- (NSString*)primeNameFromBoundName:(NSString*)name;

- (void)storePrimeConstructorObject:(JSObjectRef)jsPrimeConstructor as:(NSString*)name;
- (void)storeBoundConstructorObject:(JSObjectRef)jsBoundConstructor as:(NSString*)name;
- (JSObjectRef)retrievePrimeConstructorObject:(NSString*)name;
- (JSObjectRef)retrieveBoundConstructorObject:(NSString*)name;
- (JSObjectRef)retrieveProperConstructorObject:(NSString*)name;

- (BSBinding*)createBindingWithClass:(Class)class;
- (BSBinding*)createBindingWithPrimeClassName:(NSString*)name;
- (BSBinding*)createBindingWithBoundClassName:(NSString*)name;
- (void)destroyBinding:(BSBinding*)binding;

- (void)didDefineManagedObject:(JSObjectRef)jsObject name:(NSString*)name;
- (JSObjectRef)didCallManagedObjectAsFunction:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSObjectRef)didCallManagedObjectAsConstructor:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;

+ (BSBinding*)bindingAssociatedToObject:(JSObjectRef)jsObject ofContext:(JSContextRef)jsContext;
+ (void)associateBinding:(BSBinding*)binding toObject:(JSObjectRef)jsObject ofContext:(JSContextRef)jsContext;

@end
