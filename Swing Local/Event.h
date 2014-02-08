//
//  EventObject.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject <NSCoding>

//updated by google calendar and api
@property (nonatomic) NSString *eventTitle;

//cost cover for this event
@property (nonatomic) NSString *cost;

//age limit for this dance if exists
@property (nonatomic) NSString *ages;

//updated by google calendar and api
@property (nonatomic) NSString *infoText;

//the image corresponding to this event
@property (nonatomic) UIImage *eventImage;

//the string to lazy load images for this event
@property (nonatomic) NSString *imageURLString;

//the string to lazy load images for this event
@property (nonatomic) NSString *calendar_id;

//the occurrences of a given event
@property (nonatomic) NSArray *occurrences;

//download image from imageurlstring
-(void) downloadEventImage;

//conversion from venue data to event models
+(NSMutableArray*) convertDataToEventModel:(NSArray*) eventData ;

-(void) sortOccurrences;

@end
