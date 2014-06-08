//
//  SSMapView.m
//  Swing Local
//
//  Created by Stevenson on 3/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSMapView.h"

#define TAB_HEIGHT 50.f
#define TAB_WIDTH 50.f

@implementation SSMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame = rect;
    //// Color Declarations
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(frame)-5, CGRectGetMaxY(frame)-TAB_HEIGHT)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame)-5, CGRectGetMaxY(frame)-5)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMaxX(frame)-10, CGRectGetMaxY(frame)) controlPoint1: CGPointMake(CGRectGetMaxX(frame)-5, CGRectGetMaxY(frame)-5) controlPoint2: CGPointMake(CGRectGetMaxX(frame)-7.5, CGRectGetMaxY(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame)-(TAB_WIDTH+5), CGRectGetMaxY(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMaxX(frame)-(TAB_WIDTH+10), CGRectGetMaxY(frame)-5) controlPoint1: CGPointMake(CGRectGetMaxX(frame)-(TAB_WIDTH+7.5), CGRectGetMaxY(frame)) controlPoint2: CGPointMake(CGRectGetMaxX(frame)-(TAB_WIDTH+10), CGRectGetMaxY(frame)-5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame)-(TAB_WIDTH+10), CGRectGetMaxY(frame)-TAB_HEIGHT)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame)-TAB_HEIGHT)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame)-TAB_HEIGHT)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame)-5, CGRectGetMaxY(frame)-TAB_HEIGHT)];
    //[[UIColor colorWithRed:0.705 green:0.194 blue:0.165 alpha:1.000] setFill];
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
}
@end
