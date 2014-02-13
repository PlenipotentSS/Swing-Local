//
//  CityAnnotation.h
//  Swing Local
//
//  Created by Stevenson on 2/12/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CityAnnotation : NSObject<MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end
