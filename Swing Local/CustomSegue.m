//
//  customSegue.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue

- (void) perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    //NSLog(@"%@ : %@",src,dst);
    [src addChildViewController:dst];
    
    [UIView transitionWithView:src.navigationController.view duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    }
                    completion:NULL];
}

@end
