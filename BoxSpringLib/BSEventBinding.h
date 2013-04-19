//
//  BSEventBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-16.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"

@interface BSEventBinding : BSBinding {
    NSMutableDictionary* listeners;
    NSMutableDictionary* callbacks;
}

- (void)setEventCallback:(NSString*)event callback:(JSObjectRef)jsCallback;
- (void)getEventCallback:(NSString*)event;
- (void)triggerEvent:(NSString*)event argc:(size_t)argc argv:(const JSValueRef[])argv;

@end
