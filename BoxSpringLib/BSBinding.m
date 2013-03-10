//
//  BSBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"
#import "BSScriptView.h"

@implementation BSBinding

@synthesize scriptView;

- (id)initWithScriptView:(BSScriptView *)theScriptView
{
    self = [super init];
    if (self) {
        scriptView = [theScriptView retain];
    }
    return self;
}

- (void)dealloc
{
    [scriptView release];
    [super dealloc];
}

@end
