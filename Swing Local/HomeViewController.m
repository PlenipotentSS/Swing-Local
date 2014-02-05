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

@interface HomeViewController () <UIGestureRecognizerDelegate, HomePageManagerDelegate, EventManagerAllCitiesDelegate>

//the header image set under title
@property (weak, nonatomic) IBOutlet UIImageView *cityHeaderImage;

//content ScrollView
@property (weak,nonatomic) IBOutlet EventsTableView *contentTableView;

//flag for ongoing animation
@property (nonatomic) BOOL __block cityIsAnimating;

//main view for this controller
@property (weak, nonatomic) HomeView *homeView;

//array of all cities
@property (nonatomic) NSArray *cityKeys;

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

//news view
@property (nonatomic) NewsView *newsView;

//flag if news is currently presented
@property (nonatomic) BOOL newsIsActive;

//current index selected in city array
@property (nonatomic) NSInteger currentCityIndex;

//whether there is a city that this user has selected in the past
@property (nonatomic) BOOL citySelected;

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
    
    [[EventManager sharedManager] setAllCitiesDelegate:self];
    [[EventManager sharedManager] downloadCities];
    [self setupContentTable];
    [self setupGesture];
    [self setupButtons];
    [self setupNews];
    [self setupActionSheet];
    [self setupGeneral];
    [self loadCities];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadInitialCity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup methods
-(void) setupGeneral {
    _homeView = (HomeView*)self.view;
    [_homeView setup];    
    self.homeView.footerView = self.footerView;
}

-(void) setupNews {
    if (!self.citySelected && self.newsView) {
        CGRect newsFrame = _newsView.frame;
        newsFrame.size.height = CGRectGetHeight(self.homeView.frame)-CGRectGetHeight(self.footerView.frame);
        self.newsView.frame = newsFrame;
        [self.homeView insertSubview:_newsView aboveSubview:_footerView];
        self.newsIsActive =YES;
    }
}


-(void) setupActionSheet {
    _cityActionSheet = [[SSActionSheet alloc] init];
    _cityActionSheet.nAnimationType = DoTransitionStylePop;
    _cityActionSheet.dButtonRound = 2;
}

-(void) reloadAllCities {
    [self loadCities];
}

-(void) loadCities {
    NSArray *allCities = [[EventManager sharedManager] allCities];
    NSMutableArray *cityNames = [NSMutableArray new];
    for (City *thisCity in allCities) {
        [cityNames addObject:thisCity.cityName];
    }
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    _cityKeys = [cityNames sortedArrayUsingDescriptors:sortDescriptors];
    
}

-(void) setupContentTable {
    _contentTableView.contentSize = CGSizeMake(320.f, 1000.f);
    _contentTableView.userInteractionEnabled = YES;
    _contentTableView.scrollEnabled = YES;
    
    _contentModel = [[EventsTableViewModel alloc] init];
    _contentTableView.delegate = _contentModel;
    _contentTableView.dataSource = _contentModel;
    [_contentModel setTheTableView:_contentTableView];
}

-(void) setupButtons {
    self.cityIsAnimating = NO;
    _currentCityIndex = -1;
    
    self.moreEvents.layer.cornerRadius = CGRectGetWidth(self.moreEvents.frame)/2;
    self.moreEvents.layer.masksToBounds = YES;
    //[self.moreEvents setColorOverlay:[UIColor burntScheme] withImage:[UIImage imageNamed:@"arrow_right"]];
    [self.moreEvents addTarget:self action:@selector(presentMoreEvents) forControlEvents:UIControlEventTouchUpInside];
    
    [self.moreEventsWrapper addTarget:self action:@selector(presentMoreEvents) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setupGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(footerSlide:)];
    
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    
    pan.delegate = self;
    [self.footerView addGestureRecognizer:pan];
}

#pragma mark - Event management
-(void) loadInitialCity {
    if ([EventManager sharedManager].topCity) {
        self.citySelected = YES;
        [self hideCitySelectorAndShowActionSheet:NO];
        [self showChangeCitySelector];
        [self updateViewWithCity:[EventManager sharedManager].topCity];
    }
}

#pragma mark - IBActions to select city
-(IBAction)selectCity:(id)sender {
    if (!self.cityIsAnimating) {
        [self hideCitySelectorAndShowActionSheet:YES];
    }
}

-(IBAction)changeCity:(id)sender {
    if (!self.cityIsAnimating) {
        [self hideChangeCitySelectorAndShowActionSheet:YES];
    }
}

#pragma mark - Pan Gesture Selector
-(void) footerSlide:(id)sender {
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
        self.currentCityIndex = index;
        [self.homeView.title setText:[_cityKeys objectAtIndex:index]];
        [[HomePageManager sharedManager] setDelegate:self];
        NSURL *headerImageURL = [self getImageFromCityName:[_cityKeys objectAtIndex:index]];
        [[HomePageManager sharedManager] downloadImageFromURL:headerImageURL forCityName:[_cityKeys objectAtIndex:index]];
        [_contentModel setCityWithName:[_cityKeys objectAtIndex:index]];
    }
}

-(void) updateViewWithCity:(City*) thisCity {
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
    self.homeView.changeCityButton.hidden = NO;
    __block CGRect changeCityNewFrame = self.homeView.changeCityButton.frame;
    changeCityNewFrame.origin.y = CGRectGetHeight(self.homeView.changeCityButton.superview.frame);
    self.homeView.changeCityButton.frame = changeCityNewFrame;
    self.cityIsAnimating = YES;
    [UIView animateWithDuration:.4f animations:^{
        changeCityNewFrame.origin.y = CGRectGetHeight(self.homeView.changeCityButton.superview.frame)-80;
        self.homeView.changeCityButton.frame = changeCityNewFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3f animations:^{
            changeCityNewFrame.origin.y += 10;
            self.homeView.changeCityButton.frame = changeCityNewFrame;
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
                             if (self.newsIsActive) {
                                 [UIView animateWithDuration:.5f animations:^{
                                     [_newsView setAlpha:0.f];
                                 } completion:^(BOOL finished) {
                                     [_newsView removeFromSuperview];
                                 }];
                                 _newsIsActive = NO;
                             }
                             [self performSelector:@selector(showChangeCitySelector) withObject:nil afterDelay:.4f];
                         } else {
                             [self performSelector:@selector(showCitySelector) withObject:nil afterDelay:.4f];
                         }
                     }];
}




@end
