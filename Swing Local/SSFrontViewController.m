//
//  SSFrontViewController.m
//  Swing Local
//
//  Created by Stevenson on 2/1/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSFrontViewController.h"
#import "HomeView.h"
#import "NewsView.h"

@interface SSFrontViewController ()

@end

@implementation SSFrontViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIViewController *home_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home_vc"];
    UIViewController *news_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"news_vc"];
    [(HomeView*)home_vc.view setNewsView:(NewsView*)news_vc.view];
    
    [self.mainView setAlpha:0.f];
    [self.mainView setup];
    [self.mainView setCurrentView:home_vc.view];
    [self.mainView setAlpha:1.f];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
