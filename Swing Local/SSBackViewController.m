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
#import "EventManager.h"


@interface SSBackViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) IBOutlet UITableView *theTableView;

@property (nonatomic) NSArray *menuItems;
@property (nonatomic) NSArray *segueItems;
@property (nonatomic) BOOL edittingCells;

@property (nonatomic) NSMutableArray *savedCities;

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
    [self configureData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSavedCities) name:@"SavedCitiesUpdated" object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setup configurations
-(void)configureData
{
    _theTableView.dataSource = self;
    _theTableView.delegate = self;
    
    _menuItems = @[@"homeCell",@"newsCell",@"calendarCell",@"settingsCell",@"supportCell"];
    _segueItems = @[@"showHome",@"showNews",@"showCalendar",@"showSettings",@"showSupport"];
    
    [self reloadSavedCities];
}

-(void) reloadSavedCities {
    _savedCities = [[EventManager sharedManager] savedCities];
    [self.theTableView reloadData];
}

#pragma mark - edit events
-(IBAction)editSavedEvents:(id)sender
{
    if ( [[(UIButton*)sender titleLabel].text isEqualToString:@"Edit"]) {
        _edittingCells = YES;
        [self.theTableView setEditing:YES animated:YES];
        [(SplitViewController*)self.parentViewController.parentViewController showMenuFullScreen];
        [(UIButton*)sender setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        _edittingCells = NO;
        [self.theTableView setEditing:NO animated:YES];
        [self.theTableView endUpdates];
        [(SplitViewController*)self.parentViewController.parentViewController showMenuSplit];
        [(UIButton*)sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

#pragma mark - UITableView delegate and datasource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_menuItems count]) {
        [self.frontViewController performSegueWithIdentifier:[_segueItems objectAtIndex:indexPath.row] sender:self];
    }
    if (indexPath.row > [_menuItems count]) {
        NSInteger savedIndex = indexPath.row-[_menuItems count]-1;
        [[EventManager sharedManager] setCurrentCity:[_savedCities objectAtIndex:savedIndex]];
        [self.frontViewController performSegueWithIdentifier:@"showSingleCity" sender:self];
    }
    
    //stay in menu if support is pushed
    //support needs to be last element in menu
    if (indexPath.row != [_menuItems count] && indexPath.row != [_menuItems count]-1) {
        [(SplitViewController*)self.parentViewController.parentViewController hideMenu];
    }
    
    [_theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_menuItems count]) {
        return 60.f;
    } else {
        return 35.f;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count] + 1 + [_savedCities count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell ;
    if (indexPath.row < [_menuItems count]) {
        cell = [_theTableView dequeueReusableCellWithIdentifier:[_menuItems objectAtIndex:indexPath.row] forIndexPath:indexPath];
        
    } else if (indexPath.row == [_menuItems count]) {
        cell = [_theTableView dequeueReusableCellWithIdentifier:@"savedCityLabelCell" forIndexPath:indexPath];
    } else {
        cell = [_theTableView dequeueReusableCellWithIdentifier:@"savedCityCell" forIndexPath:indexPath];
        NSInteger savedIndex = indexPath.row-[_menuItems count]-1;
        cell.textLabel.text = [(City*)[_savedCities objectAtIndex:savedIndex] cityName];
    }
    
    return cell;
}

#pragma mark editing uitableview datasource and delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_edittingCells && indexPath.row > [_menuItems count] ) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_edittingCells && indexPath.row > [_menuItems count] ) {
        return YES;
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row <= [_menuItems count]) {
        return [NSIndexPath indexPathForRow:[_menuItems count]+1 inSection:0];
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //set top city in event manager if tondexpath or fromindexpath is _mentuItems count+1
}

@end
