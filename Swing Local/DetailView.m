//
//  DetailView.m
//  Swing Local
//
//  Created by Stevenson on 2/6/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "DetailView.h"
#import "UIColor+SwingLocal.h"
@interface DetailView()

@property (nonatomic) UIImageView *headerImg;
@property (nonatomic) UIButton *closeButton;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subtitleLabel;
@property (nonatomic) UILabel *DJLabel;
@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UILabel *linkTitleLabel;

@property (nonatomic) UIScrollView *theScrollView;

@end

@implementation DetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


-(void) setThisOccurrence:(Occurrence *)thisOccurrence {
    _thisOccurrence = thisOccurrence;
    self.theScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.theScrollView.frame), 700.f);
    [self createLabels];
}

-(IBAction)hideDetail:(id)sender {
    [UIView animateWithDuration:.4f animations:^{
        [self setAlpha:0.f];
    } completion:^(BOOL finished) {
         
        [self.titleLabel removeFromSuperview];
        [self.subtitleLabel removeFromSuperview];
        [self.DJLabel removeFromSuperview];
        [self.contentLabel removeFromSuperview];
        [self.linkTitleLabel removeFromSuperview];
        [self.theScrollView removeFromSuperview];
        
    }];
}

#pragma mark - content Loading methods
-(void) createLabels {
    CGRect windowRect = [UIScreen mainScreen].bounds;
    
    
    //pin img
    if (![self.headerImg superview]) {
        self.headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(147.0f, 19.f, 27.f, 56.f)];
        UIImage *pinImage = [UIImage imageNamed:@"SwingLocalLogo-Pin_Only"];
        
        self.headerImg.image = pinImage;
        [self addSubview:self.headerImg];
    }
    
    
    //close button
    if (![self.closeButton superview]) {
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(245.f, 26.f, 65.f, 42.f)];
        [self.closeButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:20.0]];
        [self.closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [self.closeButton setTitleColor:[UIColor aquaScheme] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(hideDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
    }
    
    if (![self.theScrollView superview]) {
        self.theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 70.f, 320.f, (CGRectGetHeight(windowRect)-70.f))];
        self.theScrollView.backgroundColor = [UIColor clearColor];
        self.theScrollView.scrollEnabled = YES;
        [self addSubview:self.theScrollView];
    }
    
    
    //title
    CGFloat ongoingHeight = 12.0f;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, ongoingHeight, CGRectGetWidth(self.theScrollView.frame)-40, 45.0f)];
    self.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:23.0];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor aquaScheme];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.shadowColor = [UIColor lightGrayColor];
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.titleLabel.text = self.thisOccurrence.updatedTitle;
    [self.titleLabel sizeToFit];
    ongoingHeight += CGRectGetHeight(self.titleLabel.frame)+2;
    
    if (![self.titleLabel superview]) {
        [self.theScrollView addSubview:self.titleLabel];
    }
    
    //subtitle
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GENERAL_TIME_FORMAT];
    NSString *startTime = [dateFormatter stringFromDate:self.thisOccurrence.startTime];
    NSString *endTime = [dateFormatter stringFromDate:self.thisOccurrence.endTime];
    NSString *cost = @"";
    if (self.thisOccurrence.updatedCost) {
        cost = [NSString stringWithFormat:@"%@%@",cost,self.thisOccurrence.updatedCost];
    } else if (self.thisOccurrence.eventForOccurrence.cost && ![self.thisOccurrence.eventForOccurrence.cost isEqualToString:@""]) {
        cost = [NSString stringWithFormat:@"%@%@",cost,self.thisOccurrence.eventForOccurrence.cost];
    } else {
        cost = @"";
    }
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, ongoingHeight, CGRectGetWidth(self.theScrollView.frame)-40, 30.0f)];
    self.subtitleLabel.font = [UIFont fontWithName:@"Avenir-Oblique" size:14.0];
    self.subtitleLabel.textAlignment = NSTextAlignmentLeft;
    self.subtitleLabel.textColor = [UIColor aquaScheme];
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@-%@ : %@",startTime,endTime, cost];
    self.subtitleLabel.numberOfLines = 0;
    [self.subtitleLabel sizeToFit];
    ongoingHeight += CGRectGetHeight(self.subtitleLabel.frame)+30;
    
    if (![self.subtitleLabel superview]) {
        [self.theScrollView addSubview:self.subtitleLabel];
    }
    
    
    //dj or music
    NSString *dj = @"DJ Music";
    if (self.thisOccurrence.DJ && ![self.thisOccurrence.DJ isEqualToString:@""]) {
        dj = [NSString stringWithFormat:@" - %@",self.thisOccurrence.DJ];
    }
    
    self.DJLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, ongoingHeight, CGRectGetWidth(self.theScrollView.frame)-40, 30.0f)];
    self.DJLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:20.0];
    self.DJLabel.textAlignment = NSTextAlignmentLeft;
    self.DJLabel.textColor = [UIColor aquaScheme];
    self.DJLabel.text = dj;
    self.DJLabel.numberOfLines = 0;
    [self.DJLabel sizeToFit];
    ongoingHeight += CGRectGetHeight(self.DJLabel.frame)+5;
    
    if (![self.DJLabel superview]) {
        [self.theScrollView addSubview:self.DJLabel];
    }
    
    //load text
    self.contentLabel= [[UILabel alloc] initWithFrame:CGRectMake(20.0f, ongoingHeight, CGRectGetWidth(self.theScrollView.frame)-40, 30.0f)];
    self.contentLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:12.0];
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.textColor = [UIColor aquaScheme];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.text = self.thisOccurrence.updatedInfoText;
    [self.contentLabel sizeToFit];
    ongoingHeight += CGRectGetHeight(self.contentLabel.frame)+30;
    
    if (![self.contentLabel superview]) {
        [self.theScrollView addSubview:self.contentLabel];
    }
    
    //links header
    self.linkTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, ongoingHeight, CGRectGetWidth(self.theScrollView.frame)-40, 30.0f)];
    self.linkTitleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:20.0];
    self.linkTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.linkTitleLabel.textColor = [UIColor aquaScheme];
    self.linkTitleLabel.text = @"Links";
    self.linkTitleLabel.numberOfLines = 0;
    [self.linkTitleLabel sizeToFit];
    ongoingHeight += CGRectGetHeight(self.linkTitleLabel.frame)+5;
    
    if (![self.linkTitleLabel superview]) {
        [self.theScrollView addSubview:self.linkTitleLabel];
    }
    
    
    self.theScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.theScrollView.frame), ongoingHeight+100);
}























@end
