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

@interface GoogleCalendarManager() <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic) NSInteger APIcallCount;
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSOperationQueue *googleDownloadQueue;
@property (nonatomic) NSURLSessionDataTask *eventsTasks;
@property (nonatomic) NSMutableArray *eventsDownloading;

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
    self.APIcallCount = 0;
    if( NSClassFromString(@"NSURLSession") != nil) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            
        [sessionConfig setRequestCachePolicy:NSURLCacheStorageAllowed];
        [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
        sessionConfig.timeoutIntervalForRequest = 10.0; sessionConfig.timeoutIntervalForResource = 30.0;
        //sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:self.googleDownloadQueue];
    } else {
        //NSLog(@"setuping up google calendars for iOS 6");
    }
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

-(void) cancelAllDownloadJobs {
    
    if( NSClassFromString(@"NSURLSession") != nil) {
        [self.urlSession invalidateAndCancel];

        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
        sessionConfig.timeoutIntervalForRequest = 30.0; sessionConfig.timeoutIntervalForResource = 60.0; sessionConfig.HTTPMaximumConnectionsPerHost = 1;

        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:self.googleDownloadQueue];
    } else {
        //NSLog(@"attempting to cancel all downloads with iOS6");
        [self.googleDownloadQueue cancelAllOperations];
    }
}

-(void) getTodaysOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event *)theEvent {
    [self getOccurrencesWithGoogleCalendarID:googleCalID forEvent:theEvent andForDateRange:[self getTodaysDate]];
}

-(void) getOccurrencesWithGoogleCalendarID: (NSString*) googleCalID forEvent:(Event *)theEvent andForDateRange: (NSArray*) dates {
    self.APIcallCount++;
    NSLog(@"%i",(int)self.APIcallCount);
    if( NSClassFromString(@"NSURLSession") != nil) {
        NSURL *googleCalURL = [self getGoogleCalURLFromID:googleCalID];
        self.eventsTasks = [self.urlSession  dataTaskWithURL:googleCalURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSError *err;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                if (!err && ![jsonObject isKindOfClass:[NSString class]]) {
                    NSDictionary *googleCalData = (NSDictionary*)jsonObject;
                    
                    NSArray *allOccurrences = [(NSDictionary*)[googleCalData objectForKey:@"feed"] objectForKey:@"entry"];
                    
                    //return all Events in the given date range for venue
                    NSMutableArray *filteredMutableArray = [self filterOccurrencesFromAllOccurrences:allOccurrences forDates:dates];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        for (Occurrence *occ in filteredMutableArray) {
                            occ.eventForOccurrence = theEvent;
                        }
                        theEvent.occurrences = [NSArray arrayWithArray:filteredMutableArray];
                        [self.delegate updateVenueForEvent:theEvent];
                        [self.delegate doneDownloadingOccurrences];
                    }];
                    
                } else {
                    NSLog(@"error json google: %@ : %@",err,jsonObject);
                }
            } else {
                
                NSLog(@"error domain google: %@",error);
            }
        }];
        [self.eventsTasks resume];
    } else {
        [self.googleDownloadQueue addOperationWithBlock:^{
            //NSLog(@"Attempting to load google calendars on iOS6");
            NSString *strResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[self getGoogleCalURLFromID:googleCalID]] encoding:NSUTF8StringEncoding];
            if ( ![strResult length] == 0 ) {
                NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONReadingMutableContainers error:&err];
                if (!err && ![jsonObject isKindOfClass:[NSString class]]) {
                    NSDictionary *googleCalData = (NSDictionary*)jsonObject;
                    
                    NSArray *allOccurrences = [(NSDictionary*)[googleCalData objectForKey:@"feed"] objectForKey:@"entry"];
                    
                    //return all Events in the given date range for venue
                    NSMutableArray *filteredMutableArray = [self filterOccurrencesFromAllOccurrences:allOccurrences forDates:dates];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        for (Occurrence *occ in filteredMutableArray) {
                            occ.eventForOccurrence = theEvent;
                        }
                        theEvent.occurrences = [NSArray arrayWithArray:filteredMutableArray];
                        [self.delegate updateVenueForEvent:theEvent];
                        [self.delegate doneDownloadingOccurrences];
                    }];
                    
                } else {
                    NSLog(@"error json google: %@ : %@",err,jsonObject);
                }
            }
        }];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
    NSLog(@"session: %@",session);
    NSLog(@"datatask: %@",dataTask);
    NSLog(@"willcacheresponse: %@",proposedResponse);
    
    completionHandler(proposedResponse);
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
            BOOL isALLDay = NO;
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
                }
            }
        }
    }
    return filteredEventsByDates;
}

@end
