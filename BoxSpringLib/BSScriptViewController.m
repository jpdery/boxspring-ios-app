//
//  BSScriptViewController.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSScriptViewController.h"

@interface BSScriptViewController ()

@end

@implementation BSScriptViewController

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
	
	BSScriptView *view = [[BSScriptView alloc] initWithFrame:frame];
	self.view = view;
	[view loadScript:@"main.js"];
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
