//
//  SSBackViewController.m
//  Swing Local
//
//  Created by Stevenson on 2/1/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSBackViewController.h"
#import "UIColor+SwingLocal.h"
#import "SplitViewController.h"
#import "MenuTableViewModel.h"
#import "SavedEventsTableViewModel.h"

@interface SSBackViewController ()

@property (weak,nonatomic) IBOutlet UITableView *tableViewMenu;
@property (weak,nonatomic) IBOutlet UITableView *tableViewSavedEvents;

@property (weak,nonatomic) IBOutlet MenuTableViewModel *menuModel;
@property (weak, nonatomic) IBOutlet SavedEventsTableViewModel *savedEventsModel;

@end

@implementation SSBackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupTableViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setup configurations
- (void)configureView
{
    // Update the user interface for the detail item.
    self.view.backgroundColor = [UIColor aquaScheme];
}

-(void) setupTableViews {
    [_menuModel setTheTableView:_tableViewMenu];
    [_savedEventsModel setTheTableView:_tableViewSavedEvents];
}

#pragma mark - edit events
-(IBAction)editSavedEvents:(id)sender {
    if ( [[(UIButton*)sender titleLabel].text isEqualToString:@"Edit"]) {
        [(SplitViewController*)self.parentViewController.parentViewController showMenuFullScreen];
        [(UIButton*)sender setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        [(SplitViewController*)self.parentViewController.parentViewController showMenuSplit];
        [(UIButton*)sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

@end
