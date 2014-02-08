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
#import "Occurrence.h"

@interface EventsTableViewModel() <EventManagerCityDelegate, GoogleCalendarManagerDelegate>

//all occurrences found
@property (nonatomic) NSMutableArray *occurrencesOfEvents;

//operation queue for cell row animations
@property (nonatomic) NSOperationQueue *cellOperationQueue;

//list of all occurrence dates for each event in venues
@property (nonatomic) NSMutableArray *datesWithEvents;

//dictionary with keys being the dates of occurrences
@property (nonatomic) NSMutableDictionary *OccurrencesWithDateKeys;

//sorted dates that contain occurrences
@property (nonatomic) NSMutableArray *sortedDateKeys;

@end

@implementation EventsTableViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _cellOperationQueue = [NSOperationQueue new];
        [_cellOperationQueue setMaxConcurrentOperationCount:1];
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
    
    _OccurrencesWithDateKeys = [NSMutableDictionary new];
    
    _sortedDateKeys = [NSMutableArray new];
    _occurrencesOfEvents = [NSMutableArray new];
    [self refreshEventTableWithCity:city];

}

#pragma mark rebuild table view given the current city
//called initially to load, and again when download venues completes
-(void) refreshEventTableWithCity: (City*) thisCity {
    if (self.city.venueOrganizations) {
        [[GoogleCalendarManager sharedManager] setDelegate:self];
        [self.cellOperationQueue addOperationWithBlock:^{
            usleep(500000);
        }];
        [self loadEventsForVenues];
    } else {
        [[EventManager sharedManager] setCityDelegate:self];
        [[EventManager sharedManager] downloadVenuesAndEventsInCity:thisCity];
    }
}


#pragma mark get events for all events in venue
//send events for each venue to see if there is an event today
-(void) loadEventsForVenues {
    for (Venue *thisVenue in self.city.venueOrganizations) {
        //change to get get events for this day in venue
        [self eventsTodayForVenue:thisVenue];
    }
}

#pragma mark download occurrences for events
//send to google manager for json data
-(void) eventsTodayForVenue:(Venue*) thisVenue {
    for (Event *thisEvent in thisVenue.events) {
        
        
        NSString *calendarURLString = thisEvent.calendar_id;             //change imageURLSTring
        
        
        if (![calendarURLString isKindOfClass:[NSNull class]] && calendarURLString && ![calendarURLString isEqualToString:@""]) {
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
        if ([self.OccurrencesWithDateKeys objectForKey:startDate]) {
            thisDateArray = [self.OccurrencesWithDateKeys objectForKey:startDate];
            [thisDateArray addObject:thisOcc];
        } else {
            thisDateArray = [NSMutableArray new];
            [thisDateArray addObject:thisOcc];
        }
        
        [self.OccurrencesWithDateKeys setValue:thisDateArray forKey:[NSString stringWithFormat:@"%@",startDate]];
        if (![self.sortedDateKeys containsObject:startDate]) {
            [self.sortedDateKeys addObject:startDate];
        }

    }
    
    [self.theTableView reloadData];
    [self.theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}


#pragma mark - UITableViewDataSource and Delegate methods
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.contentView.backgroundColor = [UIColor offWhiteScheme];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor burntScheme];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [_theTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.section < [self.sortedDateKeys count]) {
        NSString *keyName = [self.sortedDateKeys objectAtIndex:indexPath.section];
        NSArray *eventsOnDay = [self.OccurrencesWithDateKeys objectForKey:keyName];
        if (indexPath.row < [eventsOnDay count]) {
            Occurrence *thisOcc = [eventsOnDay objectAtIndex:indexPath.row];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowDetailViewController" object:nil userInfo:@{@"occurrence" : thisOcc}];
        }
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sortedDateKeys && [self.sortedDateKeys count] > 0) {
        return [self.sortedDateKeys count];
    } else if (self.city) {
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
        return [[self.OccurrencesWithDateKeys objectForKey:keyName] count];
    } else {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sortedDateKeys count] == 0) {
        
        NSString *cellIdentifier = @"noEventsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell.contentView setAlpha:0.f];
        [self animateCell:cell AtIndex:indexPath];
        return cell;        
    }
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *keyName = [self.sortedDateKeys objectAtIndex:indexPath.section];
    NSArray *eventsOnDay = [self.OccurrencesWithDateKeys objectForKey:keyName];
    
    Occurrence *thisOcc = [eventsOnDay objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisOcc.updatedTitle;
    cell.textLabel.textColor = [UIColor offWhiteScheme];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GENERAL_TIME_FORMAT];
    NSString *startTime = [dateFormatter stringFromDate:thisOcc.startTime];
    NSString *endTime = [dateFormatter stringFromDate:thisOcc.endTime];
    
    NSString *cost = @"$";
    if (thisOcc.updatedCost) {
        cost = [NSString stringWithFormat:@"%@%@",cost,thisOcc.updatedCost];
    } else if (thisOcc.eventForOccurrence.cost && ![thisOcc.eventForOccurrence.cost isEqualToString:@""]) {
        cost = [NSString stringWithFormat:@"%@%@",cost,thisOcc.eventForOccurrence.cost];
    } else {
        cost = @"";
    }
    
    NSString *dj = @"";
    if (thisOcc.DJ && ![thisOcc.DJ isEqualToString:@""]) {
        dj = [NSString stringWithFormat:@" - %@",thisOcc.DJ];
    }
    
    NSString *subtitle = [NSString stringWithFormat:@"%@-%@ : %@ %@",startTime,endTime, cost, dj];
    cell.detailTextLabel.text = subtitle;
    cell.detailTextLabel.textColor = [UIColor offWhiteScheme];
    [cell.contentView setAlpha:0.f];
    
    
    [self animateCell:cell AtIndex:indexPath];
    return cell;
}

#pragma mark - animation for cells
-(void) animateCell: (UITableViewCell*) cell AtIndex: (NSIndexPath*) indexPath {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.25f, 1.25f);
        [_cellOperationQueue addOperationWithBlock:^{
            usleep(25000);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [UIView animateWithDuration:.4f animations:^{
                    [cell.contentView setAlpha:1.f];
                    cell.contentView.transform = CGAffineTransformScale(transform,.8f,.8f);
                }];
            }];
        }];

}

@end
