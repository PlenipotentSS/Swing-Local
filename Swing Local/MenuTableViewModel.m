//
//  MenuTableViewModel.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "MenuTableViewModel.h"
@interface MenuTableViewModel()

@property (nonatomic) NSArray* menuItems;

@end

@implementation MenuTableViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _menuItems = @[@"News",@"Home",@"Calendar",@""];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItems count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"menuCell";
    UITableViewCell *cell = [_theTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [_menuItems objectAtIndex:indexPath.row];
    
    return cell;
}

@end
