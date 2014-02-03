//
//  testData.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "testData.h"
#import "City.h"
#import "Venue.h"
#import "Event.h"

@implementation testData

- (id)init
{
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

-(void) setupData {
    _cities = [[NSMutableArray alloc] init];
    _venues = [[NSMutableArray alloc] init];
    _events = [[NSMutableArray alloc] init];

    City *city1 = [self setupCity];
    NSLog(@"%@",city1);
    
}

-(City*) setupCity {
    City *city = [City new];
    
    Venue *venue1 = [Venue new];
    venue1.venueTitle = @"Savoy Swing Club";
    [city.venueOrganizations addObject:venue1];
    
    
    Event *event1 = [Event new];
    event1.eventTitle = @"Savoy Mondays";
    [venue1.events addObject:event1];
    
    return city;
}



@end
