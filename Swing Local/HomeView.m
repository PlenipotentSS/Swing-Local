//
//  HomeView.m
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HomeView.h"
#import "UIColor+SwingLocal.h"
#import "SSActionSheet.h"
#import "HomePageManager.h"
#import "HollowButton.h"
#import "EventsTableView.h"
#import "EventsTableViewModel.h"

@interface HomeView() <UIGestureRecognizerDelegate, HomePageManagerDelegate>

//wrapper view
@property (weak, nonatomic) IBOutlet UIView *wrapper;

//button to select a city for first run
@property (weak, nonatomic) IBOutlet UIButton *citySelectButton;

//button to change city after selected
@property (weak, nonatomic) IBOutlet HollowButton *changeCityButton;

//content ScrollView
@property (weak,nonatomic) IBOutlet EventsTableView *contentScrollView;

//content Header view to display tonight's dances
@property (weak, nonatomic) IBOutlet UIView *contentHeader;

//footer view for any separate swipe gestures
@property (weak, nonatomic) IBOutlet UIView *footerView;

//title header of current view
@property (weak, nonatomic) IBOutlet UILabel *title;

//the header image set under title
@property (weak, nonatomic) IBOutlet UIImageView *cityHeaderImage;

//button for more dances
@property (weak, nonatomic) IBOutlet HollowButton *moreEvents;

//button for more dances
@property (weak, nonatomic) IBOutlet UIButton *moreEventsWrapper;

//flag for ongoing animation
@property (nonatomic) BOOL __block cityIsAnimating;

//action sheet to display cities
@property (nonatomic) SSActionSheet *cityActionSheet;

//current index selected in city array
@property (nonatomic) NSInteger currentCityIndex;

//original origin of changeCity Button
@property (nonatomic) CGPoint changeCityOrigin;

//whether there is a city that this user has selected in the past
@property (nonatomic) BOOL citySelected;

//table view model
@property (nonatomic) EventsTableViewModel *contentModel;

@property (nonatomic) BOOL newsIsActive;


@end

@implementation HomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setup {
    
    [self setupGeneral];
    [self setupContentTable];
    [self setupCityButtons];
    [self setupGesture];
    [self setupActionSheet];
    [self setupNews];
    
}

#pragma mark - Setup methods for Home View
- (void)setupGeneral {
    _cityKeys = @[@"Seattle, WA",@"Phoenix, AZ",@"Chicago, IL",@"New Orleans, LA",@"New York, NY",@"Portland, OR",@"San Francisco, CA",@"Denver, CO",@"Los Angeles, CA",@"Washington, D.C.",@"Austin, TX",@"Albuquerque, NM"];
    _title.textColor = [UIColor offWhiteScheme];
    
    
    _contentScrollView.contentSize = CGSizeMake(320.f, 1000.f);
    _contentScrollView.userInteractionEnabled = YES;
    _contentScrollView.scrollEnabled = YES;
}

-(void) setupContentTable {
    _contentModel = [[EventsTableViewModel alloc] init];
    _contentScrollView.delegate = _contentModel;
    _contentScrollView.dataSource = _contentModel;
    [_contentModel setTheTableView:_contentScrollView];
}

-(void) setupCityButtons {
    _currentCityIndex = -1;
    self.citySelected = NO;
    _cityIsAnimating = NO;
    
    self.changeCityOrigin = CGPointMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.changeCityButton.superview.frame)-70+CGRectGetHeight(self.changeCityButton.frame)/2);
    
    self.changeCityButton.layer.cornerRadius = CGRectGetWidth(self.changeCityButton.frame)/2;
    self.changeCityButton.layer.masksToBounds = YES;
    [self.changeCityButton setColorOverlay:[UIColor burntScheme] withImage:[UIImage imageNamed:@"arrow_down"]];
    
    self.moreEvents.layer.cornerRadius = CGRectGetWidth(self.moreEvents.frame)/2;
    self.moreEvents.layer.masksToBounds = YES;
    [self.moreEvents setColorOverlay:[UIColor burntScheme] withImage:[UIImage imageNamed:@"arrow_right"]];
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

-(void) setupActionSheet {
    _cityActionSheet = [[SSActionSheet alloc] init];
    _cityActionSheet.nAnimationType = DoTransitionStylePop;
    _cityActionSheet.dButtonRound = 2;
    
}

-(void) setupNews {
    if (!_citySelected && _newsView) {
        CGRect newsFrame = _newsView.frame;
        newsFrame.size.height = CGRectGetHeight(self.frame)-CGRectGetHeight(_footerView.frame);
        _newsView.frame = newsFrame;
        [self insertSubview:_newsView aboveSubview:_footerView];
        _newsIsActive =YES;
    }
}

#pragma mark - IBActions to select city
-(IBAction)selectCity:(id)sender {
    if (!self.cityIsAnimating) {
        [self hideCitySelector];
    }
}

-(IBAction)changeCity:(id)sender {
    if (!self.cityIsAnimating) {
        [self hideChangeCitySelector];
    }
}

#pragma mark - Pan Gesture Selector
-(void) footerSlide:(id)sender {
    if (!self.cityIsAnimating){
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
        if (self.citySelected) {
            [self moveButton:self.changeCityButton withGesture:pan];
        } else {
            [self moveButton:self.citySelectButton withGesture:pan];
        }
    }
    
}

-(void) moveButton:(UIButton*) button withGesture:(UIPanGestureRecognizer*) pan {
    CGPoint translation = [pan translationInView:self];
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
            if (_currentCityIndex == -1) {
                [self hideCitySelector];
            } else {
                [self hideChangeCitySelector];
            }
        } else {
            _cityIsAnimating = YES;
            [UIView animateWithDuration:.4f animations:^{
                button.center = self.changeCityOrigin;
            } completion:^(BOOL finished) {
                _cityIsAnimating = NO;
            }];
        }
    }
}

#pragma mark - animations for selectCity button
-(void) showCitySelector {
    self.citySelectButton.hidden = NO;
    __block CGRect changeCityNewFrame = self.citySelectButton.frame;
    changeCityNewFrame.origin.y = CGRectGetHeight(self.citySelectButton.superview.frame);
    self.citySelectButton.frame = changeCityNewFrame;
    
    
    _cityIsAnimating = YES;
    [UIView animateWithDuration:.6f animations:^{
        changeCityNewFrame.origin.y = CGRectGetHeight(self.citySelectButton.superview.frame)-70;
        self.citySelectButton.frame = changeCityNewFrame;
    } completion:^(BOOL finished){
        _cityIsAnimating = NO;
    }];
}

-(void) hideCitySelector {
    CGRect newFrame = self.citySelectButton.frame;
    newFrame.origin.y = CGRectGetHeight(self.footerView.frame);
    _cityIsAnimating = YES;
    self.citySelectButton.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.citySelectButton.frame = newFrame;
    } completion:^(BOOL finished) {
        self.citySelectButton.hidden = YES;
        _cityIsAnimating = NO;
        
        [self showActionSheet];
    }];
}

#pragma mark - Animation Methods
#pragma mark animations for changeCity button
-(void) showChangeCitySelector {
    self.changeCityButton.hidden = NO;
    __block CGRect changeCityNewFrame = self.changeCityButton.frame;
    changeCityNewFrame.origin.y = CGRectGetHeight(self.changeCityButton.superview.frame);
    self.changeCityButton.frame = changeCityNewFrame;
    _cityIsAnimating = YES;
    [UIView animateWithDuration:.4f animations:^{
        changeCityNewFrame.origin.y = CGRectGetHeight(self.changeCityButton.superview.frame)-80;
        self.changeCityButton.frame = changeCityNewFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3f animations:^{
            changeCityNewFrame.origin.y += 10;
            self.changeCityButton.frame = changeCityNewFrame;
        } completion:^(BOOL finished){
            _cityIsAnimating = NO;
        }];
    }];
}

-(void) hideChangeCitySelector {
    CGRect newFrame = self.changeCityButton.frame;
    newFrame.origin.y = CGRectGetHeight(self.changeCityButton.superview.frame);
    
    _cityIsAnimating = YES;
    self.changeCityButton.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.changeCityButton.frame = newFrame;
    } completion:^(BOOL finished) {
        self.changeCityButton.hidden = YES;
        _cityIsAnimating = NO;
        
        [self showActionSheet];
        
    }];
}


-(void) showActionSheet {
    [_cityActionSheet showC:@"Select Your City:"
                     cancel:@"Cancel"
                    buttons:_cityKeys
                     result:^(int nResult) {
                         if (nResult != _currentCityIndex && nResult != -100) {
                             [self updateEventsAtCity:nResult];
                             if (self.citySelected) {
                                 [self animateShowingContent];
                             }
                         }
                         if (self.citySelected) {
                             if (_newsIsActive) {
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

#pragma mark animation for sub view methods
-(void) animateShowingContent {
    _contentHeader.alpha = 1.f;
    [UIView animateWithDuration:.4f animations:^{
        _contentHeader.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self bounceContentHeader];
        [UIView animateWithDuration:.8f animations:^{
            _contentHeader.alpha = 1.f;
        }];
    }];
}

-(void) bounceContentHeader {
    _contentHeader.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    [UIView animateKeyframesWithDuration:.4f delay:0.f options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        _contentHeader.transform = CGAffineTransformIdentity;
    } completion:nil];
}

#pragma mark - action sheet result
-(void) updateEventsAtCity:(NSInteger) index {
    if (index >= 0 && index < [_cityKeys count]) {
        if (!self.citySelected) {
            self.citySelected = YES;
        }
        _currentCityIndex = index;
        [_title setText:[_cityKeys objectAtIndex:index]];
        [[HomePageManager sharedManager] setDelegate:self];
        NSURL *headerImageURL = [self getImageFromCity:[_cityKeys objectAtIndex:index]];
        [[HomePageManager sharedManager] downloadImageFromURL:headerImageURL];
        [_contentModel setCity:[_cityKeys objectAtIndex:index]];
    }
}

#pragma mark - imageviewcreator
-(NSURL*) getImageFromCity: (NSString*) cityName {
    cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=10&size=460x230&maptype=roadmap&sensor=false",cityName];
    return [NSURL URLWithString:strURL];
}

#pragma mark - HomePageManagerDelegate methods
-(void) updateViewWithImage:(UIImage*) theImage {
    [_cityHeaderImage setAlpha:0.f];
    [_cityHeaderImage setImage:theImage];
    [UIView animateWithDuration:.4f animations:^{
        [_cityHeaderImage setAlpha:1.f];
    }];
}

#pragma mark - outlets
-(void) presentMoreEvents {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"More Events" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}


@end
