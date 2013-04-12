//
//  BGView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-20.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSView.h"
#import "BSViewBinding.h"
#import "BSContextBinding.h"

@implementation BSView

@synthesize binding;
@synthesize context;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andBinding:(BSViewBinding*)theBinding
{
    if (self = [self initWithFrame:frame]) {
        binding = theBinding;

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

 
}

@end
