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

@interface EventsTableViewModel : NSObject <UITableViewDataSource,UITableViewDelegate>

//the current city being displayed
@property (nonatomic) City *city;

//link to the table view to redraw
@property (nonatomic) EventsTableView *theTableView;

//set city in case only have name
-(void) setCityWithName: (NSString*) cityName;

@end
