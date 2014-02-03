//
//  Venue.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueOrganization : NSObject <NSCoding>

//list of all events in this venue/organization
@property (nonatomic) NSMutableArray *events;

//Venue Manager Or organization of event
@property (nonatomic) NSString *venue;

//website to venue
@property (nonatomic) NSString *website;


@end
