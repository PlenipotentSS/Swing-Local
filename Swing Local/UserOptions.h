//
//  UserOptions.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"

@interface UserOptions : NSObject

@property (nonatomic) BOOL hasLaunched;

@property (nonatomic) NSArray *favoritedCities;

@property (nonatomic) City *currentCity;

@end
