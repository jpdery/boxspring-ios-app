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

BS_DEFINE_FUNCTION(log, jsLog)
BS_DEFINE_FUNCTION(info, jsLog)
BS_DEFINE_FUNCTION(warn, jsLog)
BS_DEFINE_FUNCTION(debug, jsLog)
BS_DEFINE_FUNCTION(error, jsLog)

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
