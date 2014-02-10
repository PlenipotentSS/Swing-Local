//
//  HomePageManager.m
//  Swing Local
//
//  Created by Stevenson on 2/1/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HomePageManager.h"
#import "EventManager.h"


@interface HomePageManager()

@property (nonatomic) NSOperationQueue *downloadImageQueue;

@end

@implementation HomePageManager

+(HomePageManager*) sharedManager {
    static dispatch_once_t pred;
    static HomePageManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[HomePageManager alloc] init];
        shared.downloadImageQueue = [NSOperationQueue new];
    });
    
    return shared;
}

-(void) downloadImageFromURL:(NSURL *)imageURL forCity:(City*)city{
    [self.downloadImageQueue addOperationWithBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *theImage = [UIImage imageWithData:imageData];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            city.cityImage = theImage;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.delegate updateViewWithImage:theImage];
            }];
        }];
    }];
}

-(void) downloadImageFromURL:(NSURL *)imageURL forCityName:(NSString*)cityName{
    NSArray *allCities = [[EventManager sharedManager] allCities];
    for (City *thisCity in allCities) {
        if ([thisCity.cityName isEqualToString:cityName]) {
            [self downloadImageFromURL:imageURL forCity:thisCity];
            break;
        }
    }
}

@end
