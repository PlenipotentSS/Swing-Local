//
//  EventsTableViewModel.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "EventsTableViewModel.h"
#import "UIColor+SwingLocal.h"
#import "EventManager.h"
#import "Venue.h"
#import "Event.h"
#import "GoogleCalendarManager.h"

@interface EventsTableViewModel() <EventManagerCityDelegate, GoogleCalendarManagerDelegate>

//all occurrences found
@property (nonatomic) NSMutableArray *occurrencesOfEvents;

//operation queue for cell row animations
@property (nonatomic) NSOperationQueue *cellOperationQueue;

//operation queue for cell row animations
@property (nonatomic) NSOperationQueue *headerOperationQueue;

//list of all occurrence dates for each event in venues
@property (nonatomic) NSMutableArray *datesWithEvents;

//dictionary with keys being the dates of occurrences
@property (nonatomic) NSMutableDictionary *occurrencesForDateKeys;

//sorted dates that contain occurrences
@property (nonatomic) NSMutableArray *sortedDateKeys;

//current download count
@property (nonatomic) NSInteger eventDownloadCount;

//current download count
@property (nonatomic) NSInteger totalEventCount;

@property (nonatomic) BOOL occurrencesFound;

@end

@implementation EventsTableViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _cellOperationQueue = [NSOperationQueue new];
        [self.cellOperationQueue setMaxConcurrentOperationCount:1];
        _headerOperationQueue = [NSOperationQueue new];
        [self.headerOperationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void) setCityWithName:(NSString *)cityName {
    NSArray *allCities = [[EventManager sharedManager] allCities];
    for (City *thisCity in allCities) {
        if (thisCity.cityName && [thisCity.cityName isEqualToString:cityName]) {
            [self setCity:thisCity];
            break;
        }
    }
}

#pragma mark - add City and updata Data methods
-(void) setCity:(City *)city {
    _city = city;
    
    _occurrencesForDateKeys = [NSMutableDictionary new];
    _datesWithEvents = [NSMutableArray new];
    _sortedDateKeys = [NSMutableArray new];
    _occurrencesForDateKeys = [NSMutableDictionary new];
    _occurrencesOfEvents = [NSMutableArray new];
    self.totalEventCount = 0;
    self.eventDownloadCount = 0;
    self.occurrencesFound = YES;
    
    [[GoogleCalendarManager sharedManager] cancelAllDownloadJobs];
    [self refreshEventTableWithCity:city];


}

-(void) setCities:(NSArray *)cities {
    _cities = cities;
    
    _occurrencesForDateKeys = [NSMutableDictionary new];
    _datesWithEvents = [NSMutableArray new];
    _sortedDateKeys = [NSMutableArray new];
    _occurrencesForDateKeys = [NSMutableDictionary new];
    _occurrencesOfEvents = [NSMutableArray new];
    self.totalEventCount = 0;
    self.eventDownloadCount = 0;
    self.occurrencesFound = YES;
    
    [[GoogleCalendarManager sharedManager] cancelAllDownloadJobs];
    for (City *thisCity in cities) {
        [self refreshEventTableWithCity:thisCity];
    }
}

#pragma mark rebuild table view given the current city
//called initially to load, and again when download venues completes
-(void) refreshEventTableWithCity: (City*) thisCity {\
    if (thisCity.venueOrganizations) {
        [[GoogleCalendarManager sharedManager] setDelegate:self];
        [self loadEventsForVenuesInCity:thisCity];
    } else {
        [[EventManager sharedManager] setCityDelegate:self];
        [[EventManager sharedManager] downloadVenuesAndEventsInCity:thisCity];
    }
}


#pragma mark get events for all events in venue
//send events for each venue to see if there is an event today
-(void) loadEventsForVenuesInCity:(City*)thisCity {
    for (Venue *thisVenue in thisCity.venueOrganizations) {
        //change to get get events for this day in venue
        [self eventsTodayForVenue:thisVenue];
    }
}

#pragma mark download occurrences for events
//send to google manager for json data
-(void) eventsTodayForVenue:(Venue*) thisVenue {
    for (Event *thisEvent in thisVenue.events) {
        NSString *calendarURLString = thisEvent.calendar_id;
        
        if (![calendarURLString isKindOfClass:[NSNull class]] && calendarURLString && ![calendarURLString isEqualToString:@""]) {
            self.eventDownloadCount++;
            self.totalEventCount++;
            if (self.datesToSearch && [self.datesToSearch count] > 0) {
                [[GoogleCalendarManager sharedManager] getOccurrencesWithGoogleCalendarID:calendarURLString forEvent:thisEvent andForDateRange:self.datesToSearch];
            } else {
                [[GoogleCalendarManager sharedManager] getTodaysOccurrencesWithGoogleCalendarID:calendarURLString forEvent:thisEvent];
            }
        }
    }
}

#pragma mark build table view with downloaded google occurrences
//receive from google manager: an array of events today
-(void) updateVenueForEvent:(Event*) thisEvent {
    //give delay for cell animations
    for (Occurrence *occ in thisEvent.occurrences) {
        [self.occurrencesOfEvents addObject:occ];
    }
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSArray *sortDescriptors = @[dateDescriptor];
    NSArray *sortedOccurrencesOfEvents = [self.occurrencesOfEvents sortedArrayUsingDescriptors:sortDescriptors];
    
    for (Occurrence *thisOcc in sortedOccurrencesOfEvents) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:SIMPLE_DATE_FORMAT];
        NSString *startDate = [dateFormatter stringFromDate:thisOcc.startTime];
        
        NSMutableArray *thisDateArray;
        if ([self.occurrencesForDateKeys objectForKey:startDate]) {
            thisDateArray = [self.occurrencesForDateKeys objectForKey:startDate];
            if (![thisDateArray containsObject:thisOcc]) {
                [thisDateArray addObject:thisOcc];
            }
        } else {
            thisDateArray = [NSMutableArray new];
            [thisDateArray addObject:thisOcc];
        }
        
        [self.occurrencesForDateKeys setValue:thisDateArray forKey:[NSString stringWithFormat:@"%@",startDate]];
        if (![self.sortedDateKeys containsObject:startDate]) {
            [self.sortedDateKeys addObject:startDate];
        }
        [self.delegate updateMapPinForOccurrence:thisOcc];
    }
    [self sortDateKeys];
}

-(void) doneDownloadingOccurrences
{
    self.eventDownloadCount--;
    CGFloat progress = ((float)self.totalEventCount-(float)self.eventDownloadCount)/(float)self.totalEventCount;
    [self.delegate updateProgress:progress];
    if (self.eventDownloadCount == 0) {
        if ([self.sortedDateKeys count] == 0) {
            self.occurrencesFound = NO;
        }
        [self.theTableView reloadData];
        [self.theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [self.delegate doneSearching];
    }
}

-(void) sortDateKeys {
    NSArray *sortedKeys = [self.sortedDateKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:SIMPLE_DATE_FORMAT];
        NSDate *date1 = [dateFormatter dateFromString:obj1];
        NSDate *date2 = [dateFormatter dateFromString:obj2];
        return [date1 compare:date2];
    }];
    
    self.sortedDateKeys = [NSMutableArray arrayWithArray:sortedKeys];
}


#pragma mark - UITableViewDataSource and Delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [_theTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.section < [self.sortedDateKeys count]) {
        NSString *keyName = [self.sortedDateKeys objectAtIndex:indexPath.section];
        NSArray *eventsOnDay = [self.occurrencesForDateKeys objectForKey:keyName];
        if (indexPath.row < [eventsOnDay count]) {
            Occurrence *thisOcc = [eventsOnDay objectAtIndex:indexPath.row];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowDetailViewController" object:nil userInfo:@{@"occurrence" : thisOcc}];
        }
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sortedDateKeys && [self.sortedDateKeys count] > 0) {
        return [self.sortedDateKeys count];
    } else if (!self.occurrencesFound) {
        return 1;
    } else {
        return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.datesToSearch && [self.datesToSearch count] >0 && section < [self.sortedDateKeys count]) {
        return [self.sortedDateKeys objectAtIndex:section];
    } else if (self.datesToSearch && [self.datesToSearch count] >0) {
        return @"";
    } else {
        return @"Today";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.sortedDateKeys count] == 0 && self.city) {
        return 1;
    } else if (section < [self.sortedDateKeys count]) {
        NSString *keyName = [self.sortedDateKeys objectAtIndex:section];
        return [[self.occurrencesForDateKeys objectForKey:keyName] count];
    } else {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sortedDateKeys count] == 0) {
        
        NSString *cellIdentifier = @"noEventsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell.contentView setAlpha:0.f];
        return cell;        
    }
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *keyName = [self.sortedDateKeys objectAtIndex:indexPath.section];
    NSArray *eventsOnDay = [self.occurrencesForDateKeys objectForKey:keyName];
    
    Occurrence *thisOcc = [eventsOnDay objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisOcc.updatedTitle;
    cell.textLabel.textColor = [UIColor offWhiteScheme];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GENERAL_TIME_FORMAT];
    NSString *startTime = [dateFormatter stringFromDate:thisOcc.startTime];
    NSString *endTime = [dateFormatter stringFromDate:thisOcc.endTime];
    
    NSString *dj = @"";
    if (thisOcc.music && ![thisOcc.music isEqualToString:@""]) {
        dj = [NSString stringWithFormat:@": %@",thisOcc.music];
    }
    
    NSString *subtitle = [NSString stringWithFormat:@"%@-%@ %@",startTime,endTime, dj];
    cell.detailTextLabel.text = subtitle;
    cell.detailTextLabel.textColor = [UIColor offWhiteScheme];
    
    //if device can handle animations!
    [cell.contentView setAlpha:0.f];
    //end
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self animateCell:cell];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.contentView.backgroundColor = [UIColor burntScheme];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor burntScheme];
        
        //if device can handle animations!
        [self animateHeaderView:tableViewHeaderFooterView];
        tableViewHeaderFooterView.contentView.backgroundColor = [UIColor burntScheme];
        //else
        //tableViewHeaderFooterView.contentView.backgroundColor = [UIColor offwhiteScheme];
        //end
    }
}

#pragma mark - animation for cells
-(void) animateCell: (UITableViewCell*) cell
{
    [self.cellOperationQueue addOperationWithBlock:^{
        usleep(25000);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [UIView animateWithDuration:.4f animations:^{
                [cell.contentView setAlpha:1.f];
            }];
        }];
    }];
    CATransform3D transform3d = CATransform3DMakeScale(1.15, 1.15, 1.15);
    cell.layer.transform = transform3d;
    [self.cellOperationQueue addOperationWithBlock:^{
        usleep(40000);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [UIView animateWithDuration:.4f animations:^{
                cell.layer.transform = CATransform3DIdentity;
            }];
        }];
    }];

}

-(void) animateHeaderView: (UITableViewHeaderFooterView*) view
{
    [self.cellOperationQueue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            usleep(25000);
            [UIView animateWithDuration:.4f animations:^{
                [[view contentView] setBackgroundColor:[UIColor offWhiteScheme]];
            }];
        }];
    }];
}

@end
