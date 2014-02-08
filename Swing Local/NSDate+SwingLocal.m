//
//  NSDate+SwingLocal.m
//  Swing Local
//
//  Created by Stevenson on 2/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "NSDate+SwingLocal.h"

@implementation NSDate (SwingLocal)

+(BOOL)dateA:(NSDate*)dateA isSameDayAsDateB:(NSDate*)dateB {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:dateA];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:dateB];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+(BOOL)dateA: (NSDate*)dateA isBeforeDateB:(NSDate*)dateB {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:dateA];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:dateB];
    
    if ([comp1 year] < [comp2 year]) {
        return YES;
    }
    if ([comp1 year] == [comp2 year]) {
        if ([comp1 month] < [comp2 month]) {
            return YES;
        }
        if ([comp1 month] == [comp2 month]) {
            if ([comp1 day] <= [comp2 day]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
