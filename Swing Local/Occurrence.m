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
    
    if ([occurrenceData objectForKey:@"gd$where"] && [(NSArray*)[occurrenceData objectForKey:@"gd$where"] count] > 0 ) {
    NSString *where = [(NSDictionary*)[(NSArray*)[occurrenceData objectForKey:@"gd$where"] objectAtIndex:0] objectForKey:@"valueString"];
    thisOccurrence.address = where;
    }
    
    NSString *unfilteredContent = [[occurrenceData objectForKey:@"content"] objectForKey:@"$t"];
    NSMutableDictionary *attributeData = [Occurrence convertEmbeddedDataToDictionaryWithText:unfilteredContent];
    
    thisOccurrence.updatedInfoText = [occurrenceData objectForKey:@"text"];
    thisOccurrence.updatedTitle = [[occurrenceData objectForKey:@"title"] objectForKey:@"$t"];
    
    thisOccurrence.updatedCost = [attributeData objectForKey:@"cost"];
    thisOccurrence.music = [attributeData objectForKey:@"music"];
    thisOccurrence.updatedInfoText = [attributeData objectForKey:@"text"];
    
    return thisOccurrence;
}

+(NSMutableDictionary*) convertEmbeddedDataToDictionaryWithText: (NSString*) content {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    //parse through content
    NSError *error;
    NSRegularExpression *shortcodes = [NSRegularExpression regularExpressionWithPattern:@"(::.*::)+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [shortcodes matchesInString:content
                                           options:0
                                             range:NSMakeRange(0, [content length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSString *thisShortcode = [content substringWithRange:matchRange];
        thisShortcode = [thisShortcode stringByReplacingOccurrencesOfString:@"::" withString:@""];
        NSArray *thisKeyedEntry = [thisShortcode componentsSeparatedByString:@":"];
        NSString *thisKey =[[thisKeyedEntry objectAtIndex:0] lowercaseString];
        thisKey = [thisKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([ thisKey isEqualToString:@"cost" ]) {
            NSMutableArray *contentArray = [NSMutableArray arrayWithArray:thisKeyedEntry];
            [contentArray removeObjectAtIndex:0];
            NSString *thisValue =  [[contentArray valueForKey:@"description"] componentsJoinedByString:@":"];
            thisValue = [thisValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [attributes setObject:thisValue forKey:@"cost"];
        }
        if ([ thisKey isEqualToString:@"dj" ] || [ thisKey isEqualToString:@"music" ] || [ thisKey isEqualToString:@"band" ]) {
            NSMutableArray *contentArray = [NSMutableArray arrayWithArray:thisKeyedEntry];
            [contentArray removeObjectAtIndex:0];
            NSString *thisValue =  [[contentArray valueForKey:@"description"] componentsJoinedByString:@":"];
            thisValue = [thisValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [attributes setObject:thisValue forKey:@"music"];
        }
    }
    //remove matched shortcodes
    NSString *filteredContent = [content copy];
    filteredContent = [shortcodes stringByReplacingMatchesInString:filteredContent options:0 range:NSMakeRange(0, [filteredContent length]) withTemplate:@""];

    NSRegularExpression *multipleLines = [NSRegularExpression regularExpressionWithPattern:@"(\n|\r){3,}" options:NSRegularExpressionCaseInsensitive error:&error];
    filteredContent = [multipleLines stringByReplacingMatchesInString:filteredContent  options:0 range:NSMakeRange(0, [filteredContent length]) withTemplate:@""];
    
    if (!error) {
        //change to remove tags
        [attributes setObject:filteredContent forKey:@"text"];
    } else {
        NSLog(@"%@",error);
        [attributes setObject:content forKey:@"text"];
    }
    return attributes;
}

@end