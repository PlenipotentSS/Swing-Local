//
//  SSMasterViewController.m
//  SplitPeekViewController
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SplitViewController.h"
#import "BackViewController.h"
#import "FrontViewController.h"

#define Menu_Offset 60.f
#define MAX_OPEN_SPACE 256.f

@interface SplitViewController () <UIGestureRecognizerDelegate>

@end

@implementation SplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:(NSBundle *)nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //setup navigation controller pointers
    [self setupSubNavControllers];
    
    //setup pan gesture recognizers
//    [self setupPanGesture];
    
    //set the current relationship cover
    self.menuStateInView = MenuCompletelyHidden;
    
}

-(void) setupSubNavControllers {
    self.backViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"back"];
    [self.view addSubview:self.backViewController.view];
    [self addChildViewController:self.backViewController];
    [self.backViewController didMoveToParentViewController:self];

    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
//    self.view.backgroundColor = [(UIViewController*)[[self.backViewController viewControllers] firstObject] view].backgroundColor;
    
    self.frontViewController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"front"];
    [self.view addSubview:self.frontViewController.view];
    [self addChildViewController:self.frontViewController];
    [self.frontViewController didMoveToParentViewController:self];
    
    FrontViewController *frontVC = (FrontViewController*)[[self.frontViewController viewControllers] firstObject];
    BackViewController *backVC = (BackViewController*)[[self.backViewController viewControllers] firstObject];
    [backVC setFrontViewController:frontVC];
    
    self.frontViewController.navigationController.navigationBar.hidden = NO;
    
    [self addChildViewController:self.frontViewController];
    [self.frontViewController didMoveToParentViewController:self];
    
    [self.frontViewController.view.layer setShadowOpacity:0.8f];
    [self.frontViewController.view.layer setShadowOffset:CGSizeMake(-1,0)];
}

//-(void)setupPanGesture {
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slidePanel:)];
//    
//    pan.minimumNumberOfTouches = 1;
//    pan.maximumNumberOfTouches = 1;
//    
//    pan.delegate = self;
//    
//    [self.frontViewController.view addGestureRecognizer:pan];
//}

///////// VIEW CONTROLLER FRAME SETS WITH ROTATIONS

#pragma mark - top view controller motions from menu
-(void)showMenuFullScreen {
    CGRect newFrontFrame = self.frontViewController.view.frame;
    newFrontFrame.origin.x = CGRectGetWidth(self.frontViewController.view.frame);
    newFrontFrame.origin.y = 0.f;
    [UIView animateWithDuration:.4f animations:^{
        self.frontViewController.view.frame= newFrontFrame;
        self.backViewController.view.frame = [self getBackViewRectOpen];
    }];
    self.menuStateInView = MenuCompletelyOpened;
}

-(void)showMenuSplit {
    CGRect newFrontFrame = self.frontViewController.view.frame;
    CGFloat newXOrigin = CGRectGetWidth(self.frontViewController.view.frame)-(.2*CGRectGetWidth(self.frontViewController.view.frame));
    if (newXOrigin > MAX_OPEN_SPACE) {
        newXOrigin = MAX_OPEN_SPACE;
    }
    newFrontFrame.origin.x = newXOrigin;
    newFrontFrame.origin.y = 0.f;
    
    CABasicAnimation *frontPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    
    CGPoint newPosition = self.frontViewController.view.layer.position;
    newPosition.x = newXOrigin+CGRectGetWidth(self.frontViewController.view.frame)/2;
    
    frontPosAnim.fromValue = [NSValue valueWithCGPoint:self.frontViewController.view.layer.position ];
    frontPosAnim.toValue = [NSValue valueWithCGPoint:newPosition];
    frontPosAnim.duration = .4f;
    frontPosAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *backPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    
    CGPoint newPositionBack = self.frontViewController.view.layer.position;
    newPosition.x = 0.f;
    
    backPosAnim.fromValue = [NSValue valueWithCGPoint:self.frontViewController.view.layer.position ];
    backPosAnim.toValue = [NSValue valueWithCGPoint:newPositionBack];
    backPosAnim.duration = .4f;
    backPosAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0.75; // Your from value (not obvious from the question)
    scale.toValue = @1.0;
    scale.duration = 0.4;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.backViewController.view.layer addAnimation:scale forKey:@"move forward by scaling"];
    [self.frontViewController.view.layer addAnimation:frontPosAnim forKey:@"position"];
    [self.backViewController.view.layer addAnimation:backPosAnim forKey:@"position"];
    self.backViewController.view.transform = CGAffineTransformIdentity; // Set end value (animation won't apply the value to the model)
    self.frontViewController.view.frame= newFrontFrame;
    self.backViewController.view.frame = [self getBackViewRectOpen];
    
    self.menuStateInView = MenuOpened;
}


- (void)hideMenu {
    CGRect newFrontFrame = self.frontViewController.view.frame;
    newFrontFrame.origin.x = 0.f;
    newFrontFrame.origin.y = 0.f;
    [UIView animateWithDuration:.4f animations:^{
        self.frontViewController.view.frame= newFrontFrame;
        self.backViewController.view.frame = [self getBackViewRectOrigin];
    }];
    self.menuStateInView = MenuCompletelyHidden;
}


- (CGRect)getBackViewRectOrigin
{
    CGRect backFrame = self.backViewController.view.frame;
    backFrame.origin.x = Menu_Offset;
    return backFrame;
}

- (CGRect)getBackViewRectOpen
{
    CGRect backFrame = self.backViewController.view.frame;
    backFrame.origin.x = 0;
    return backFrame;
}

///////// END VIEW CONTROLLER FRAME SETS WITH ROTATIONS

//#pragma mark - pan Gesture Actions
//- (void)slidePanel:(id)sender
//{
//    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
//    
//    //CGPoint velocity = [pan velocityInView:pan.view];
//    CGPoint translation = [pan translationInView:self.view];
//    CGPoint velocity = [pan velocityInView:self.view];
//    if (pan.state ==UIGestureRecognizerStateChanged) {
//        if (self.frontViewController.view.frame.origin.x+translation.x >= 0) {
//            self.frontViewController.view.center = CGPointMake(self.frontViewController.view.center.x+translation.x, self.frontViewController.view.center.y);
//            
//            [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0, 0) inView:self.view];
//        }
//        
//        if (self.backViewController.view.frame.origin.x >= -Menu_Offset && self.backViewController.view.frame.origin.x <= 0.f) {
//            CGFloat menuTranslation = self.backViewController.view.center.x+translation.x*Menu_Offset/320;
//            if (menuTranslation > self.view.center.x) {
//                menuTranslation = self.view.center.x;
//            }
//            [self scaleBackViewByOffset:(menuTranslation-96)];
//            self.backViewController.view.center = CGPointMake(menuTranslation, self.frontViewController.view.center.y);
//        }
//    }
//    if (pan.state == UIGestureRecognizerStateEnded) {
//        if ((self.frontViewController.view.frame.origin.x <= self.view.frame.size.width/2 && velocity.x < 1200.f) || velocity.x < -1200.f ) {
//            [self hideMenu];
//            self.backViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, .85, .85);
//            self.menuStateInView = MenuCompletelyHidden;
//        } else if (velocity.x >= 1200.f || self.frontViewController.view.frame.origin.x > self.view.frame.size.width/2) {
//            self.backViewController.view.transform = CGAffineTransformIdentity;
//            [self showMenuSplit];
//        }
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end