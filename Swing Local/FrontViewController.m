//
//  FrontViewController.m
//  SplitPeekViewController
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "FrontViewController.h"
#import "SplitViewController.h"

@interface FrontViewController ()

@property (nonatomic) IBOutlet UIButton *menu_burger;

@end

@implementation FrontViewController

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
    
}

-(IBAction)menuButtonPushed:(id)sender {
    SplitViewController *splitController = (SplitViewController*)self.parentViewController.parentViewController;
    if (splitController.menuStateInView == MenuCompletelyHidden){
        [splitController showMenuSplit];
    } else {
        [splitController hideMenu];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end