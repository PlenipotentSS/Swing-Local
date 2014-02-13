//
//  GoogleCalendarManager.h
//  Swing Local
//
//  Created by Stevenson on 2/5/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@protocol GoogleCalendarManagerDelegate <NSObject>

@optional
-(void) updateVenueForEvent:(Event*) theEvent;

-(void) updateEventsInVenuesWithDateRange:(NSArray*) todaysEvents;

-(void) doneDownloadingOccurrences;

@end

@interface GoogleCalendarManager : NSObject

+(GoogleCalendarManager*) sharedManager;

@property (unsafe_unretained) id<GoogleCalendarManagerDelegate> delegate;

-(void) cancelAllDownloadJobs;

-(void) getTodaysOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event *)theEvent;

//array of date range must have an array of every date that wants to be shown (i.e. today is 1 date and 7 days is 7 dates)
-(void) getOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event *)theEvent andForDateRange: (NSArray*) dates;

@end
