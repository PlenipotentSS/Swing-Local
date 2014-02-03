//
//  EventsTableViewModel.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityEvents.h"
#import "EventsTableView.h"

@interface EventsTableViewModel : NSObject <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) CityEvents *city;
@property (nonatomic) EventsTableView *theTableView;

@end
