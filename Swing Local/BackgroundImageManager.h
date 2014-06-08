//
//  BackgroundImageManager.h
//  Swing Local
//
//  Created by Steven Stevenson on 6/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSPhotoBackgroundView.h"


@interface BackgroundImageManager : NSObject

+ (BackgroundImageManager*)sharedManager;

- (SSPhotoBackgroundView*)getBackgroundView;

@end
