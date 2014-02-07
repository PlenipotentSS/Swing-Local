//
//  EventObject.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "Event.h"

@implementation Event

#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder  {
    _eventTitle = [aDecoder decodeObjectForKey:@"eventTitle"];
    _cost = [aDecoder decodeObjectForKey:@"cost"];
    _ages = [aDecoder decodeObjectForKey:@"ages"];
    _infoText = [aDecoder decodeObjectForKey:@"infoText"];
    _imageURLString = [aDecoder decodeObjectForKey:@"imageURLString"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.eventTitle forKey:@"eventTitle"];
    [aCoder encodeObject:self.cost forKey:@"cost"];
    [aCoder encodeObject:self.ages forKey:@"ages"];
    [aCoder encodeObject:self.infoText forKey:@"infoText"];
    [aCoder encodeObject:self.imageURLString forKey:@"imageURLString"];
}

#pragma mark - download methods
-(void) downloadEventImage {
    if (_imageURLString) {
        NSData *eventImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageURLString]];
        UIImage *eventImage = [UIImage imageWithData:eventImageData];
        if (eventImage) {
            _eventImage = eventImage;
        }
    }
}

#pragma mark - Conversion methods
+(NSMutableArray*) convertDataToEventModel:(NSArray*) eventData {
    NSMutableArray *events = [NSMutableArray new];
    for (NSDictionary *event in eventData) {
        Event *thisEvent = [Event new];
        thisEvent.eventTitle = [event objectForKey:@"title"];
        thisEvent.cost = [event objectForKey:@"cost"];
        thisEvent.ages = [event objectForKey:@"ages"];
        thisEvent.infoText = [event objectForKey:@"info_text"];
        
        if ([event objectForKey:@"event_image_url"]) {
            thisEvent.imageURLString = [event objectForKey:@"event_image_url"];
        }
        
        [events addObject:thisEvent];
    }
    
    return events;
}

#pragma mark - sort occurrences by date
-(void) sortOccurrences {
    
}

@end
