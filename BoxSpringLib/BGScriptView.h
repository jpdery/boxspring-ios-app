//
//  BSScriptView.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BGBinding;

@interface BGScriptView : UIView
   
@property(nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property(nonatomic, readonly) JSObjectRef jsGlobalObject;
@property(nonatomic, readonly) JSValueRef jsUndefinedValue;
@property(nonatomic, readonly) JSValueRef jsNullValue;
@property(nonatomic, readonly) JSValueRef jsTrueValue;
@property(nonatomic, readonly) JSValueRef jsFalseValue;
@property(nonatomic, copy) NSMutableArray* bindings;

- (void)loadScript:(NSString*)path;
- (void)evalScript:(NSString*)source;

- (void)bind:(BGBinding*)binding;
- (void)bind:(BGBinding*)binding toKey:(NSString*)key;
- (void)bind:(BGBinding*)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject;

- (void)log:(JSValueRef)jsException;

// temp
+ (NSString*)binding:(NSString*)name;

@end
