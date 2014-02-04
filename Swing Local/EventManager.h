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

@property (unsafe_unretained) id<EventManagerCityDelegate> cityDelegate;
@property (unsafe_unretained) id<EventManagerAllCitiesDelegate> allCitiesDelegate;
@property (nonatomic) __block NSArray *allCities;
@property (nonatomic) City *topCity;

+(EventManager*) sharedManager;

-(void) downloadCities;

-(void) downloadVenuesAndEventsInCity:(City*) city;

@end
