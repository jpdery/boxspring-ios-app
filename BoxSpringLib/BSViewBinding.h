//
//  BSViewBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-18.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"

@class BSBoundView;

@interface BSViewBinding : BSBinding

@property (nonatomic, retain) BSBoundView* view;

- (void)loadViewWithRect:(CGRect)rect;

@end
