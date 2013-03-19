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

BG_BIND_FUNCTION(log, jsLog)
BG_BIND_FUNCTION(info, jsLog)
BG_BIND_FUNCTION(warn, jsLog)
BG_BIND_FUNCTION(debug, jsLog)
BG_BIND_FUNCTION(error, jsLog)

/**
 *
 */
- (JSValueRef)jsLog:(JSContextRef)context argc:(size_t)argc argv:(const JSValueRef[])argv
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

//BS_BIND_FUNCTION(log, ctx, argc, argv) {
//    
//    NSMutableArray* arguments = [[NSMutableArray alloc] init];
//    for (int i = 0; i < argc; i++) {
//        NSString* value = [NSString stringWithJSValue:argv[i] fromContext:self.scriptView.context];
//        [arguments addObject:value];
//    }
//
//    NSLog(@"LOG: %@", arguments);
//    
//    [arguments release];
//
//    return NULL;
//}

@end
