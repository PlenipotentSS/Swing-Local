//
//  HomePageManager.m
//  Swing Local
//
//  Created by Stevenson on 2/1/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HomePageManager.h"
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

-(void) downloadImageFromURL:(NSURL *)imageURL {
    [self.downloadImageQueue addOperationWithBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *theImage = [UIImage imageWithData:imageData];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate updateViewWithImage:theImage];
        }];
    }];
}

@end
