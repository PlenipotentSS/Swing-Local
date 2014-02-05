//
//  SingleCityViewController.m
//  Swing Local
//
//  Created by Stevenson on 2/4/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SingleCityViewController.h"
#import "EventsTableView.h"
#import "EventsTableViewModel.h"
#import "EventManager.h"
#import "HomePageManager.h"
#import "UIColor+SwingLocal.h"

@interface SingleCityViewController () <UITableViewDataSource,UITableViewDelegate, HomePageManagerDelegate>


//content ScrollView
@property (weak,nonatomic) IBOutlet EventsTableView *theTableView;

//array of all cities
@property (nonatomic) NSMutableArray *allEvents;

//table view model
@property (nonatomic) EventsTableViewModel *contentModel;

//title for this controller's view
@property (nonatomic) IBOutlet UILabel *titleLabel;

//image for this city
@property (nonatomic) IBOutlet UIImageView *cityHeaderImage;

@end

@implementation SingleCityViewController

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
    
    _theTableView.delegate = self;
    _theTableView.dataSource = self;
    _allEvents = [NSMutableArray new];
    
    if (!_theCity) {
        _theCity = [[EventManager sharedManager] topCity];
        [self getAllEventsInCity];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setTheCity:(City *)theCity {
    _theCity = theCity;
    
    [self getAllEventsInCity];
    [self.theTableView reloadData];
}

#pragma mark - updating data and UI
-(void)getAllEventsInCity {
    if (_theCity) {
        NSMutableArray *venues = [_theCity venueOrganizations];
        for (Venue *thisVenue in venues) {
            //change to get events on day
            [_allEvents addObjectsFromArray:[thisVenue events]];
        }
    }
    [self updatePageViews];
    [self.theTableView reloadData];
}

-(void) updatePageViews {
    _titleLabel.text = [_theCity cityName];
    [[HomePageManager sharedManager] setDelegate:self];
    NSURL *headerImageURL = [self getImageFromCityName:_theCity.cityName];
    [[HomePageManager sharedManager] downloadImageFromURL:headerImageURL forCity:_theCity];
    
}

#pragma mark - imageviewcreator
-(NSURL*) getImageFromCityName: (NSString*) cityName {
    cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=10&size=460x230&maptype=roadmap&sensor=false",cityName];
    return [NSURL URLWithString:strURL];
}

#pragma mark - HomePageManagerDelegate methods
-(void) updateViewWithImage:(UIImage*) theImage {
    [self.cityHeaderImage setAlpha:0.f];
    [self.cityHeaderImage setImage:theImage];
    [UIView animateWithDuration:.4f animations:^{
        [self.cityHeaderImage setAlpha:1.f];
    }];
}

#pragma mark - UITableView data source methods
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allEvents count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [_theTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Event *thisEvent = [_allEvents objectAtIndex:indexPath.row];
    cell.textLabel.text = thisEvent.eventTitle;
    cell.textLabel.textColor = [UIColor offWhiteScheme];
    return cell;
}

@end
