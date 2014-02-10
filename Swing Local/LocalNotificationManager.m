//
//  LocalNotificationManager.m
//  Swing Local
//
//  Created by Stevenson on 2/10/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "LocalNotificationManager.h"

@implementation LocalNotificationManager

-(void) scheduleNotification
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [self addNumberOfDays:7 toDate:[NSDate date]];
    notification.repeatInterval = NSWeekCalendarUnit;
    notification.alertBody = @"There's some exciting events happening this week! Check it out!";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertAction = NSLocalizedString(@"View", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void) resetNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


-(NSDate*) addNumberOfDays:(NSInteger) days toDate: (NSDate*) date
{
    return [date dateByAddingTimeInterval:60*60*6*days ];
}
@end
