//
//  BSCoreImageBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-04-13.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSEventBinding.h"

@interface BSCoreImageBinding : BSEventBinding {
    JSValueRef jsSrc;
}

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, assign) BOOL loaded;

@end
