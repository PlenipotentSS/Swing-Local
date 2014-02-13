//
//  EventsTableViewModel.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"
#import "EventsTableView.h"
#import "Occurrence.h"

@protocol EventsTableViewModelDelegate <NSObject>

-(void) updateMapPinForOccurrence:(Occurrence*) thisOccurrence;
-(void) doneSearching;
@end

@interface EventsTableViewModel : NSObject <UITableViewDataSource,UITableViewDelegate>

//delegate for updating occurrence to view
@property (unsafe_unretained) id<EventsTableViewModelDelegate> delegate;

//the current city being displayed NOTE set dates before city!
@property (nonatomic) City *city;

@property (nonatomic) NSArray *cities;

//link to the table view to redraw
@property (nonatomic) EventsTableView *theTableView;

//dates to search for NOTE: to use set dates before setting city!
@property (nonatomic) NSArray *datesToSearch;

//set city in case only have name
-(void) setCityWithName: (NSString*) cityName;


@end
