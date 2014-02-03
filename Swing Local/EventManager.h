//
//  EventManager.h
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityEvents.h"
#import "VenueEvent.h"
#import "VenueOrganization.h"

@interface EventManager : NSObject

+(EventManager*) sharedManager;

-(NSArray*) downloadEventCities;

-(NSArray*) downloadEventsInCity:(CityEvents*) city;

-(NSArray*) downloadEventsForVenue:(VenueOrganization*) venue;

@end
