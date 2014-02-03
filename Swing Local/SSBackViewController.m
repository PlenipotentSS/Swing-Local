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
#import "SplitControllerSegue.h"


@interface SSBackViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) IBOutlet UITableView *theTableView;

@property (nonatomic) NSArray *menuItems;
@property (nonatomic) NSArray *segueItems;

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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    _theTableView.dataSource = self;
    _theTableView.delegate = self;
    
    _menuItems = @[@"newsCell",@"homeCell",@"calendarCell",@"settingsCell",@"supportCell"];
    _segueItems = @[@"showNews",@"showHome",@"showCalendar",@"showSettings",@"showSupport"];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.frontViewController performSegueWithIdentifier:[_segueItems objectAtIndex:indexPath.row] sender:self];
    [_theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItems count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_theTableView dequeueReusableCellWithIdentifier:[_menuItems objectAtIndex:indexPath.row] forIndexPath:indexPath];
    
    return cell;
}

@end
