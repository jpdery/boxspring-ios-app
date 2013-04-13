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
@synthesize contextBinding;


- (id)initWithFrame:(CGRect)frame andViewBinding:(BSViewBinding*)theViewBinding
{
    if (self = [self initWithFrame:frame]) {
        viewBinding = [theViewBinding retain];
        contextBinding = [[BSContextBinding alloc] initWithScriptView:theViewBinding.scriptView]; // One per everything ?
    }
    
    return self;
}

- (void)dealloc
{
    [contextBinding release];
    [viewBinding release];
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    JSObjectRef jsRectConstructor = [[self.viewBinding.scriptView.primeConstructors objectForKey:@"boxspring.Rect"] jsObject];
    
    JSValueRef argv[4];
    argv[0] = JSValueMakeNumber(self.viewBinding.jsContext, rect.origin.x);
    argv[1] = JSValueMakeNumber(self.viewBinding.jsContext, rect.origin.y);
    argv[2] = JSValueMakeNumber(self.viewBinding.jsContext, rect.size.width);
    argv[3] = JSValueMakeNumber(self.viewBinding.jsContext, rect.size.height);

    JSObjectRef jsRect = JSObjectCallAsConstructor(self.viewBinding.jsContext, jsRectConstructor, 4, argv, NULL);
    
    contextBinding.context = UIGraphicsGetCurrentContext();

    JSValueRef drawArgv[2];
    drawArgv[0] = contextBinding.jsBoundObject;
    drawArgv[1] = jsRect;

    [self.viewBinding call:@"draw" argc:2 argv:drawArgv ofObject:self.viewBinding.jsParentObject ? self.viewBinding.jsParentObject : self.viewBinding.jsBoundObject];

}


@end
