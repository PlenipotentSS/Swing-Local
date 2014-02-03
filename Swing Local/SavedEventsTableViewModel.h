//
//  SavedEventsTableViewModel.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedEventsTableViewModel : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) UITableView *theTableView;


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath ;

@end
