//
//  BSScriptView.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include <objc/message.h>

@class BSBinding;

@interface BSScriptView : UIView {
    JSGlobalContextRef context;
    @public JSValueRef undefined;
}

@property(nonatomic, readonly) JSGlobalContextRef context;
@property(nonatomic, readonly) JSValueRef undefined;
@property(nonatomic, copy) NSMutableArray* bindings;

- (void)loadScriptFromFile:(NSString *)file;

- (void)addGlobalObject:(NSString*)objectName usingClass:(JSClassRef)objectClass withPrivateData:(void*)privateData;
- (void)addGlobalObject:(NSString*)objectName usingBinding:(BSBinding *)objectBinding withPrivateData:(void*)privateData;

- (JSClassRef)createJSClass:(id)class;

@end
