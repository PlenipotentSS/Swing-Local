//
//  RootViewController.m
//  Swing Local
//
//  Created by Stevenson on 2/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "RootViewController.h"
#import "CustomSegue.h"
#import "EventManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
    //load all cities from manager & compare with that in data
//    NSURL *archiveURL = [[self documentDir] URLByAppendingPathComponent:SAVED_CITY_ARCHIVE_NAME];
//    NSMutableArray *savedCities =[NSKeyedUnarchiver unarchiveObjectWithFile:[archiveURL path]];
//    if (savedCities) {
//        [EventManager sharedManager].savedCities = savedCities;
//    }
//    [[EventManager sharedManager] downloadCities];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    [standardDefaults setBool:YES forKey:@"newLaunch"];
    BOOL skipTutorial = [standardDefaults boolForKey:@"SkipTutorial"];
    
    [self performSegueWithIdentifier:@"showTutorial" sender:self];
    
    if (skipTutorial || ![UIPageControl instancesRespondToSelector:@selector(setTintColor:)]){
        [self performSegueWithIdentifier:@"showSplitController" sender:self];
        [standardDefaults setBool:NO forKey:@"Skiptutorial"];
    } else {
        [self performSegueWithIdentifier:@"showTutorial" sender:self];
        [self performSegueWithIdentifier:@"showSplitController" sender:self];
    }
}

-(NSURL *)documentDir {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [(CustomSegue*)segue perform];
}
@end
