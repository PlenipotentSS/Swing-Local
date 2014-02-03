//
//  EventsTableViewModel.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "EventsTableViewModel.h"
#import "UIColor+SwingLocal.h"

@interface EventsTableViewModel()

@property (nonatomic) NSArray *testData;
@property (nonatomic) NSArray *subTitleData;
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

-(void) setCity:(CityEvents *)city {
    _city = city;
    
    _testData = @[@"Century Ballroom",@"Russian Center",@"Savoy Mondays"];
    _subTitleData = @[@"9:30pm",@"9:00pm",@"9:00pm"];
    
    [_cellOperationQueue addOperationWithBlock:^{
        usleep(500000);
    }];
    [_theTableView reloadData];
    [_theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_testData count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [_testData objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor offWhiteScheme];
    
    cell.detailTextLabel.text = [_subTitleData objectAtIndex:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor offWhiteScheme];
    [cell.contentView setAlpha:0.f];
    [self animateCell:cell AtIndex:indexPath];
    return cell;
}

-(void) animateCell: (UITableViewCell*) cell AtIndex: (NSIndexPath*) indexPath {
    CGAffineTransform transform = CGAffineTransformMakeScale(1.33f, 1.33f);
    [_cellOperationQueue addOperationWithBlock:^{
        usleep(250000);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [UIView animateWithDuration:.4f animations:^{
                [cell.contentView setAlpha:1.f];
                cell.transform = CGAffineTransformScale(transform, .75f, .75f);
            }];
        }];
    }];

}

@end
