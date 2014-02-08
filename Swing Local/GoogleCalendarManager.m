//
//  GoogleCalendarManager.m
//  Swing Local
//
//  Created by Stevenson on 2/5/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "GoogleCalendarManager.h"
#import "Occurrence.h"
#import "NSDate+SwingLocal.h"

@interface GoogleCalendarManager() <NSURLSessionDelegate>

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSOperationQueue *googleDownloadQueue;

@end

// Keychain item name for saving the user's authentication information
NSString *const kKeychainItemName = @"CalendarSwingLocal: Swing Local Calendar";

@implementation GoogleCalendarManager

+(GoogleCalendarManager*) sharedManager
{
    static dispatch_once_t pred;
    static GoogleCalendarManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[GoogleCalendarManager alloc] init];
        if (!shared.googleDownloadQueue) {
            [shared setup];
        }
    });
    
    return shared;
}

#pragma mark - Setup methods
-(void) setup {
    _googleDownloadQueue = [NSOperationQueue new];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.0; sessionConfig.timeoutIntervalForResource = 60.0; sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:self.googleDownloadQueue];
}

-(NSURL*) getGoogleCalURLFromID: (NSString*) googleCalID {
    NSString *googleStringURL = [NSString stringWithFormat:@"%@%@%@",GOOGLE_BASE,googleCalID,GOOGLE_VARS];
    return [NSURL URLWithString:googleStringURL];
}

#pragma mark - compararing dates
-(NSArray*) getTodaysDate {
    NSDate *now = [NSDate date];
    return @[now];
}

#pragma mark - Google API Downloads
-(void) getTodaysOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event *)theEvent {
    [self getOccurrencesWithGoogleCalendarID:googleCalID forEvent:theEvent andForDateRange:[self getTodaysDate]];
}

-(void) getOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event *)theEvent andForDateRange: (NSArray*) dates {
    NSURL *googleCalURL = [self getGoogleCalURLFromID:googleCalID];
    NSURLSessionDataTask *eventsTasks = [_urlSession  dataTaskWithURL:googleCalURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *err;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            if (!err && ![jsonObject isKindOfClass:[NSString class]]) {
                NSDictionary *googleCalData = (NSDictionary*)jsonObject;
                
                NSArray *allOccurrences = [(NSDictionary*)[googleCalData objectForKey:@"feed"] objectForKey:@"entry"];
                
                //return all Events in the given date range for venue
                NSMutableArray *filteredMutableArray = [self filterOccurrencesFromAllOccurrences:allOccurrences forDates:dates];
                
                for (Occurrence *occ in filteredMutableArray) {
                    occ.eventForOccurrence = theEvent;
                }
                theEvent.occurrences = [NSArray arrayWithArray:filteredMutableArray];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate updateVenueForEvent:theEvent];
                }];
                
            } else {
                NSLog(@"error json: %@ : %@",err,jsonObject);
            }
        } else {
            
            NSLog(@"error domain: %@",error);
        }
    }];
    [eventsTasks resume];
}

#pragma mark - get events in time range
-(NSMutableArray*) filterOccurrencesFromAllOccurrences: (NSArray*) allOccurrences forDates:(NSArray*) datesArray {
    NSMutableArray *filteredEventsByDates = [NSMutableArray new];
    
    //yyyy-MM-dd'T'HH:mm:ssZ
    NSDateFormatter *googleFormat = [[NSDateFormatter alloc] init];
    [googleFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSzzz"];
    
    //loop through all events in this calendar
    for (NSDictionary *thisOccData in allOccurrences) {
        NSArray *whenData = [thisOccData objectForKey:@"gd$when"];
        

        //go through all dates given for comparison
        for (NSDate *compareDate in datesArray) {
            
            BOOL continueFlag = YES;
            BOOL isALLDay = NO;
            if (continueFlag) {
            
                //loop through all times in this calendar
                for (NSDictionary *thisTime in whenData) {

                        
                    //check if the we are checking for dates that have yet to occur
                    NSDate* eventDate = [googleFormat dateFromString:[thisTime objectForKey:@"startTime"]];
                    if (!eventDate) {
                        NSDateFormatter *allDayFormat = [[NSDateFormatter alloc] init];
                        [allDayFormat setDateFormat:@"yyyy-MM-dd"];
                        eventDate = [allDayFormat dateFromString:[thisTime objectForKey:@"startTime"]];
                        if (!eventDate) {
                            continue;
                        } else {
                            isALLDay = YES;
                        }
                    }
                    
                    //NSLog(@"%@  :  %@",eventDate,compareDate);
                    if ([NSDate dateA:eventDate isBeforeDateB:compareDate]) {
                        
                        
                        //check if the two dates are the same
                        if ( [NSDate dateA:eventDate isSameDayAsDateB:compareDate] ) {
                            NSDate* endTime;
                            if (isALLDay) {
                                NSDateFormatter *allDayFormat = [[NSDateFormatter alloc] init];
                                [allDayFormat setDateFormat:@"yyyy-MM-dd"];
                                eventDate = [allDayFormat dateFromString:[thisTime objectForKey:@"startTime"]];
                            } else {
                                endTime = [googleFormat dateFromString:[thisTime objectForKey:@"endTime"]];
                            }
                            
                            Occurrence *thisOcc = [Occurrence convertDataToOccurrenceModel:thisOccData withStartTime:eventDate andEndTime:endTime];
                            [filteredEventsByDates addObject:thisOcc];
                            break;
                        }
                    } else {
                        continueFlag = NO;
                        break;
                    }
                }
                
            } else {
                continueFlag = NO;
                break;
            }

        }
    }
    return filteredEventsByDates;
}

@end
