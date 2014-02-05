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

@protocol EventManagerAllCitiesDelegate <NSObject>

-(void) reloadAllCities;

@end

@interface EventManager : NSObject

//delegate to download and refresh venues/events in a given city
@property (unsafe_unretained) id<EventManagerCityDelegate> cityDelegate;

//delegate to update controller that all cities is ready
@property (unsafe_unretained) id<EventManagerAllCitiesDelegate> allCitiesDelegate;

//array of all cities
@property (nonatomic) __block NSArray *allCities;

//the top ranking city to show on home view
@property (nonatomic) City *topCity;

//current City to load for single city views
@property (nonatomic) City *currentCity;


//current City to load for single city views
@property (nonatomic) NSMutableArray *savedCities;

+(EventManager*) sharedManager;

-(void) downloadCities;

-(void) downloadVenuesAndEventsInCity:(City*) city;

@end
