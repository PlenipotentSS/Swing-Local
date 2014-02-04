//
//  CityEvents.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "City.h"

@implementation City


#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _cityName = [aDecoder decodeObjectForKey:@"cityName"];
    _country =[aDecoder decodeObjectForKey:@"country"];
    _venueOrganizations = [aDecoder decodeObjectForKey:@"venueOrganizations"];
    _cityID = [[aDecoder decodeObjectForKey:@"cityID"] integerValue];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.venueOrganizations forKey:@"venueOrganizations"];
    [aCoder encodeObject:@(self.cityID) forKey:@"cityID"];
}

-(void)downloadCityImage {
    if (_imageURLString) {
        NSData *cityImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageURLString]];
        UIImage *cityImage = [UIImage imageWithData:cityImageData];
        if (cityImage) {
            _cityImage = cityImage;
        }
    }
}

@end
