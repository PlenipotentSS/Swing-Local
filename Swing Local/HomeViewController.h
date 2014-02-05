//
//  HomeViewController.h
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrontViewController.h"
#import "City.h"

@interface HomeViewController : FrontViewController

//the current city for home view
@property (weak, nonatomic) City *currentCity;

@end
