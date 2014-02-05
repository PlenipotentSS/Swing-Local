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

@interface EventsTableViewModel() <EventManagerCityDelegate>

@property (nonatomic) NSMutableArray *events;
@property (nonatomic) NSOperationQueue *cellOperationQueue;

@end

@implementation EventsTableViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _events = [NSMutableArray new];
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

-(void) refreshEventTableWithCity: (City*) thisCity {
    if (_city.venueOrganizations) {
        [self reloadEvents];
    } else {
        [[EventManager sharedManager] setCityDelegate:self];
        [[EventManager sharedManager] downloadVenuesAndEventsInCity:thisCity];
    }
}

-(void) reloadEvents {
    _events = [NSMutableArray new];
    //give delay for cell animations
    [_cellOperationQueue addOperationWithBlock:^{
        usleep(500000);
    }];
    for (Venue *thisVenue in _city.venueOrganizations) {
        //change to get get events for this day in venue
        NSArray *eventsToday = [self eventsTodayForVenue:thisVenue];
        [_events addObjectsFromArray:eventsToday];
        
        [_theTableView reloadData];
        [_theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
}

-(NSArray*) eventsTodayForVenue:(Venue*) thisVenue {
    return thisVenue.events;
}

#pragma mark - UITableViewDataSource and Delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [_theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_events count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Event *thisEvent = [_events objectAtIndex:indexPath.row];
    
    
    cell.textLabel.text = thisEvent.eventTitle;
    cell.textLabel.textColor = [UIColor offWhiteScheme];
    
    //cell.detailTextLabel.text = [_subTitleData objectAtIndex:indexPath.row];
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
