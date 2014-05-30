//
//  HomeView.m
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HomeView.h"

@interface HomeView()

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
    [self setupCityButtons];
    
}

#pragma mark - Setup methods for Home View
- (void)setupGeneral {
    _title.textColor = [UIColor offWhiteScheme];
}

-(void) setupCityButtons {  
    self.changeCityOrigin = CGPointMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.changeCityButton.superview.frame)-70+CGRectGetHeight(self.changeCityButton.frame)/2);
    
    self.changeCityButton.layer.cornerRadius = CGRectGetWidth(self.changeCityButton.frame)/2;
    self.changeCityButton.layer.masksToBounds = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [self.citySelectButton setTitleColor:[UIColor burntScheme] forState:UIControlStateNormal];
        [self.citySelectButton setBackgroundColor:[UIColor offWhiteScheme]];
    }
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
        } completion:^(BOOL finished) {
            [self.delegate setupLayout];
        }];
    }];
}

-(void) bounceContentHeader {
    if ([UIView instancesRespondToSelector:@selector(animateKeyframesWithDuration:delay:options:animations:completion:)]){
        _contentHeader.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        [UIView animateKeyframesWithDuration:.4f delay:0.f options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            _contentHeader.transform = CGAffineTransformIdentity;
        } completion:nil];
    } else {
        //NSLog(@"not animating content header for iOS6");
    }
}

@end
