//
//  DateRangeSelectorView.h
//  Swing Local
//
//  Created by Stevenson on 2/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXBlurView.h>

@protocol DateRangeSelectorDelegate <NSObject>

-(void) updateTableViewWithBeginDateDate:(NSDate*) startDate toEndDate: (NSDate*) endDate;

@end

@interface DateRangeSelectorView : UIView

@property (unsafe_unretained) id<DateRangeSelectorDelegate> delegate;

-(void) setup;

@end
