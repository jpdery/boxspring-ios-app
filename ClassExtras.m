//
//  Class+Methods.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-30.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <objc/runtime.h>
#import "ClassExtras.h"

NSArray* class_getMethodsWithPrefix(Class class, NSString* prefix)
{/*
    NSMutableArray* methodsWithPrefix = [NSMutableArray new];
  
    while (class) {
        u_int count;
        Method* methods = class_copyMethodList(object_getClass(class), &count);
        for (u_int i = 0; i < count; i++) {
            NSString *name = NSStringFromSelector(method_getName(methods[i]));
            if ([name hasPrefix:prefix]) {
                [methodsWithPrefix addObject:name];

            }
        }
        free(methods);
        class = class.superclass;
    }

    NSArray* array = [NSArray arrayWithArray:methodsWithPrefix];
    
    [methodsWithPrefix release];

    return array;
    */
    return nil;
}