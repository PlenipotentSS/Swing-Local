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

@interface SingleCityViewController () <HomePageManagerDelegate>


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
    
    self.contentModel = [[EventsTableViewModel alloc] init];
    self.theTableView.delegate = self.contentModel;
    self.theTableView.dataSource = self.contentModel;
    [self.contentModel setTheTableView:self.theTableView];
    self.allEvents = [NSMutableArray new];
    
    if (!self.theCity) {
        self.theCity = [[EventManager sharedManager] currentCity];
        [self getAllEventsInCity];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - updating data and UI
-(void)getAllEventsInCity {
    if (self.theCity) {
        NSMutableArray *venues = [self.theCity venueOrganizations];
        for (Venue *thisVenue in venues) {
            //change to get events on day
            [self.allEvents addObjectsFromArray:[thisVenue events]];
        }
    }
    [self updatePageViews];
    [self.theTableView reloadData];
}

-(void) updatePageViews {
    self.titleLabel.text = [self.theCity cityName];
    if (self.theCity.cityImage) {
        [self updateViewWithImage:self.theCity.cityImage];
    } else {
        [[HomePageManager sharedManager] setDelegate:self];
        NSURL *headerImageURL = [self getImageFromCityName:self.theCity.cityName];
        [[HomePageManager sharedManager] downloadImageFromURL:headerImageURL forCity:self.theCity];
    }
    [self.contentModel setCity:self.theCity];
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

@end
