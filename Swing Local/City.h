//
//  CityEvents.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject <NSCoding>

//array of all venueOrganizations within this city
@property (nonatomic) NSMutableArray *venueOrganizations;

//name of this city
@property (nonatomic) NSString *cityName;

//country containing this city
@property (nonatomic) NSString *country;

//string of url to image for this city
@property (nonatomic) NSString *imageURLString;

//image representing this city
@property (nonatomic) UIImage *cityImage;

//reference id for this city
@property (nonatomic) NSInteger cityID;

//whether this city is saved in users
@property (nonatomic,readwrite) BOOL savedCity;

+(NSArray*) convertDataToCityModel:(NSArray*)cityData;

@end
