//
//  Venue.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "Venue.h"

@implementation Venue


#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _events = [aDecoder decodeObjectForKey:@"events"];
    _venueTitle =[aDecoder decodeObjectForKey:@"venue"];
    _website = [aDecoder decodeObjectForKey:@"website"];
    _twitterUsername =[aDecoder decodeObjectForKey:@"twitterUsername"];
    _facebookPage = [aDecoder decodeObjectForKey:@"facebookPage"];
    _venueImageURLString = [aDecoder decodeObjectForKey:@"venueImageURLString"];
    _venueID = [[aDecoder decodeObjectForKey:@"venueID"] integerValue];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.events forKey:@"events"];
    [aCoder encodeObject:self.venueTitle forKey:@"venue"];
    [aCoder encodeObject:self.website forKey:@"website"];
    [aCoder encodeObject:self.twitterUsername forKey:@"twitterUsername"];
    [aCoder encodeObject:self.facebookPage forKey:@"facebookPage"];
    [aCoder encodeObject:self.venueImageURLString forKey:@"venueImageURLString"];
    [aCoder encodeObject:@(self.venueID) forKey:@"venueID"];
}

#pragma mark - download methods
-(void) downloadVenueImage {
    if (_venueImageURLString) {
        NSData *venueImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_venueImageURLString]];
        UIImage *venueImage = [UIImage imageWithData:venueImageData];
        if (venueImage) {
            _venueImage = venueImage;
        }
    }
}

@end
