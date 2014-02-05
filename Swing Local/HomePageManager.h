//
//  HomePageManager.h
//  Swing Local
//
//  Created by Stevenson on 2/1/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"

@protocol HomePageManagerDelegate <NSObject>

-(void) updateViewWithImage:(UIImage*) theImage;

@end

@interface HomePageManager : NSObject

@property (unsafe_unretained) id<HomePageManagerDelegate> delegate;

+ (HomePageManager*) sharedManager;

-(void) downloadImageFromURL:(NSURL *)imageURL forCity:(City*)city;

-(void) downloadImageFromURL:(NSURL *)imageURL forCityName:(NSString*)cityName;
@end
