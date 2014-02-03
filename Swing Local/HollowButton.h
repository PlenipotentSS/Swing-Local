//
//  HollowButton.h
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HollowButton : UIButton

@property (nonatomic) UIColor *colorOverlay;

-(void) setColorOverlay:(UIColor *)colorOverlay withImage:(UIImage*) buttonImage;

@end
