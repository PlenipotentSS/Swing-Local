//
//  DateRangeSelectorView.m
//  Swing Local
//
//  Created by Stevenson on 2/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "DateRangeSelectorView.h"
@interface DateRangeSelectorView()

@property (nonatomic,weak) IBOutlet UIDatePicker *startPicker;
@property (nonatomic,weak) IBOutlet UIDatePicker *endPicker;
@property (nonatomic,weak) IBOutlet UIButton *doneButton;

@end

@implementation DateRangeSelectorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setup
{
    CGRect startDateFrame =  self.startPicker.frame;
    startDateFrame.size.height = 100.f;
    self.startPicker.frame = startDateFrame;
    
    CGRect endDateFrame =  self.endPicker.frame;
    endDateFrame.size.height = 100.f;
    self.startPicker.frame = endDateFrame;
    
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

-(IBAction)setCurrentDate:(id)sender
{
    NSDate *start = self.startPicker.date;
    NSDate *end = self.endPicker.date;
    if (start <= end) {
        [self removeFromSuperview];
        [self.delegate updateTableViewWithBeginDateDate:start toEndDate:end];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Date Range" message:@"Start date must be before end Date" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }
    
}

@end
