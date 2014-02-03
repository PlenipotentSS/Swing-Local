//
//  EventObject.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueEvent : NSObject <NSCoding>

//updated by google calendar and api
@property (nonatomic) NSString *eventTitle;

//start time of this event
@property (nonatomic) NSDate *startTime;

//end time of this event
@property (nonatomic) NSDate *endTime;

//cost cover for this event
@property (nonatomic) NSString *cost;

//age limit for this dance if exists
@property (nonatomic) NSString *ages;

//updated by google calendar and api
@property (nonatomic) NSString *infoText;

//updated only by google calendar
@property (nonatomic) NSString *DJ;

//updated by api or google calendar
@property (nonatomic) NSString *address;

//the image corresponding to this event
@property (nonatomic) UIImage *eventImage;

//the string to lazy load images for this event
@property (nonatomic) NSString *imageURLString;




@end
