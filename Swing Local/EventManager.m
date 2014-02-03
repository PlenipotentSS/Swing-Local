//
//  EventManager.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "EventManager.h"

@implementation EventManager

+(EventManager*) sharedManager {
    static dispatch_once_t pred;
    static EventManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[EventManager alloc] init];
    });
    
    return shared;
}

-(NSArray*) downloadEventCities {
    //data from db for all keys
    NSArray *cities = [[NSArray alloc] init];
    
    return cities;
}

-(NSArray*) downloadEventsInCity:(CityEvents*) city {
    //download all venue information for given city
    NSArray *venues = [[NSArray alloc] init];
    
    return venues;
}

-(NSArray*) downloadEventsForVenue:(VenueOrganization*) venue {
    NSArray *events = [[NSArray alloc] init];
    
    return events;
}

@end
