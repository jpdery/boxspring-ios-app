//
//  BSViewBindingView.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-13.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSViewBinding;
@class BSContextBinding;

@interface BSBoundView : UIView

@property(nonatomic, readonly) BSViewBinding* viewBinding;
@property(nonatomic, readonly) BSContextBinding* contextBinding;

- (id)initWithFrame:(CGRect)frame andViewBinding:(BSViewBinding*)theViewBinding;

@end
