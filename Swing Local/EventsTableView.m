//
//  EventsTableView.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "EventsTableView.h"
@interface EventsTableView()

@property (weak, nonatomic) IBOutlet UIView *headerView;


@end

@implementation EventsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)reloadData {
    CGPoint center = CGPointMake(self.center.x-100, _headerView.center.y);
    _headerView.center = center;
    [super reloadData];
}

@end
