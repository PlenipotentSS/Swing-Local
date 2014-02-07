//
//  FrontViewController.h
//  SplitPeekViewController
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailView.h"

@interface FrontViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (nonatomic) FrontViewController *rootSegueController;

@end