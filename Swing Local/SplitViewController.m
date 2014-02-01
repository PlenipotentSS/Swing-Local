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

#define Menu_Offset 40.f
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
    [self setupPanGesture];
    
    //set the current relationship cover
    self.menuStateInView = MenuCompletelyHidden;
    
}

-(void) setupSubNavControllers {
    self.backViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"back"];
    [self.view addSubview:self.backViewController.view];
    [self addChildViewController:self.backViewController];
    [self.backViewController didMoveToParentViewController:self];
    BackViewController *backVC = (BackViewController*)[[self.backViewController viewControllers] firstObject];
    
    self.frontViewController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"front"];
    [self.view addSubview:self.frontViewController.view];
    [self addChildViewController:self.frontViewController];
    [self.frontViewController didMoveToParentViewController:self];
    
    FrontViewController *frontVC = (FrontViewController*)[[self.frontViewController viewControllers] firstObject];
    
    //[backVC setFrontViewController:frontVCVC];
    
    self.frontViewController.navigationController.navigationBar.hidden = NO;
    
    [self addChildViewController:self.frontViewController];
    [self.frontViewController didMoveToParentViewController:self];
    
    [self.frontViewController.view.layer setShadowOpacity:0.8f];
    [self.frontViewController.view.layer setShadowOffset:CGSizeMake(-1,0)];
}

-(void)setupPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slidePanel:)];
    
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    
    pan.delegate = self;
    
    [self.frontViewController.view addGestureRecognizer:pan];
}

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
    [UIView animateWithDuration:.4f animations:^{
        self.frontViewController.view.frame= newFrontFrame;
        self.backViewController.view.frame = [self getBackViewRectOpen];
    }];
    self.menuStateInView = MenuOpened;
}

-(void)hideMenu {
    CGRect newFrontFrame = self.frontViewController.view.frame;
    newFrontFrame.origin.x = 0.f;
    newFrontFrame.origin.y = 0.f;
    [UIView animateWithDuration:.4f animations:^{
        self.frontViewController.view.frame= newFrontFrame;
        self.backViewController.view.frame = [self getBackViewRectOrigin];
    }];
    self.menuStateInView = MenuCompletelyHidden;
}


-(CGRect) getBackViewRectOrigin {
    CGRect backFrame = self.backViewController.view.frame;
    backFrame.origin.x = -Menu_Offset;
    return backFrame;
}

-(CGRect) getBackViewRectOpen {
    CGRect backFrame = self.backViewController.view.frame;
    backFrame.origin.x = 0.f;
    return backFrame;
}

///////// END VIEW CONTROLLER FRAME SETS WITH ROTATIONS

#pragma mark - pan Gesture Actions
-(void)slidePanel:(id) sender {
    NSLog(@"slidePanel");
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    
    //CGPoint velocity = [pan velocityInView:pan.view];
    CGPoint translation = [pan translationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    if (pan.state ==UIGestureRecognizerStateChanged) {
        if (self.frontViewController.view.frame.origin.x+translation.x >= 0) {
            self.frontViewController.view.center = CGPointMake(self.frontViewController.view.center.x+translation.x, self.frontViewController.view.center.y);
            
            [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0, 0) inView:self.view];
        }
        
        
        
        if (self.backViewController.view.frame.origin.x >= -Menu_Offset && self.backViewController.view.frame.origin.x <= 0.f) {
            CGFloat menuTranslation = self.backViewController.view.center.x+translation.x*Menu_Offset/320;
            if (menuTranslation > self.view.center.x) {
                menuTranslation = self.view.center.x;
            }
            //self.backViewController.view.center = CGPointMake(menuTranslation, self.frontViewController.view.center.y);
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        if ((self.frontViewController.view.frame.origin.x <= self.view.frame.size.width/2 && velocity.x < 1200.f) || velocity.x < -1200.f ) {
            [self hideMenu];
            self.menuStateInView = MenuCompletelyHidden;
        } else if (velocity.x >= 1200.f || self.frontViewController.view.frame.origin.x > self.view.frame.size.width/2) {
            [self showMenuSplit];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
