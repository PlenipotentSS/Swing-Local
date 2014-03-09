//
//  SSPhotoBackgroundView.m
//  Swing Local
//
//  Created by Stevenson on 3/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSPhotoBackgroundView.h"

@interface SSPhotoBackgroundView()

@property (weak, nonatomic) IBOutlet UIImageView *photographyBackground;

@end

@implementation SSPhotoBackgroundView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self makeBackgroundGradient];
}

- (void)makeBackgroundGradient
{
    CGRect frame = self.frame;
    
    //// General Declarations
    UIGraphicsBeginImageContext(frame.size);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color1 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0];
    UIColor* color2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.7];
    
    //// Gradient Declarations
    NSArray* sVGID_1_Colors = [NSArray arrayWithObjects:
                               (id)color1.CGColor,
                               (id)color2.CGColor, nil];
    CGFloat sVGID_1_Locations[] = {0.73, 1};
    CGGradientRef sVGID_1_ = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)sVGID_1_Colors, sVGID_1_Locations);
    NSArray* sVGID_2_Colors = [NSArray arrayWithObjects:
                               (id)color1.CGColor,
                               (id)color2.CGColor, nil];
    CGFloat sVGID_2_Locations[] = {0.73, 1};
    CGGradientRef sVGID_2_ = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)sVGID_2_Colors, sVGID_2_Locations);
    
    
    //// Rectangle Drawing
    CGRect rectangleRect = frame;
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rectangleRect];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, sVGID_1_,
                                CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetHeight(rectangleRect)),
                                CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMinY(rectangleRect)),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: rectangleRect];
    CGContextSaveGState(context);
    [rectangle2Path addClip];
    CGContextDrawLinearGradient(context, sVGID_1_,
                                CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMinY(rectangleRect)),
                                CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetHeight(rectangleRect)),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    self.photographyBackground.image = backgroundImage;
    
    //// Cleanup
    CGGradientRelease(sVGID_1_);
    CGGradientRelease(sVGID_2_);
    CGColorSpaceRelease(colorSpace);
}

@end
