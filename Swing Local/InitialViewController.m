//
//  InitialViewController.m
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "InitialViewController.h"
#import "GHWalkThroughView.h"
#import "UIColor+LocalSwingCalendar.h"
#import "SplitViewController.h"

@interface InitialViewController () <GHWalkThroughViewDataSource, GHWalkThroughViewDelegate>

@property (nonatomic, strong) GHWalkThroughView* ghView ;
@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic,strong) SplitViewController *splitController;

@property (nonatomic,strong) NSMutableArray *titles;
@property (nonatomic,strong) NSMutableArray *descriptions;
@property (nonatomic,strong) NSMutableArray *backgroundColors;

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor aquaScheme];
    
    [self setupSplitController];
    
    [self setupDescriptions];
    
    [self setupWalkThrough];
    
    
}

#pragma mark - Initial Controller setup methods
-(void) setupDescriptions {
    self.titles = [[NSMutableArray alloc] init];
    [self.titles addObject:@"Find Swing Dances in your City"];
    [self.titles addObject:@"Venue Updates Straight To You"];
    [self.titles addObject:@"Easy For Venues, Easier For The You"];
    
    
    self.descriptions = [[NSMutableArray alloc] init];
    [self.descriptions addObject:@"Swing dance venues can now provide you up to date information about where to dance in your city. We are here to make it easier for you to find where to dance in your city!"];
    [self.descriptions addObject:@"With our simple Google update platform, we collect all the date for you! It is up to the venue managers to keep up to date records, and that information is then presented here in real time. You will no longer have to hunt to find where to dance in your city!"];
    [self.descriptions addObject:@"Venue managers keep up to date information on a google calendar of their choice, and we compile all their data to you and provide the information you need to go straight to dancing. No more PHDs in research to find where you want to go out!"];
    
    self.backgroundColors = [[NSMutableArray alloc] init];
    [self.backgroundColors addObject:[UIColor aquaScheme]];
    [self.backgroundColors addObject:[UIColor orangeScheme]];
    [self.backgroundColors addObject:[UIColor burntScheme]];
}

-(void) setupSplitController {
    self.splitController = (SplitViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"splitController"];
}

-(void) setupWalkThrough {
    _ghView = [[GHWalkThroughView alloc] initWithFrame:self.navigationController.view.bounds];
    [_ghView setDataSource:self];
    [_ghView setDelegate:self];
    [self.ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
    
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    welcomeLabel.text = @"Swing Local";
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    
    [_ghView setFloatingHeaderView:welcomeLabel];
    [(UILabel*)self.ghView.floatingHeaderView setTextColor:[UIColor offWhiteScheme]];
    
    [self.ghView showInView:self.navigationController.view animateDuration:0.3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GHWalkThroughDelegate
-(void) skipButtonPressed {
    [self.splitController.view setAlpha:0.f];
    [self.view insertSubview:self.splitController.view belowSubview:self.ghView];
    [UIView animateWithDuration:.4f animations:^{
        [self.splitController.view setAlpha:1.f];
    }];
}

#pragma mark - GHWalkThroughViewDataSource
-(NSInteger) numberOfPages
{
    return 3;
}

- (void) configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.backgroundColor = [self.backgroundColors objectAtIndex:index];
    
    cell.title = [self.titles objectAtIndex:index];
    cell.titleColor = [UIColor offWhiteScheme];
    cell.desc = [self.descriptions objectAtIndex:index];
    cell.descColor = [UIColor offWhiteScheme];
}

- (UIImage*) bgImageforPage:(NSInteger)index
{
    //NSString* imageName =[NSString stringWithFormat:@"bg_0%li.png", index+1];
    //UIImage* image = [UIImage imageNamed:imageName];
    return nil;
}

@end
