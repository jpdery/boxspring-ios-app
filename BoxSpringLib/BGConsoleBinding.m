//
//  BSConsoleBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGConsoleBinding.h"
#import "NSString+JavaScriptCoreString.h"

@implementation BGConsoleBinding

BG_DEFINE_BOUND_FUNCTION(log, log)

- (JSValueRef)log:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSMutableArray* args = [[NSMutableArray alloc] initWithCapacity: argc];
    for (int i = 0; i < argc; i++) {
        [args addObject:[NSString stringWithJSValue:argv[i] fromContext:self.scriptView.jsGlobalContext]];
    }
    NSString* output = [args componentsJoinedByString:@","];
    NSLog(@"JS: %@", output);
    [args release];
    return NULL;
}

@end
