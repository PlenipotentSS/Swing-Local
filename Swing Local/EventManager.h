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

@protocol EventManagerDelegate <NSObject>

-(void) reloadEvents;

@end

@interface EventManager : NSObject

@property (unsafe_unretained) id<EventManagerDelegate> delegate;
@property (nonatomic) __block NSArray *allCities;
@property (nonatomic) City *topCity;

+(EventManager*) sharedManager;

-(void) downloadCities;

-(void) downloadVenuesInCity:(City*) city;

@end
