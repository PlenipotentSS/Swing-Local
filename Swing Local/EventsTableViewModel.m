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

@property (nonatomic) NSMutableArray *eventsInCity;
@property (nonatomic) NSMutableArray *occurrencesOfEvents;
@property (nonatomic) NSOperationQueue *cellOperationQueue;

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
        if ([thisCity.cityName isEqualToString:cityName]) {
            [self setCity:thisCity];
            break;
        }
    }
}

-(void) setCity:(City *)city {
    _city = city;
    
    [self refreshEventTableWithCity:city];

}

//called initially to load, and again when download venues completes
-(void) refreshEventTableWithCity: (City*) thisCity {
    if (self.city.venueOrganizations) {
        _eventsInCity = [NSMutableArray new];
        _occurrencesOfEvents = [NSMutableArray new];
        [self.cellOperationQueue addOperationWithBlock:^{
            usleep(500000);
        }];
        [self loadEventsForVenues];
    } else {
        [[EventManager sharedManager] setCityDelegate:self];
        [[EventManager sharedManager] downloadVenuesAndEventsInCity:thisCity];
    }
}

//send events for each venue to see if there is an event today
-(void) loadEventsForVenues {
    for (Venue *thisVenue in self.city.venueOrganizations) {
        //change to get get events for this day in venue
        [self eventsTodayForVenue:thisVenue];
    }
}

#warning CHANGE NAME TO GOOGLE URL
//send to google manager for json data
-(void) eventsTodayForVenue:(Venue*) thisVenue {
    for (Event *thisEvent in thisVenue.events) {
        
        
        NSString *calendarURLString = thisEvent.imageURLString;             //change imageURLSTring
        
        
        if (calendarURLString && ![calendarURLString isEqualToString:@""]) {
            [[GoogleCalendarManager sharedManager] getTodaysOccurrencesWithGoogleCalendarID:calendarURLString forEvent:thisEvent];
            [self.eventsInCity addObject:thisEvent];
        }
    }
}

//receive from google manager: an array of events today
-(void) updateVenueForEvent:(Event*) thisEvent {
    //give delay for cell animations
    for (Occurrence *occ in thisEvent.occurrences) {
        [self.occurrencesOfEvents addObject:occ];
    }
    [self.theTableView reloadData];
    [self.theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

#pragma mark - UITableViewDataSource and Delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [_theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.occurrencesOfEvents count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Occurrence *thisOcc = [self.occurrencesOfEvents objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisOcc.updatedTitle;
    cell.textLabel.textColor = [UIColor offWhiteScheme];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GENERAL_TIME_FORMAT];
    NSString *startTime = [dateFormatter stringFromDate:thisOcc.startTime];
    NSString *endTime = [dateFormatter stringFromDate:thisOcc.endTime];
    
    
    NSString *cost = thisOcc.eventForOccurrence.cost;
    if (cost && ![cost isEqualToString:@""]) {
        cost = thisOcc.updatedCost;
    }
    
    NSString *dj;
    if (dj && ![dj isEqualToString:@""]) {
        dj = [NSString stringWithFormat:@" - %@",thisOcc.DJ];
    }
    
    NSString *subtitle = [NSString stringWithFormat:@"%@-%@ : $%@ %@",startTime,endTime, cost, dj];
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
