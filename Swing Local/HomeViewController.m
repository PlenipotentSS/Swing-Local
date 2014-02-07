//
//  HomeViewController.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeView.h"
#import "EventsTableViewModel.h"
#import "HollowButton.h"
#import "SSActionSheet.h"
#import "EventManager.h"
#import "SSFrontViewController.h"
#import "SplitViewController.h"
#import "DetailView.h"

@interface HomeViewController () <UIGestureRecognizerDelegate, HomePageManagerDelegate>

//the header image set under title
@property (weak, nonatomic) IBOutlet UIImageView *cityHeaderImage;

//content ScrollView
@property (weak,nonatomic) IBOutlet EventsTableView *contentTableView;

//flag for ongoing animation
@property (nonatomic) BOOL __block cityIsAnimating;

//main view for this controller
@property (weak, nonatomic) HomeView *homeView;

//array of all cities
@property (nonatomic) NSMutableArray *cityKeys;

//table view model
@property (nonatomic) EventsTableViewModel *contentModel;

//button for more dances
@property (weak, nonatomic) IBOutlet HollowButton *moreEvents;

//button for more dances
@property (weak, nonatomic) IBOutlet UIButton *moreEventsWrapper;

//footer view for any separate swipe gestures
@property (weak, nonatomic) IBOutlet UIView *footerView;

//action sheet to display cities
@property (nonatomic) SSActionSheet *cityActionSheet;

//whether there is a city that this user has selected in the past
@property (nonatomic) BOOL citySelected;

//current index selected in city array
@property (nonatomic) NSInteger currentCityIndex;

//initial home view
@property (weak,nonatomic) IBOutlet UIView *initialHomeView;

@end

@implementation HomeViewController

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
    [self setupContentTable];
    [self setupGesture];
    [self setupButtons];
    [self setupActionSheet];
    [self setupGeneral];
    [self loadCities];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCities) name:@"AllCitiesUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControllerWithOccurrence:) name:@"ShowDetailViewController" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadInitialCity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup methods
-(void) setupGeneral
{
    _homeView = (HomeView*)self.view;
    [_homeView setup];    
    self.homeView.footerView = self.footerView;
}

-(void) setupActionSheet
{
    _cityActionSheet = [[SSActionSheet alloc] init];
    _cityActionSheet.nAnimationType = DoTransitionStylePop;
    _cityActionSheet.dButtonRound = 2;
}


-(void) setupContentTable
{
    _contentTableView.contentSize = CGSizeMake(320.f, 1000.f);
    _contentTableView.userInteractionEnabled = YES;
    _contentTableView.scrollEnabled = YES;
    
    _contentModel = [[EventsTableViewModel alloc] init];
    _contentTableView.delegate = _contentModel;
    _contentTableView.dataSource = _contentModel;
    [_contentModel setTheTableView:_contentTableView];
}

-(void) setupButtons
{
    self.cityIsAnimating = NO;
    _currentCityIndex = -1;
    
    self.moreEvents.layer.cornerRadius = CGRectGetWidth(self.moreEvents.frame)/2;
    self.moreEvents.layer.masksToBounds = YES;
    //[self.moreEvents setColorOverlay:[UIColor burntScheme] withImage:[UIImage imageNamed:@"arrow_right"]];
    [self.moreEvents addTarget:self action:@selector(presentMoreEvents) forControlEvents:UIControlEventTouchUpInside];
    
    [self.moreEventsWrapper addTarget:self action:@selector(presentMoreEvents) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setupGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(footerSlide:)];
    
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    
    pan.delegate = self;
    [self.footerView addGestureRecognizer:pan];
}

#pragma mark - City management
-(void) loadInitialCity
{
    if ([[[EventManager sharedManager] savedCities] count] > 0) {
        self.initialHomeView.hidden = YES;
        self.citySelected = YES;
        [self hideCitySelectorAndShowActionSheet:NO];
        [self showChangeCitySelector];
        [self.homeView animateShowingContent];
        [self updateViewWithCity:[[[EventManager sharedManager] savedCities] objectAtIndex:0]];
        self.homeView.addCityToSavedCitiesButton.hidden = YES;
    } else {
        [self showInitialView];
    }
}

-(void) loadCities
{
    NSArray *allCities = [[EventManager sharedManager] allCities];
    _cityKeys = [NSMutableArray new];
    for (City *thisCity in allCities) {
        [_cityKeys addObject:thisCity.cityName];
    }
}

#pragma mark - IBActions to select city
-(IBAction)selectCity:(id)sender
{
    if (!self.cityIsAnimating) {
        [self hideCitySelectorAndShowActionSheet:YES];
    }
}

-(IBAction)changeCity:(id)sender
{
    if (!self.cityIsAnimating) {
        [self hideChangeCitySelectorAndShowActionSheet:YES];
    }
}

#pragma mark - IBAction to save City to saved cities
-(IBAction)saveCityToSavedCities:(id)sender
{
    self.homeView.addCityToSavedCitiesButton.hidden = YES;
    [[EventManager sharedManager].savedCities addObject:self.currentCity];
    [[EventManager sharedManager] persistAndNotifySavedCities];
    [(SplitViewController*)self.parentViewController.parentViewController showMenuSplit];
}

#pragma mark - Pan Gesture Selector
-(void) footerSlide:(id)sender
{
    if (!self.cityIsAnimating){
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
        if (self.citySelected) {
            [self moveButton:self.homeView.changeCityButton withGesture:pan];
        } else {
            [self moveButton:self.homeView.citySelectButton withGesture:pan];
        }
    }
    
}

-(void) moveButton:(UIButton*) button withGesture:(UIPanGestureRecognizer*) pan {
    CGPoint translation = [pan translationInView:self.homeView];
    CGPoint newPoint = button.center;
    if (pan.state ==UIGestureRecognizerStateChanged) {
        newPoint.y = button.center.y+translation.y;
        if (translation.y > 0) {
            button.center = newPoint;
            
            [pan setTranslation:CGPointMake(0, 0) inView:self.footerView];
        }
    }
    
    if (pan.state ==UIGestureRecognizerStateEnded) {
        if (button.center.y > 125) {
            if (self.currentCityIndex == -1) {
                [self hideCitySelectorAndShowActionSheet:YES];
            } else {
                [self hideChangeCitySelectorAndShowActionSheet:YES];
            }
        } else {
            self.cityIsAnimating = YES;
            [UIView animateWithDuration:.4f animations:^{
                button.center = self.homeView.changeCityOrigin;
            } completion:^(BOOL finished) {
                self.cityIsAnimating = NO;
            }];
        }
    }
}


#pragma mark - HomePageManagerDelegate methods
-(void) updateViewWithImage:(UIImage*) theImage {
    [self.cityHeaderImage setAlpha:0.f];
    [self.cityHeaderImage setImage:theImage];
    [UIView animateWithDuration:.4f animations:^{
        [self.cityHeaderImage setAlpha:1.f];
    }];
}

#pragma mark - update home with event
-(void) updateViewWithCityIndex:(NSInteger) index {
    if (index >= 0 && index < [_cityKeys count]) {
        if (!self.citySelected) {
            self.citySelected = YES;
        }
        NSArray *allCities = [[EventManager sharedManager] allCities];
        for (City *thisCity in allCities) {
            NSString *thisCityName = [_cityKeys objectAtIndex:index];
            if ([thisCityName isEqualToString:[thisCity cityName]]) {
                [self updateViewWithCity:thisCity];
                break;
            }
        }
    }
}

-(void) updateViewWithCity:(City*) thisCity {
    [self hideInitialView];
    self.currentCity = thisCity;
    self.currentCityIndex = [_cityKeys indexOfObject:thisCity];
    [self.homeView.title setText:thisCity.cityName];
    if (thisCity.cityImage) {
        [self.homeView animateShowingContent];
        [self updateViewWithImage:thisCity.cityImage];
    } else {
        [[HomePageManager sharedManager] setDelegate:self];
        NSURL *headerImageURL = [self getImageFromCity:thisCity];
        [[HomePageManager sharedManager] downloadImageFromURL:headerImageURL forCity:thisCity];
    }
    [_contentModel setCity:thisCity];
}

#pragma mark - image url configurations
-(NSURL*) getImageFromCityName: (NSString*) cityName {
    cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=10&size=460x230&maptype=roadmap&sensor=false",cityName];
    return [NSURL URLWithString:strURL];
}

-(NSURL*) getImageFromCity: (City*) theCity {
    NSString *cityName = [theCity.cityName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=10&size=460x230&maptype=roadmap&sensor=false",cityName];
    return [NSURL URLWithString:strURL];
}

#pragma mark - outlets
- (void)showInitialView
{
    self.initialHomeView.alpha = 0.f;
    self.initialHomeView.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.initialHomeView.alpha = 1.f;
    }];
}

- (void)hideInitialView
{
    [UIView animateWithDuration:.4f animations:^{
        self.initialHomeView.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.initialHomeView.hidden = YES;
    }];
}


-(void) presentMoreEvents {
    [(SSFrontViewController*)self.rootSegueController performSegueWithIdentifier:@"showCalendar" sender:self];
}

#pragma mark - animations for selectCity button
-(void) showCitySelector {
    self.homeView.citySelectButton.hidden = NO;
    __block CGRect changeCityNewFrame = self.homeView.citySelectButton.frame;
    changeCityNewFrame.origin.y = CGRectGetHeight(self.homeView.citySelectButton.superview.frame);
    self.homeView.citySelectButton.frame = changeCityNewFrame;
    
    
    self.cityIsAnimating = YES;
    [UIView animateWithDuration:.6f animations:^{
        changeCityNewFrame.origin.y = CGRectGetHeight(self.homeView.citySelectButton.superview.frame)-70;
        self.homeView.citySelectButton.frame = changeCityNewFrame;
    } completion:^(BOOL finished){
        self.cityIsAnimating = NO;
    }];
}

-(void) hideCitySelectorAndShowActionSheet:(BOOL) aShow {
    CGRect newFrame = self.homeView.citySelectButton.frame;
    newFrame.origin.y = CGRectGetHeight(self.footerView.frame);
    self.cityIsAnimating = YES;
    self.homeView.citySelectButton.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.homeView.citySelectButton.frame = newFrame;
    } completion:^(BOOL finished) {
        self.homeView.citySelectButton.hidden = YES;
        self.cityIsAnimating = NO;
        if (aShow) {
            [self showActionSheet];
        }
    }];
}

#pragma mark - Animation Methods
#pragma mark animations for changeCity button
-(void) showChangeCitySelector {
    self.cityIsAnimating = YES;
    self.homeView.changeCityButton.hidden = NO;
    
    if ( [[EventManager sharedManager].savedCities containsObject:self.currentCity] ) {
        self.homeView.addCityToSavedCitiesButton.hidden = YES;
    } else {
        self.homeView.addCityToSavedCitiesButton.hidden = NO;
    }
    
    
    __block CGRect changeCityNewFrame = self.homeView.changeCityButton.frame;
    changeCityNewFrame.origin.y = CGRectGetHeight(self.homeView.changeCityButton.superview.frame);
    self.homeView.changeCityButton.frame = changeCityNewFrame;
    
    __block CGRect cityToSavedButtonFrame = self.homeView.addCityToSavedCitiesButton.frame;
    cityToSavedButtonFrame.origin.y = CGRectGetHeight(self.homeView.addCityToSavedCitiesButton.superview.frame);
    self.homeView.addCityToSavedCitiesButton.frame = cityToSavedButtonFrame;
    
    [UIView animateWithDuration:.4f animations:^{
        
        changeCityNewFrame.origin.y = CGRectGetHeight(self.homeView.changeCityButton.superview.frame)-80;
        self.homeView.changeCityButton.frame = changeCityNewFrame;
        
        cityToSavedButtonFrame.origin.y = CGRectGetHeight(self.homeView.changeCityButton.superview.frame)-80;
        self.homeView.addCityToSavedCitiesButton.frame = cityToSavedButtonFrame;
        
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3f animations:^{
            changeCityNewFrame.origin.y += 10;
            self.homeView.changeCityButton.frame = changeCityNewFrame;
            
            cityToSavedButtonFrame.origin.y += 10;
            self.homeView.addCityToSavedCitiesButton.frame = cityToSavedButtonFrame;
        } completion:^(BOOL finished){
            self.cityIsAnimating = NO;
        }];
    }];
}

-(void) hideChangeCitySelectorAndShowActionSheet:(BOOL) aShow {
    CGRect newFrame = self.homeView.changeCityButton.frame;
    newFrame.origin.y = CGRectGetHeight(self.homeView.changeCityButton.superview.frame);
    
    self.cityIsAnimating = YES;
    self.homeView.changeCityButton.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.homeView.changeCityButton.frame = newFrame;
    } completion:^(BOOL finished) {
        self.homeView.changeCityButton.hidden = YES;
        self.cityIsAnimating = NO;
        if (aShow) {
            [self showActionSheet];
        }
        
    }];
}

-(void) showActionSheet {
    [_cityActionSheet showC:@"Select Your City:"
                     cancel:@"Cancel"
                    buttons:_cityKeys
                     result:^(int nResult) {
                         if (nResult != self.currentCityIndex && nResult != -100) {
                             [self updateViewWithCityIndex:nResult];
                             if (self.citySelected) {
                                 [self.homeView animateShowingContent];
                             }
                         }
                         if (self.citySelected) {
                             [self performSelector:@selector(showChangeCitySelector) withObject:nil afterDelay:.4f];
                         } else {
                             [self performSelector:@selector(showCitySelector) withObject:nil afterDelay:.4f];
                         }
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



@end
