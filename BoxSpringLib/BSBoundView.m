//
//  BSViewBindingView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-13.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSContextBinding.h"
#import "BSViewBinding.h"
#import "BSBoundView.h"

@implementation BSBoundView

@synthesize binding;

- (id)initWithFrame:(CGRect)frame binding:(BSViewBinding*)theBinding
{
    if (self = [self initWithFrame:frame]) {
        binding = [theBinding retain];
    }
    return self;
}

- (void)dealloc
{
    [binding release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [self.binding viewDidDraw:self inRect:rect];
}

@end
