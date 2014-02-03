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
    return [UIColor colorWithRed:56.f/255.f green:76.f/255.f blue:87.f/255.f alpha:1.f];
}

+(UIColor *) offWhiteScheme {
    return [UIColor colorWithRed:229.f/255.f green:228.f/255.f blue:202.f/255.f alpha:1.f];
}

+(UIColor *) peachScheme {
    return [UIColor colorWithRed:255.f/255.f green:201.f/255.f blue:132.f/255.f alpha:1.f];
}

+(UIColor *) orangeScheme {
    return [UIColor colorWithRed:208.f/255.f green:109.f/255.f blue:40.f/255.f alpha:1.f];
}

+(UIColor *) burntScheme {
    return [UIColor colorWithRed:189.f/255.f green:73.f/255.f blue:50.f/255.f alpha:1.f];
    //return [UIColor colorWithRed:189.f/255.f green:54.f/255.f blue:34.f/255.f alpha:1.f];
}


//+(UIColor *) getRandomColor {
//    //CGFloat r = drand48(255)/255;
//    
//    NSMutableArray *comps = [NSMutableArray new];
//    for (int i=0;i<3;i++) {
//        NSUInteger r = arc4random_uniform(256);
//        CGFloat randomColorComponent = (CGFloat)r/255.f;
//        [comps addObject:@(randomColorComponent)];
//    }
//    return [UIColor colorWithRed:[comps[0] floatValue] green:[comps[1] floatValue] blue:[comps[2] floatValue] alpha:1.0];
//}

@end
