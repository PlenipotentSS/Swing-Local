//
//  testData.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "testData.h"
#import "CityEvents.h"
#import "VenueOrganization.h"
#import "VenueEvent.h"

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

    CityEvents *city1 = [self setupCity];
    NSLog(@"%@",city1);
    
}

-(CityEvents*) setupCity {
    CityEvents *city = [CityEvents new];
    
    VenueOrganization *venue1 = [VenueOrganization new];
    venue1.venueTitle = @"Savoy Swing Club";
    [city.venueOrganizations addObject:venue1];
    
    
    VenueEvent *event1 = [VenueEvent new];
    event1.eventTitle = @"Savoy Mondays";
    [venue1.events addObject:event1];
    
    return city;
}



@end
