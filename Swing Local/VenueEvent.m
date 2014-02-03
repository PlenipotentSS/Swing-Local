//
//  EventObject.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "VenueEvent.h"

@implementation VenueEvent

-(void) downloadEventImage {
    if (self.imageURLString) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURLString]];
        UIImage *eventImage = [UIImage imageWithData:imageData];
        if (eventImage) {
            _eventImage = eventImage;
        }
    }
}

#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _eventTitle = [aDecoder decodeObjectForKey:@"eventTitle"];
    _startTime =[aDecoder decodeObjectForKey:@"startTime"];
    _endTime = [aDecoder decodeObjectForKey:@"endTime"];
    _cost = [aDecoder decodeObjectForKey:@"cost"];
    _ages = [aDecoder decodeObjectForKey:@"ages"];
    _infoText = [aDecoder decodeObjectForKey:@"infoText"];
    _DJ = [aDecoder decodeObjectForKey:@"DJ"];
    _address = [aDecoder decodeObjectForKey:@"address"];
    _imageURLString = [aDecoder decodeObjectForKey:@"imageURLString"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.eventTitle forKey:@"eventTitle"];
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.cost forKey:@"cost"];
    [aCoder encodeObject:self.ages forKey:@"ages"];
    [aCoder encodeObject:self.infoText forKey:@"infoText"];
    [aCoder encodeObject:self.DJ forKey:@"DJ"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.imageURLString forKey:@"imageURLString"];
}

@end
