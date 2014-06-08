//
//  BackgroundImageManager.m
//  Swing Local
//
//  Created by Steven Stevenson on 6/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "BackgroundImageManager.h"

@interface BackgroundImageManager()

@property (nonatomic,weak) SSPhotoBackgroundView *backgroundView;

@end


@implementation BackgroundImageManager

+(BackgroundImageManager*) sharedManager
{
    static dispatch_once_t pred;
    static BackgroundImageManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[BackgroundImageManager alloc] init];
        if (!shared.backgroundView) {
            [shared setupBackgroundView];
        }
    });
    
    return shared;
}

- (SSPhotoBackgroundView*)getBackgroundView
{
    return self.backgroundView;
}

- (void)setupBackgroundView
{
    _backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"PhotographerCoverView" owner:self options:nil] objectAtIndex:0];
}

@end
