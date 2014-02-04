//
//  Venue.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venue : NSObject <NSCoding>

//list of all events in this venue/organization
@property (nonatomic) NSMutableArray *events;

//Venue Manager Or organization of event
@property (nonatomic) NSString *venueTitle;

//website to venue
@property (nonatomic) NSString *website;

//twitter account
@property (nonatomic) NSString *twitterUsername;

//facebook page
@property (nonatomic) NSString *facebookPage;

//reference id for this venue
@property (nonatomic) NSInteger venueID;

//image url string for venue/organization
@property (nonatomic) NSString *venueImageURLString;

//image for venue/organization
@property (nonatomic) UIImage *venueImage;

//download the venue's image
-(void)downloadVenueImage;

@end
