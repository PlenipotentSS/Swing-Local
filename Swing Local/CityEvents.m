//
//  CityEvents.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "CityEvents.h"

@implementation CityEvents


#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _cityName = [aDecoder decodeObjectForKey:@"cityName"];
    _country =[aDecoder decodeObjectForKey:@"country"];
    _venueOrganizations = [aDecoder decodeObjectForKey:@"venueOrganizations"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.venueOrganizations forKey:@"venueOrganizations"];
}

@end
