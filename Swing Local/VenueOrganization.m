//
//  Venue.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "VenueOrganization.h"

@implementation VenueOrganization


#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _events = [aDecoder decodeObjectForKey:@"events"];
    _venue =[aDecoder decodeObjectForKey:@"venue"];
    _website = [aDecoder decodeObjectForKey:@"website"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.events forKey:@"events"];
    [aCoder encodeObject:self.venue forKey:@"venue"];
    [aCoder encodeObject:self.website forKey:@"website"];
}

@end
