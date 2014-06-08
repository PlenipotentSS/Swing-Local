//
//  MapManager.h
//  Swing Local
//
//  Created by Steven Stevenson on 6/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSMapView.h"

@protocol MapManagerDelegate <NSObject>

- (void)mapViewButton:(id)sender;

@end

@interface MapManager : NSObject

+ (MapManager*)sharedManager;

- (SSMapView*)getMapView;

@property (weak,nonatomic) id<MapManagerDelegate> mapDelegate;

@end
