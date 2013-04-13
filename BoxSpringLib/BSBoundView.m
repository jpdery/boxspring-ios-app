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

@synthesize viewBinding;

- (id)initWithFrame:(CGRect)frame andViewBinding:(BSViewBinding*)theViewBinding
{
    if (self = [self initWithFrame:frame]) {
        viewBinding = [theViewBinding retain];
    }
    
    return self;
}

- (void)dealloc
{
    [viewBinding release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [self.viewBinding viewDidDraw:self inRect:rect];
}


@end
