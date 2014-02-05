//
//  UserOptions.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "UserOptions.h"

@implementation UserOptions

#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _savedCities = [aDecoder decodeObjectForKey:@"savedCities"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.savedCities forKey:@"savedCities"];
}

@end
