//
//  SavedEventsTableViewModel.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SavedEventsTableViewModel.h"
@interface SavedEventsTableViewModel()

@property (nonatomic) NSArray *mySavedEvents;

@end

@implementation SavedEventsTableViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _mySavedEvents = @[@"Seattle, WA", @"New York, NY",@"Los Angeles",@"Albuqurque, NM",@"New Orleans, LA",@""];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_mySavedEvents count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"savedEventCell";
    UITableViewCell *cell = [_theTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [_mySavedEvents objectAtIndex:indexPath.row];
    
    return cell;
}

@end
