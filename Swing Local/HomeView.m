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

@interface HomeView() <UIGestureRecognizerDelegate,HomePageManagerDelegate>

//footer view for any separate swipe gestures
@property (nonatomic) IBOutlet UIView *footerView;

//title header of current view
@property (nonatomic) IBOutlet UILabel *title;


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

//the header image set under title
@property (nonatomic) IBOutlet UIImageView *cityHeaderImage;

//View containing content for home page
@property (nonatomic) IBOutlet __block UIView *eventsTodayView;

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
    
    _cityKeys = @[@"Seattle, WA",@"Phoenix, AZ",@"Chicago, IL",@"New Orleans, LA",@"New York, NY",@"Portland, OR",@"San Francisco, CA",@"Denver, CO",@"Los Angeles, CA",@"Washington, D.C.",@"Austin, TX",@"Albuquerque, NM"];
    _title.textColor = [UIColor offWhiteScheme];
    _eventsTodayView.hidden = YES;
    
    [self setupCityButtons];
    [self setupGesture];
    [self setupActionSheet];

}

#pragma mark - Setup methods for Home View
-(void) setupCityButtons {
    _currentCityIndex = -1;
    self.citySelected = NO;
    _cityIsAnimating = NO;
    
    self.changeCityOrigin = CGPointMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.changeCityButton.superview.frame)-70+CGRectGetHeight(self.changeCityButton.frame)/2);
    
    self.changeCityButton.layer.cornerRadius = CGRectGetWidth(self.changeCityButton.frame)/2;
    self.changeCityButton.layer.masksToBounds = YES;
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
        
        //show action sheet
        [self showActionSheet];
    }];
}


#pragma mark - animations for changeCity button
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
        
        
        //show action sheet
        [self showActionSheet];
        
    }];
}


-(void) showActionSheet {
    [_cityActionSheet showC:@"Select Your City:"
                 cancel:@"Cancel"
                buttons:_cityKeys
                 result:^(int nResult) {
                     if (nResult != _currentCityIndex) {
                         [self updateEventsAtCity:nResult];
                     }
                     if (self.citySelected) {
                         if (_eventsTodayView.hidden) {
                             _eventsTodayView.hidden = NO;
                         } else {
                             [UIView animateWithDuration:.4f animations:^{
                                 _eventsTodayView.alpha = 0.f;
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:.4f animations:^{
                                     _eventsTodayView.alpha = 1.f;
                                 }];
                             }];
                         }
                         
                         [self performSelector:@selector(showChangeCitySelector) withObject:nil afterDelay:.4f];
                     } else {
                         [self performSelector:@selector(showCitySelector) withObject:nil afterDelay:.4f];
                     }
                 }];
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



@end
