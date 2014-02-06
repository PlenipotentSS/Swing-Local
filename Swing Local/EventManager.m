//
//  EventManager.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "EventManager.h"

#define URL_TO_CITIES @"http://swinglocal.herokuapp.com/cities.json"
#define BASE_URL_TO_CITY @"http://swinglocal.herokuapp.com/cities"

@interface EventManager() <NSURLSessionDelegate>

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSOperationQueue *eventDownloadQueue;
@property (nonatomic) __block NSInteger counter;

@end

@implementation EventManager

+(EventManager*) sharedManager {
    static dispatch_once_t pred;
    static EventManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[EventManager alloc] init];
        if (!shared.eventDownloadQueue) {
            [shared setup];
        }
    });
    
    return shared;
}

#pragma mark - Setup methods
-(void) setup {
    _savedCities = [NSMutableArray new];
    _counter = 0;
    _eventDownloadQueue = [NSOperationQueue new];
    
    _allCities = [NSArray new];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.0; sessionConfig.timeoutIntervalForResource = 60.0; sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:_eventDownloadQueue];
}

#pragma mark - data persistence for saved cities
-(void) persistAndNotifySavedCities{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SavedCitiesUpdated" object:nil];
    }];
    [self encodeSavedCities];
}

-(void) encodeSavedCities {
    NSURL *archiveURL = [[self documentDir] URLByAppendingPathComponent:SAVED_CITY_ARCHIVE_NAME];
    [NSKeyedArchiver archiveRootObject:[EventManager sharedManager].savedCities toFile:[archiveURL path]];
}

-(NSURL *)documentDir {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void) updateDataWithNewCityArray:(NSArray*) downloadedCities {
    NSMutableArray *newSavedCities = [[NSMutableArray alloc] init];
    for (City *oldSavedCity in self.savedCities) {
        for (City *newCity in downloadedCities) {
            if ([oldSavedCity.cityName isEqualToString:newCity.cityName]) {
                [newSavedCities addObject:newCity];
                break;
            }
        }
    }
    self.savedCities = newSavedCities;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self persistAndNotifySavedCities];
    }];
}

#pragma mark - download event methods
-(void) downloadCities {
    NSURLSessionDataTask *citiesTask = [_urlSession  dataTaskWithURL:[NSURL URLWithString:URL_TO_CITIES] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *err;
            NSArray *cities = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            if (!err) {
                
                NSArray *citiesUnsorted = [self convertDataToCityModel:cities];
                NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityName" ascending:YES];
                NSArray *sortDescriptors = @[nameDescriptor];
                NSArray *sortedCities = [citiesUnsorted sortedArrayUsingDescriptors:sortDescriptors];
                if ([self.savedCities count] > 0) {
                    [self updateDataWithNewCityArray:sortedCities];
                }
                self.allCities = sortedCities;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AllCitiesUpdated" object:nil];
                }];
            } else {
                NSLog(@"error json: %@",err);
            }
        } else {
            
            NSLog(@"error domain: %@",error);
        }
    }];
    
    [citiesTask resume];
}

-(void) downloadVenuesAndEventsInCity:(City*) city {
    NSString *urlStringToVenues = [NSString stringWithFormat:@"%@/%i.json",BASE_URL_TO_CITY,(int)city.cityID];
    NSURLSessionDataTask *venuesTask = [_urlSession  dataTaskWithURL:[NSURL URLWithString:urlStringToVenues] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *err;
            NSDictionary *cityDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            if (!err) {
                NSArray *venuesForCity = [cityDictionary objectForKey:@"venues"];
                city.venueOrganizations = [self convertDataToVenueModel:venuesForCity];
                if ([_savedCities count] ==0) {
                    [_savedCities addObject:city];
                    [self persistAndNotifySavedCities];
                }
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.cityDelegate refreshEventTableWithCity:city];
                }];
            } else {
                NSLog(@"error json: %@",err);
            }
        } else {
            
            NSLog(@"error domain: %@",error);
        }
    }];

    [venuesTask resume];
}

#pragma mark - Conversion methods
-(NSMutableArray*) convertDataToVenueModel:(NSArray*) venueData {
    NSMutableArray *venues = [NSMutableArray new];
    for (NSDictionary *venue in venueData) {
        Venue *thisVenue = [Venue new];
        thisVenue.venueTitle = [venue objectForKey:@"title"];
        thisVenue.venueID = [[venue objectForKey:@"id"] integerValue];
        
        thisVenue.events = [self convertDataToEventModel:[venue objectForKey:@"events"]];
        [venues addObject:thisVenue];
    }
    
    return venues;
}

-(NSMutableArray*) convertDataToEventModel:(NSArray*) eventData {
    NSMutableArray *events = [NSMutableArray new];
    for (NSDictionary *event in eventData) {
        Event *thisEvent = [Event new];
        thisEvent.eventTitle = [event objectForKey:@"title"];
        thisEvent.cost = [event objectForKey:@"cost"];
        thisEvent.ages = [event objectForKey:@"ages"];
        thisEvent.DJ = [event objectForKey:@"dj"];
        thisEvent.infoText = [event objectForKey:@"info_text"];
        
        
        [events addObject:thisEvent];
    }
    
    return events;
}

-(NSArray*) convertDataToCityModel:(NSArray*)cityData {
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    for (NSDictionary *city in cityData) {
        City *thisCity = [City new];
        thisCity.cityName = [city objectForKey:@"name"];
        thisCity.cityID = [[city objectForKey:@"id"] integerValue];
        
        
        [modelArray addObject:thisCity];
    }
    return [NSArray arrayWithArray:modelArray];
}

@end
