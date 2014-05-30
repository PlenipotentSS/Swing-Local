//
//  SSEventTableView.h
//  Swing Local
//
//  Created by Stevenson on 3/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSEventTableView : UITableView

@property (nonatomic) BOOL isVisible;
@property (nonatomic, copy) void (^recognizerBlock)(NSSet *view);

@end
