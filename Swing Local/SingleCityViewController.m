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
#import "Occurrence.h"

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

//segmented control to select date ranges
@property (nonatomic) IBOutlet UISegmentedControl *dateSelector;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControllerWithOccurrence:) name:@"ShowDetailViewController" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - updating data and UI
-(void)getAllEventsInCity
{
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

-(void) updatePageViews
{
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
-(NSURL*) getImageFromCityName: (NSString*) cityName
{
    cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=10&size=460x230&maptype=roadmap&sensor=false",cityName];
    return [NSURL URLWithString:strURL];
}

#pragma mark - HomePageManagerDelegate methods
-(void) updateViewWithImage:(UIImage*) theImage
{
    [self.cityHeaderImage setAlpha:0.f];
    [self.cityHeaderImage setImage:theImage];
    [UIView animateWithDuration:.4f animations:^{
        [self.cityHeaderImage setAlpha:1.f];
    }];
}

#pragma mark - present detail view controller for occurrence!
-(void) showControllerWithOccurrence: (NSNotification*) notification
{
    UIViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail_vc"];
    DetailView *detailView = (DetailView*)detailVC.view;
    detailView.thisOccurrence = (Occurrence*)[[notification userInfo] objectForKey:@"occurrence"];
    [detailView setDynamic:YES];
    [detailView setAlpha:0.f];
    [detailView setTintColor:[UIColor offWhiteScheme]];
    [detailView setBlurRadius:85.f];
    
    [self.view addSubview:detailView];
    [UIView animateWithDuration:.4f animations:^{
        [detailView setAlpha:1.f];
    }];
}

#pragma mark - action to change date
- (IBAction)dateControlChanged:(id)sender
{
    UISegmentedControl *control =(UISegmentedControl*)sender;
    if (control.selectedSegmentIndex == 0) {
        [self.contentModel setDatesToSearch:[NSArray new]];
    } else if (control.selectedSegmentIndex == 1){
        NSMutableArray *mutableDates = [NSMutableArray new];
        
        NSDate *now = [NSDate date];
        for (int i=0; i <= 7 ;i++ ) {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:i];
            
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            
            NSDate *newDate2 = [gregorian dateByAddingComponents:components toDate:now options:0];
            [mutableDates addObject:newDate2];
        }
        
        [self.contentModel setDatesToSearch:[NSArray arrayWithArray:mutableDates]];
    } else if (control.selectedSegmentIndex == 2 ) {
        //load hub to select beginning date and end date!
        [self.contentModel setDatesToSearch:[NSArray new]];
    }
    
    [self.contentModel setCity:self.theCity];
}


@end
