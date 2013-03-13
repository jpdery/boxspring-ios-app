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

#define APP_FOLDER App

@class BSBinding;

@interface BSScriptView : UIView {
    
    JSGlobalContextRef jsGlobalContext;
    JSValueRef jsUndefinedValue;
    JSValueRef jsNullValue;
    JSValueRef jsTrueValue;
    JSValueRef jsFalseValue;
    
    NSMutableArray* bindings;
}

@property(nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property(nonatomic, readonly) JSValueRef jsUndefinedValue;
@property(nonatomic, readonly) JSValueRef jsNullValue;
@property(nonatomic, readonly) JSValueRef jsTrueValue;
@property(nonatomic, readonly) JSValueRef jsFalseValue;

@property(nonatomic, retain) NSMutableArray* bindings;

- (void)loadScript:(NSString*)path;
- (void)evalScript:(NSString*)source;
- (void)handleException:(JSValueRef)jsException;
- (NSString*)pathForResource:(NSString*)resource;

- (BSBinding*)bind:(Class)boundClass toKey:(NSString*)key;
- (BSBinding*)bind:(Class)boundClass toKey:(NSString*)key ofObject:(JSObjectRef)jsObject;


@end
