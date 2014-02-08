//
//  DetailView.m
//  Swing Local
//
//  Created by Stevenson on 2/6/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "DetailView.h"
@interface DetailView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *DJLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkTitleLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *theScrollView;

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
    [self resizeAndLoadDataViews];
}

-(IBAction)hideDetail:(id)sender {
    [UIView animateWithDuration:.4f animations:^{
        [self setAlpha:0.f];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - content Loading methods
- (void)loadTitleText {
    if (self.thisOccurrence.updatedTitle && ![self.thisOccurrence.updatedTitle isEqualToString:@""]) {
        self.titleLabel.text = self.thisOccurrence.updatedTitle;
    } else {
        self.titleLabel.text = self.thisOccurrence.eventForOccurrence.eventTitle;
    }
}

- (void)loadSubtitleText {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GENERAL_TIME_FORMAT];
    NSString *startTime = [dateFormatter stringFromDate:self.thisOccurrence.startTime];
    NSString *endTime = [dateFormatter stringFromDate:self.thisOccurrence.endTime];
    
    NSString *cost = @"$";
    if (self.thisOccurrence.updatedCost) {
        cost = [NSString stringWithFormat:@"%@%@",cost,self.thisOccurrence.updatedCost];
    } else if (self.thisOccurrence.eventForOccurrence.cost && ![self.thisOccurrence.eventForOccurrence.cost isEqualToString:@""]) {
        cost = [NSString stringWithFormat:@"%@%@",cost,self.thisOccurrence.eventForOccurrence.cost];
    } else {
        cost = @"";
    }
    
    NSString *subtitle = [NSString stringWithFormat:@"%@-%@ : %@",startTime,endTime, cost];
    self.subtitleLabel.text = subtitle;
}

-(void) loadDJText {
    NSString *dj = @"DJ Music";
    if (self.thisOccurrence.DJ && ![self.thisOccurrence.DJ isEqualToString:@""]) {
        dj = [NSString stringWithFormat:@" - %@",self.thisOccurrence.DJ];
    }
    self.DJLabel.text = dj;
}

#pragma mark - Resizing views
-(void) resizeAndLoadDataViews {
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.y = +12;
    self.titleLabel.numberOfLines = 0;
    [self loadTitleText];
    self.titleLabel.frame = titleFrame;
    
    CGRect maxFrame = self.titleLabel.frame;
    maxFrame.size.height = 200.f;
    [self loadSubtitleText];
    [self.titleLabel sizeThatFits:maxFrame.size];
    
    CGRect subtitleFrame = self.subtitleLabel.frame;
    subtitleFrame.origin.y = CGRectGetMinY(self.titleLabel.frame) +CGRectGetHeight(self.titleLabel.frame)+6;
    self.subtitleLabel.frame = subtitleFrame;
    
    CGRect djFrame = self.DJLabel.frame;
    djFrame.origin.y = CGRectGetMinY(self.subtitleLabel.frame) + CGRectGetHeight(self.subtitleLabel.frame) + 24;
    [self loadDJText];
    self.DJLabel.frame = djFrame;
    
    CGRect contentFrame = self.contentLabel.frame;
    contentFrame.origin.y = CGRectGetMinY(self.DJLabel.frame) + CGRectGetHeight(self.DJLabel.frame) + 24;
    
    self.contentLabel.text = self.thisOccurrence.updatedInfoText;
    [self.contentLabel sizeToFit];
    self.contentLabel.frame = contentFrame;
    
    [self setNeedsDisplay];
}

@end
