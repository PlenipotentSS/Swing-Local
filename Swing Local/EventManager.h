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

@protocol EventManagerCityDelegate <NSObject>

-(void) refreshEventTableWithCity: (City*) thisCity;

@end

@interface EventManager : NSObject

//delegate to download and refresh venues/events in a given city
@property (unsafe_unretained) id<EventManagerCityDelegate> cityDelegate;

//array of all cities
@property (nonatomic) __block NSArray *allCities;

//current City to load for single city views
@property (nonatomic) City *currentCity;


//current City to load for single city views
@property (nonatomic) __block NSMutableArray *savedCities;

+(EventManager*) sharedManager;

-(void) persistAndNotifySavedCities;

-(void) downloadCities;

-(void) downloadVenuesAndEventsInCity:(City*) city;

@end
