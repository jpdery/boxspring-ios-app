//
//  BGView.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-20.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSViewBinding;
@class BSContextBinding;

@interface BSView : UIView

@property (nonatomic, readonly) BSViewBinding* binding;
@property (nonatomic, readonly) BSContextBinding* context;

- (id)initWithFrame:(CGRect)frame andBinding:(BSViewBinding*)binding;

@end
