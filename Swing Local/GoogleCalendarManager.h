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
-(void) updateVenueForTodaysEvents:(NSArray*) todaysEvents;

-(void) updateEventsInVenuesWithDateRange:(NSArray*) todaysEvents;

@end

@interface GoogleCalendarManager : NSObject

+(GoogleCalendarManager*) sharedManager;

@property (unsafe_unretained) id<GoogleCalendarManagerDelegate> delegate;

-(void) getTodaysOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event*) theEvent;

@end
