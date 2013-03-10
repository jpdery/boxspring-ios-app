//
//  BSConsoleBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSConsoleBinding.h"
#import "NSString+JavaScriptCoreString.h"

@implementation BSConsoleBinding

BS_BIND_FUNCTION(log, ctx, argc, argv) {
    
    NSMutableArray* arguments = [[NSMutableArray alloc] init];
    for (int i = 0; i < argc; i++) {
        NSString* value = [NSString stringWithJSValue:argv[i] fromContext:self.scriptView.context];
        [arguments addObject:value];
    }

    NSLog(@"LOG: %@", arguments);
    
    [arguments release];

    return NULL;
}

@end
