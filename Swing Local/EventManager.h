//
//  EventManager.h
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"
#import "Event.h"
#import "Venue.h"

@interface EventManager : NSObject

@property (nonatomic) NSArray *allCities;

+(EventManager*) sharedManager;

-(void) downloadEventCities;

-(NSArray*) downloadEventsInCity:(City*) city;

-(NSArray*) downloadEventsForVenue:(Venue*) venue;

@end
