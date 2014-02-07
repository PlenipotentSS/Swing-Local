//
//  CalendarviewController.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "CalendarviewController.h"
#import "EventsTableViewModel.h"
#import "EventManager.h"

@interface CalendarviewController ()

//table view of events
@property (weak, nonatomic) IBOutlet EventsTableView *theTableView;

//date range control
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSelectRangeControl;

//table view model
@property (nonatomic) EventsTableViewModel *contentModel;

@end

@implementation CalendarviewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEvents) name:@"SavedCitiesUpdated" object:nil];
    
    [_dateSelectRangeControl addTarget:self action:@selector(createDateRange) forControlEvents:UIControlEventValueChanged];
    self.dateSelectRangeControl.selectedSegmentIndex = 0;
    
    self.contentModel = [[EventsTableViewModel alloc] init];
    self.theTableView.delegate = self.contentModel;
    self.theTableView.dataSource = self.contentModel;
    [self.contentModel setTheTableView:self.theTableView];
    
    if (!self.cities) {
        for (City *thisCity in [[EventManager sharedManager] savedCities]) {
            [[EventManager sharedManager] downloadVenuesAndEventsInCity:thisCity];
        }
        //[self getAllEventsInCity];
    }
    
}

-(void) updateEvents {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sgemented Control receievers
-(void) createDateRange {
    
}


#pragma mark - UITableView Datasource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [self.theTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}


@end
