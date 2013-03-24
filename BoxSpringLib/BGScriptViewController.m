//
//  BSScriptViewController.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BGScriptViewController.h"

@interface BGScriptViewController ()

@end

@implementation BGScriptViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	CGRect frame = UIScreen.mainScreen.bounds;
//	if (landscapeMode) {
//		frame.size = CGSizeMake(frame.size.height, frame.size.width);
//	}
	
	BGScriptView *view = [[BGScriptView alloc] initWithFrame:frame];
	self.view = view;
    
    [view loadScript:@"init.js"];
	[view loadScript:@"main.js"];
    [view loadScript:@"app.js"];
	[view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
