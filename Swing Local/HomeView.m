//
//  HomeView.m
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HomeView.h"
#import "UIColor+LocalSwingCalendar.h"
@interface HomeView() <UIGestureRecognizerDelegate>

@property (nonatomic) IBOutlet UIView *footerView;
@property (nonatomic) BOOL __block cityIsAnimating;
@property (nonatomic) BOOL selectCityButtonAvailable;

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
    self.cityIsAnimating = NO;
    self.selectCityButtonAvailable = YES;
    self.changeCityButton.layer.cornerRadius = CGRectGetWidth(self.changeCityButton.frame)/2;
    self.changeCityButton.layer.masksToBounds = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(footerSlide:)];
    
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    
    pan.delegate = self;
    [self.footerView addGestureRecognizer:pan];
}

-(IBAction)selectCity:(id)sender {
    if (!self.cityIsAnimating) {
        [self hideCitySelector];
    }
}

-(IBAction)changeCity:(id)sender {
    if (!self.cityIsAnimating) {
        [self showCitySelector];
    }
}

#pragma mark - Pan Gesture Selector
-(void) footerSlide:(id)sender {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    
    CGPoint translation = [pan translationInView:self];
    if (translation.y > 45 && !self.cityIsAnimating) {
        if (self.selectCityButtonAvailable) {
            [self hideCitySelector];
        } else {
            [self showCitySelector];
        }
    }
}

#pragma mark - City Button Animations
-(void) hideCitySelector {
    CGRect newFrame = self.citySelectButton.frame;
    newFrame.origin.y = CGRectGetHeight(self.footerView.frame);
    _cityIsAnimating = YES;
    self.citySelectButton.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.citySelectButton.frame = newFrame;
    } completion:^(BOOL finished) {
        self.citySelectButton.hidden = YES;
        self.selectCityButtonAvailable = NO;
        
        
        //pause for select box
        
        self.changeCityButton.hidden = NO;
        __block CGRect changeCityNewFrame = self.changeCityButton.frame;
        changeCityNewFrame.origin.y = CGRectGetHeight(self.changeCityButton.superview.frame);
        self.changeCityButton.frame = changeCityNewFrame;
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
        
    }];
}

-(void) showCitySelector {
    CGRect newFrame = self.changeCityButton.frame;
    newFrame.origin.y = CGRectGetHeight(self.changeCityButton.superview.frame);
    
    _cityIsAnimating = YES;
    self.changeCityButton.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.changeCityButton.frame = newFrame;
    } completion:^(BOOL finished) {
        self.changeCityButton.hidden = YES;
        
        
        //pause for select box
        
        self.citySelectButton.hidden = NO;
        __block CGRect changeCityNewFrame = self.citySelectButton.frame;
        changeCityNewFrame.origin.y = CGRectGetHeight(self.citySelectButton.superview.frame);
        self.citySelectButton.frame = changeCityNewFrame;
        
        [UIView animateWithDuration:.6f animations:^{
            changeCityNewFrame.origin.y = CGRectGetHeight(self.citySelectButton.superview.frame)-73;
            self.citySelectButton.frame = changeCityNewFrame;
        } completion:^(BOOL finished){
            _cityIsAnimating = NO;
        }];
    }];
    self.selectCityButtonAvailable = YES;
}


@end
