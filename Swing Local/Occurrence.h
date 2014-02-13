//
//  Occurrence.h
//  Swing Local
//
//  Created by Stevenson on 2/6/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

// LOCAL object only (not found on server). created directly by google, and the class that populates
// all calendar arrays

#import <Foundation/Foundation.h>
#import "Event.h"

@interface Occurrence : NSObject <NSCoding>

//start time of this event occurrence
@property (nonatomic) NSDate *startTime;

//end time of this event occurrence
@property (nonatomic) NSDate *endTime;

//cost cover for this event
@property (nonatomic) NSString *cost;

//start time of this event occurrence
@property (nonatomic) NSString *updatedCost;

//updated by google calendar and api
@property (nonatomic) NSString *updatedTitle;

//updated only by google calendar
@property (nonatomic) NSString *music;

//updated by api or google calendar
@property (nonatomic) NSString *address;

//updated by google calendar and api
@property (nonatomic) NSString *updatedInfoText;

//the event that pertains to this occurrence
@property (weak, nonatomic) Event *eventForOccurrence;

+(Occurrence*) convertDataToOccurrenceModel:(NSDictionary*) occurrenceData withStartTime:(NSDate*) startTime andEndTime:(NSDate*) endTime;

@end
