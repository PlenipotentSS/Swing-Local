//
//  CalendarviewController.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "CalendarviewController.h"
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


@interface CalendarviewController () <DateRangeSelectorDelegate, EventsTableViewModelDelegate>

//table view of events
@property (weak, nonatomic) IBOutlet EventsTableView *theTableView;

//date range control
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSelectRangeControl;

//table view model
@property (nonatomic) EventsTableViewModel *contentModel;

//title for this controller's view
@property (nonatomic) IBOutlet UILabel *titleLabel;

//city map view
@property (nonatomic) IBOutlet MKMapView *mapView;

//date range view selector
@property (nonatomic) DateRangeSelectorView *dateSelectorView;

//shadow box for date selector
@property (nonatomic) UIView *shadowBoxBackground;

//detail view
@property (nonatomic) DetailView *detailView;

@property (nonatomic) NSOperationQueue *miscQueue;

//pinned address on map
@property (nonatomic) NSMutableArray *pinnedAddresses;

//refresh control
@property (nonatomic, retain) UIRefreshControl *refreshControl;

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
    _miscQueue = [NSOperationQueue new];
    
    self.contentModel = [[EventsTableViewModel alloc] init];
    self.theTableView.delegate = self.contentModel;
    self.theTableView.dataSource = self.contentModel;
    [self.contentModel setTheTableView:self.theTableView];
    [self.contentModel setDelegate:self];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor offWhiteScheme];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.theTableView addSubview:self.refreshControl];
    
    if (!self.cities) {
        self.cities = [NSArray arrayWithArray:[[EventManager sharedManager] savedCities]];
        [self updatePageViews];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControllerWithOccurrence:) name:@"ShowDetailViewController" object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    }
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DateRangeSelector"
                                                      owner:self
                                                    options:nil];
    _dateSelectorView = [ nibViews objectAtIndex: 0];
    _shadowBoxBackground = [nibViews objectAtIndex: 1];
    self.pinnedAddresses = [NSMutableArray new];
    [self.dateSelectorView setShadowBoxBackground:self.shadowBoxBackground];
    [self.dateSelectorView setup];
    
    NSArray* detailNib = [[NSBundle mainBundle] loadNibNamed:@"DetailView"
                                                       owner:self
                                                     options:nil];
    _detailView = [ detailNib objectAtIndex: 0];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.cities = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Refresh Control methods
-(void) refreshTable {
    [self updatePageViews];
}

-(void)doneSearching {
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - updating data and UI

-(void) updatePageViews
{
    self.titleLabel.text = @"Your Saved Cities";
    
//    NSMutableArray *mapPins = [NSMutableArray new];
//    
//    __block NSInteger counter = 1;
//    for (City *thisCity in self.cities) {
//        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
//        [geoCoder geocodeAddressString:thisCity.cityName completionHandler:^(NSArray *placemarks, NSError *error) {
//            if (!error) {
//                CLPlacemark *locationPlacemark = [placemarks lastObject];
//                CLLocationCoordinate2D cityLocation = CLLocationCoordinate2DMake(locationPlacemark.location.coordinate.latitude,locationPlacemark.location.coordinate.longitude);
//                CityAnnotation *cityAnnotation = [[CityAnnotation alloc] init] ;
//                cityAnnotation.title = thisCity.cityName;
//                cityAnnotation.coordinate = cityLocation;
//                [mapPins addObject:cityAnnotation];
//                
//                if (counter == [self.cities count] ) {
//                    [self.mapView addAnnotations:mapPins];
//                    [self.mapView showAnnotations:mapPins animated:YES];
//                }
//                counter++;
//            }
//        }];
//    }
//    
    [self.contentModel setCities:self.cities];
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
                [self.mapView showAnnotations:self.mapView.annotations animated:NO];
            }
        } else {
            NSLog(@"error: %@ at: %@",error,thisOccurrence.address);
        }
    }];
}

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
    
    [self.contentModel setCities:self.cities];
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
    [self.miscQueue addOperationWithBlock:^{
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
            [self.contentModel setCities:self.cities];
            self.dateSelectRangeControl.selectedSegmentIndex = -1;
        }];
    }];
    
}

@end
