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

@class BSBinding;
@class BSBindingManager;

@interface BSScriptView : UIView
   
@property(nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property(nonatomic, readonly) JSObjectRef jsGlobalObject;
@property(nonatomic, readonly) JSValueRef jsUndefinedValue;
@property(nonatomic, readonly) JSValueRef jsNullValue;
@property(nonatomic, readonly) BSBindingManager* bindingManager;

- (void)loadScript:(NSString*)path;
- (void)evalScript:(NSString*)source;

- (void)bind:(BSBinding*)binding toKey:(NSString*)key;
- (void)bind:(BSBinding*)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject;

- (void)log:(JSValueRef)jsException;

@end
