//
//  BSCoreImageBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-13.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSCoreImageBinding.h"

@implementation BSCoreImageBinding

BS_DEFINE_BOUND_SETTER(src, setSrc)
BS_DEFINE_BOUND_GETTER(src, getSrc);

- (void)setSrc:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsSrc = jsValue;

    NSString* source = [NSString stringWithFormat:@"%@/App/%@", [[NSBundle mainBundle] resourcePath], JSValueToNSString(jsContext, jsValue)];

    NSLog(@"path %@", source);

    if (self.image) {
        [self.image release];
    }

    self.loaded = NO;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [UIImage imageWithContentsOfFile:source];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
            self.loaded = YES;
            [self triggerEvent:@"load" argc:0 argv:NULL];
        });
    });
}

- (JSValueRef)getSrc:(JSContextRef)jsContext
{
    return jsSrc;
}



@end
