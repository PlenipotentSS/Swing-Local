//
//  UIColor+SwingLocal.m
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "UIColor+SwingLocal.h"

@implementation UIColor (SwingLocal)

+(UIColor *) aquaScheme {
    //return [UIColor colorWithRed:16.f/255.f green:91.f/255.f blue:99.f/255.f alpha:1.f];
    //return [UIColor colorWithRed:64.f/255.f green:114.f/255.f blue:125.f/255.f alpha:1.f];
    return [UIColor colorWithRed:0.162 green:0.232 blue:0.267 alpha:1.000];
}

+(UIColor *) offWhiteScheme {
    return [UIColor colorWithRed:0.873 green:0.872 blue:0.761 alpha:1.000];
}

+(UIColor *) peachScheme {
    return [UIColor colorWithRed:0.994 green:0.739 blue:0.481 alpha:1.000];
}

+(UIColor *) orangeScheme {
    return [UIColor colorWithRed:0.813 green:0.425 blue:0.158 alpha:1.000];
}

+(UIColor *) burntScheme {
    return [UIColor colorWithRed:0.705 green:0.194 blue:0.165 alpha:1.000];
    //return [UIColor colorWithRed:189.f/255.f green:54.f/255.f blue:34.f/255.f alpha:1.f];
}


+(UIColor *) getRandomColor {
    //CGFloat r = drand48(255)/255;
    
    NSMutableArray *comps = [NSMutableArray new];
    for (int i=0;i<3;i++) {
        NSUInteger r = arc4random_uniform(256);
        CGFloat randomColorComponent = (CGFloat)r/255.f;
        [comps addObject:@(randomColorComponent)];
    }
    return [UIColor colorWithRed:[comps[0] floatValue] green:[comps[1] floatValue] blue:[comps[2] floatValue] alpha:1.0];
}

@end
