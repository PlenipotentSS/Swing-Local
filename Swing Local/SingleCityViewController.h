//
//  SingleCityViewController.h
//  Swing Local
//
//  Created by Stevenson on 2/4/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrontViewController.h"
#import "City.h"

@interface SingleCityViewController : FrontViewController

//set the current city for display
@property (weak, nonatomic) City *theCity;

@end
