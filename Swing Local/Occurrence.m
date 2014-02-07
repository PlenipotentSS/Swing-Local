//
//  Occurrence.m
//  Swing Local
//
//  Created by Stevenson on 2/6/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "Occurrence.h"

@implementation Occurrence


#pragma mark - Conversion methods
//occurrence data is at the json level: entry
+(Occurrence*) convertDataToOccurrenceModel:(NSDictionary*) occurrenceData withStartTime:(NSDate*) startTime andEndTime:(NSDate*) endTime {
    Occurrence *thisOccurrence = [Occurrence new];

    thisOccurrence.startTime = startTime;
    thisOccurrence.endTime = endTime;
    
    NSString *unfilteredContent = [[occurrenceData objectForKey:@"content"] objectForKey:@"$t"];
    NSMutableDictionary *attributeData = [Occurrence convertEmbeddedDataToDictionaryWithText:unfilteredContent];
    
    
    thisOccurrence.updatedInfoText = [occurrenceData objectForKey:@"text"];
    thisOccurrence.updatedTitle = [[occurrenceData objectForKey:@"title"] objectForKey:@"$t"];
    
    thisOccurrence.DJ = [attributeData objectForKey:@"dj"];
    thisOccurrence.updatedCost = [attributeData objectForKey:@"updatedCost"];
    
    return thisOccurrence;
}

+(NSMutableDictionary*) convertEmbeddedDataToDictionaryWithText: (NSString*) content {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    //parse through content
    
    
    //change to remove tags
    [attributes setObject:content forKey:@"text"];
    
    
    return attributes;
}

@end