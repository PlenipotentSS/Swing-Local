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
#import "DateRangeSelectorView.h"
#import "NSDate+SwingLocal.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OccAnnotation.h"
#import "M13ProgressViewStripedBar.h"
#import "UIColor+SwingLocal.h"

@interface SingleCityViewController () <DateRangeSelectorDelegate, EventsTableViewModelDelegate>

//progress view
@property (nonatomic, retain) IBOutlet M13ProgressViewStripedBar *progressView;

//content ScrollView
@property (weak,nonatomic) IBOutlet EventsTableView *theTableView;

//table view model
@property (nonatomic) EventsTableViewModel *contentModel;

//title for this controller's view
@property (nonatomic) IBOutlet UILabel *titleLabel;

//city map view
@property (nonatomic) IBOutlet MKMapView *mapView;

//segmented control to select date ranges
@property (nonatomic) IBOutlet UISegmentedControl *dateSelector;

//date range view selector
@property (nonatomic) DateRangeSelectorView *dateSelectorView;

//shadow box for date selector
@property (nonatomic) UIView *shadowBoxBackground;

//detail view
@property (nonatomic) DetailView *detailView;

//addresses pinned on map
@property (nonatomic) NSMutableArray *pinnedAddresses;

//refresh control
@property (nonatomic, retain) UIRefreshControl *refreshControl;

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
    
    [self resetProgress];
    self.progressView.hidden = YES;
    [self.progressView setSecondaryColor:[UIColor clearColor]];
    
    self.contentModel = [[EventsTableViewModel alloc] init];
    self.theTableView.delegate = self.contentModel;
    self.theTableView.dataSource = self.contentModel;
    [self.contentModel setTheTableView:self.theTableView];
    [self.contentModel setDelegate:self];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor offWhiteScheme];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.theTableView addSubview:self.refreshControl];
    
    if (!self.theCity) {
        self.theCity = [[EventManager sharedManager] currentCity];
        [self updatePageViews];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControllerWithOccurrence:) name:@"ShowDetailViewController" object:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DateRangeSelector"
                                                      owner:self
                                                    options:nil];
    _dateSelectorView = [ nibViews objectAtIndex: 0];
    _shadowBoxBackground = [nibViews objectAtIndex: 1];
    _pinnedAddresses = [NSMutableArray new];
    [self.dateSelectorView setShadowBoxBackground:self.shadowBoxBackground];
    [self.dateSelectorView setup];
    
    NSArray* detailNib = [[NSBundle mainBundle] loadNibNamed:@"DetailView"
                                                       owner:self
                                                     options:nil];
    _detailView = [ detailNib objectAtIndex: 0];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Refresh Control and progress methods
-(void) refreshTable {
    self.contentModel.city = nil;
    [self.theTableView reloadData];
    [self updatePageViews];
}

-(void)doneSearching {
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

-(void) updateProgress:(CGFloat)progress
{
    if (self.progressView.hidden) {
        self.progressView.hidden = NO;
    }
    if (progress >= 1.f) {
        [self.progressView setProgress:1.f animated:YES];
        [UIView animateWithDuration:.4f delay:0.f options:kNilOptions animations:^{
            [self.progressView setAlpha:0.f];
        } completion:^(BOOL finished) {
            self.progressView.hidden = YES;
            [self.progressView setAlpha:1.f];
        }];
    } else if (progress > self.progressView.progress) {
        [self.progressView setProgress:progress animated:YES];
    }
}
-(void) resetProgress
{
    [self.progressView setProgress:1.f animated:NO];
    [self.progressView setProgress:0.05f animated:NO];
    self.progressView.hidden = NO;
}

#pragma mark - updating data and UI
-(void) updatePageViews
{
    [self resetProgress];
    self.titleLabel.text = [self.theCity cityName];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:self.theCity.cityName completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *locationPlacemark = [placemarks lastObject];
            CLLocationCoordinate2D cityLocation = CLLocationCoordinate2DMake(locationPlacemark.location.coordinate.latitude,locationPlacemark.location.coordinate.longitude);
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(cityLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
            
            [self.mapView setRegion:viewRegion animated:YES];
        }
    }];
    [self.contentModel setCity:self.theCity];
}

-(void) updateMapPinForOccurrence:(Occurrence *)thisOccurrence
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:thisOccurrence.address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *locationPlacemark = [placemarks lastObject];
            CLLocationCoordinate2D cityLocation = CLLocationCoordinate2DMake(locationPlacemark.location.coordinate.latitude,locationPlacemark.location.coordinate.longitude);
            OccAnnotation *occAnnotation = [[OccAnnotation alloc] init];
            occAnnotation.title = thisOccurrence.updatedTitle;
            occAnnotation.coordinate = cityLocation;
            if (![self.pinnedAddresses containsObject:thisOccurrence.address]) {
                [self.mapView addAnnotation:occAnnotation];
                [self.pinnedAddresses addObject:thisOccurrence.address];
            }
        } else {
            NSLog(@"error: %@ at: %@",error,thisOccurrence.address);
        }
    }];
}


#pragma mark - imageviewcreator
-(NSURL*) getImageFromCityName: (NSString*) cityName
{
    cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=10&size=460x230&maptype=roadmap&sensor=false",cityName];
    return [NSURL URLWithString:strURL];
}

//#pragma mark - HomePageManagerDelegate methods
//-(void) updateViewWithImage:(UIImage*) theImage
//{
//    if (theImage ) {
//        [self.cityHeaderImage setAlpha:0.f];
//        [self.cityHeaderImage setImage:theImage];
//        [UIView animateWithDuration:.4f animations:^{
//            [self.cityHeaderImage setAlpha:1.f];
//        }];
//    }
//}

#pragma mark - present detail view controller for occurrence!
-(void) showControllerWithOccurrence: (NSNotification*) notification
{
    self.detailView.thisOccurrence = (Occurrence*)[[notification userInfo] objectForKey:@"occurrence"];
    [self.detailView setAlpha:0.f];
    if ([UIView instancesRespondToSelector:@selector(setTintColor:)]) {
        [self.detailView setTintColor:[UIColor offWhiteScheme]];
    }
    
    [self.view addSubview:self.detailView];
    [UIView animateWithDuration:.4f animations:^{
        [self.detailView setAlpha:1.f];
    }];
}

#pragma mark - action to change date
- (IBAction)dateControlChanged:(id)sender
{
    
    [self resetProgress];
    [self.pinnedAddresses removeAllObjects];
    [self.mapView removeAnnotations:self.mapView.annotations];
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
        [self showDateRangeSelector];
    }
    
    [self.contentModel setCity:self.theCity];
}

#pragma mark - present date range view
-(void) showDateRangeSelector
{
    [self.dateSelectorView setAlpha:0.f];
    [self.shadowBoxBackground setAlpha:0.f];
    [self.dateSelectorView setDelegate:self];
    self.dateSelectorView.center = self.view.center;
    
    [self.view addSubview:self.shadowBoxBackground];
    [self.view addSubview:self.dateSelectorView];
    [UIView animateWithDuration:.4f animations:^{
        [self.dateSelectorView setAlpha:1.f];
        [self.shadowBoxBackground setAlpha:1.f];
    }];
}

#pragma mark - DateRangeSelector Delegate methods
-(void) updateTableViewWithBeginDateDate:(NSDate*) startDate toEndDate: (NSDate*) endDate {
    NSOperationQueue *dateSearchQueue = [NSOperationQueue new];
    [dateSearchQueue addOperationWithBlock:^{
        NSMutableArray *mutableDates = [NSMutableArray new];
        
        int counter = 0;
        
        NSDate *nextDate;
        do {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:counter];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            nextDate = [gregorian dateByAddingComponents:components toDate:startDate options:0];
            
            counter++;
            
            [mutableDates addObject:nextDate];
            if ( [NSDate dateA:nextDate isSameDayAsDateB:endDate]) {
                break;
            }
        } while ( [NSDate dateA:nextDate isBeforeDateB:endDate] );
        
        NSArray *searchDates = [NSArray arrayWithArray:mutableDates];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.contentModel setDatesToSearch:searchDates];
            [self.contentModel setCity:self.theCity];
            self.dateSelector.selectedSegmentIndex = -1;
        }];
    }];

}




@end
