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
#import "AddCityTableViewCell.h"
#import "City.h"


@interface SSBackViewController () <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak,nonatomic) IBOutlet UITableView *theTableView;

@property (nonatomic) NSArray *menuItems;
@property (nonatomic) NSArray *segueItems;
@property (nonatomic) BOOL edittingCells;

@property (weak,nonatomic) NSArray *allCities;
@property (weak,nonatomic) NSMutableArray *savedCities;

@property (weak,nonatomic) UIPickerView *addPickerView;

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
    [self loadAllCities];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSavedCities) name:@"SavedCitiesUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAllCities) name:@"AllCitiesUpdated" object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.addPickerView selectedRowInComponent:0] == 0){
        [self.addPickerView selectRow:1 inComponent:0 animated:YES];
    }
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
    
    _menuItems = @[@"homeCell",@"newsCell",@"calendarCell",@"supportCell"];
    _segueItems = @[@"showHome",@"showNews",@"showCalendar",@"showSupport"];
    
    [self reloadSavedCities];
}

-(void) reloadSavedCities
{
    _savedCities = [[EventManager sharedManager] savedCities];
    [self.theTableView reloadData];
    
    if ([self.addPickerView selectedRowInComponent:0] == 0){
        [self.addPickerView selectRow:1 inComponent:0 animated:YES];
    }
}

-(void) loadAllCities
{
    _allCities = [[EventManager sharedManager] allCities];
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
    } else if (self.theTableView.editing && indexPath.row == [_menuItems count]+1){
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            return 80.f;
        } else {
            return 150.f;
        }
    } else if (indexPath.row < [_menuItems count]){
        return 35.f;
    } else {
        return 50.f;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger total =[self.menuItems count] + 1 + [_savedCities count];
    if (self.theTableView.editing){
        total++;
    }
    return total;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.row < [_menuItems count]) {
        cell = [_theTableView dequeueReusableCellWithIdentifier:[_menuItems objectAtIndex:indexPath.row] forIndexPath:indexPath];
        
    } else if (indexPath.row == [_menuItems count]) {
        cell = [_theTableView dequeueReusableCellWithIdentifier:@"savedCityLabelCell" forIndexPath:indexPath];
    } else if (self.theTableView.editing && indexPath.row == [_menuItems count]+1) {
        //add extra row
        cell = [_theTableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
        [[(AddCityTableViewCell*)cell addButton] addTarget:self action:@selector(addSavedCity) forControlEvents:UIControlEventTouchUpInside];
        [(AddCityTableViewCell*)cell thepickerView].delegate = self;
        [(AddCityTableViewCell*)cell thepickerView].dataSource = self;
        self.addPickerView = [(AddCityTableViewCell*)cell thepickerView];
        return cell;
    } else {
        cell = [_theTableView dequeueReusableCellWithIdentifier:@"savedCityCell" forIndexPath:indexPath];
        NSInteger savedIndex = indexPath.row-[_menuItems count]-1;
        if (_theTableView.editing) {
            savedIndex--;
        }
        cell.textLabel.text = [(City*)[_savedCities objectAtIndex:savedIndex] cityName];
    }
    cell.contentView.backgroundColor = self.view.backgroundColor;
    return cell;
}

#pragma mark editing uitableview datasource and delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == [_menuItems count]+1) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_edittingCells && indexPath.row > [_menuItems count]+1) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_edittingCells && indexPath.row > [_menuItems count]+1 ) {
        return YES;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger savedIndex = indexPath.row-[_menuItems count]-2;
        [[[EventManager sharedManager] savedCities] removeObjectAtIndex:savedIndex];
        [[EventManager sharedManager] persistAndNotifySavedCities];
        [self reloadSavedCities];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView endUpdates];
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSInteger savedStartIndex = [_menuItems count]+2;
    NSInteger fromIndex = sourceIndexPath.row-savedStartIndex;
    NSInteger toIndex = destinationIndexPath.row-savedStartIndex;
    
    City *fromCity = [_savedCities objectAtIndex:fromIndex];
    [_savedCities removeObjectAtIndex:fromIndex];
    [_savedCities insertObject:fromCity atIndex:toIndex];
    [EventManager sharedManager].savedCities = _savedCities;
    [[EventManager sharedManager] persistAndNotifySavedCities];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row < [_menuItems count]+2) {
        return [NSIndexPath indexPathForRow:[_menuItems count]+2 inSection:0];
    }
    return proposedDestinationIndexPath;
}

#pragma mark - edit events
-(IBAction)editSavedEvents:(id)sender
{
    if ( [[(UIButton*)sender titleLabel].text isEqualToString:@"Edit"]) {
        _edittingCells = YES;
        [self.theTableView setEditing:YES animated:YES];
        [self.theTableView reloadData];
        [(SplitViewController*)self.parentViewController.parentViewController showMenuFullScreen];
        [(UIButton*)sender setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        _edittingCells = NO;
        [self.theTableView setEditing:NO animated:YES];
        [self.theTableView reloadData];
        [(SplitViewController*)self.parentViewController.parentViewController showMenuSplit];
        [(UIButton*)sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

-(void)addSavedCity{
    NSInteger pickerSelected = [_addPickerView selectedRowInComponent:0];
    City *thisCitySelected = [self.allCities objectAtIndex:pickerSelected];
    [[EventManager sharedManager].savedCities addObject:thisCitySelected];
    [[EventManager sharedManager] persistAndNotifySavedCities];
    [self reloadSavedCities];
    [self.theTableView reloadData];
}

#pragma mark - UIPickerView Delegate & Data Source methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_allCities count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 250;
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = nil;
    if (!view) {
        CGRect thisFrame = pickerView.frame;
        thisFrame.origin.x = 0.f;
        thisFrame.origin.x = 0.f;
        view = [[UIView alloc] initWithFrame:CGRectMake(0.f,0.f,300.f,50.f)];
        UILabel  *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f,0.f,300.f,50.f)];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.text = [(City*)[_allCities objectAtIndex:row] cityName];
        //NSLog(@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            pickerLabel.textColor = [UIColor offWhiteScheme];
        } else {
            //NSLog(@"picker color is black for iOS 6");
            pickerLabel.textColor = [UIColor blackColor];
        }
        [view addSubview:pickerLabel];
    }
    if (!pickerLabel) {
        
    }
    return view;
}



@end
