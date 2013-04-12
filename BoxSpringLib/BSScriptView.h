//
//  BSScriptView.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BSBinding;

@interface BSScriptView : UIView

@property(nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property(nonatomic, readonly) JSObjectRef jsGlobalObject;
@property(nonatomic, readonly) JSValueRef jsUndefinedValue;
@property(nonatomic, readonly) JSValueRef jsNullValue;
@property(nonatomic, readonly, copy) NSMutableDictionary* primeConstructors;
@property(nonatomic, readonly, copy) NSMutableDictionary* boundConstructors;
@property(nonatomic, readonly, copy) NSMutableArray* boundInstances;
@property(nonatomic, readonly, copy) NSDictionary* bindings;

- (void)loadScript:(NSString*)source;
- (void)evalString:(NSString*)string;

- (void)bind:(BSBinding*)binding toKey:(NSString*)key;
- (void)bind:(BSBinding*)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject;

- (void)log:(JSValueRef)jsException;

- (void)didDefineObject:(JSObjectRef)jsObject name:(NSString*)name;
- (JSObjectRef)didCallObjectAsFunction:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;
- (JSObjectRef)didCallObjectAsConstructor:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;

@end
