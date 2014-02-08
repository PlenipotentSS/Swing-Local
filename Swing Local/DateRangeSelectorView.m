//
//  DateRangeSelectorView.m
//  Swing Local
//
//  Created by Stevenson on 2/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "DateRangeSelectorView.h"
#import "NSDate+SwingLocal.h"
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
    
    if ([start timeIntervalSinceDate:end] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Date Range" message:@"Start date must be before end Date" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];

    } else if ( [self daysWithinEraFromDate:start toDate:end] > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Date Range" message:@"Can only process dates within 2 weeks of start date" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        
    } else {
        [self removeFromSuperview];
        [self.shadowBoxBackground removeFromSuperview];
        [self.delegate updateTableViewWithBeginDateDate:start toEndDate:end];
    }
    
}

-(NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *newDate1 = [startDate dateByAddingTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT]];
    NSDate *newDate2 = [endDate dateByAddingTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT]];
    
    NSInteger startDay=[gregorian ordinalityOfUnit:NSDayCalendarUnit
                                            inUnit: NSEraCalendarUnit forDate:newDate1];
    NSInteger endDay=[gregorian ordinalityOfUnit:NSDayCalendarUnit
                                          inUnit: NSEraCalendarUnit forDate:newDate2];
    return endDay-startDay;
}

@end
