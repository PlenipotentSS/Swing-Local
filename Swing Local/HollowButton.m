//
//  HollowButton.m
//  Swing Local
//
//  Created by Stevenson on 2/2/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "HollowButton.h"

@implementation HollowButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setColorOverlay:(UIColor *)colorOverlay withImage:(UIImage*) buttonImage {
    _colorOverlay = colorOverlay;
    if (buttonImage) {
        CGRect frame = [self frame];
        frame.origin.x = 0.f;
        frame.origin.y = 0.f;
       
        UIView *overlay = [[UIView alloc] initWithFrame:frame];
        UIImageView *maskImageView = [[UIImageView alloc] initWithImage:buttonImage];
        [maskImageView setFrame:frame];
        [[overlay layer] setMask:[maskImageView layer]];
        [overlay setBackgroundColor:colorOverlay];
        overlay.transform = CGAffineTransformMakeScale(.8f, .8f);
    
        [self insertSubview:overlay belowSubview:self.imageView];
    }
}

@end
