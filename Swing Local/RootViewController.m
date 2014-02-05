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
    NSURL *archiveURL = [[self documentDir] URLByAppendingPathComponent:SAVED_CITY_ARCHIVE_NAME];
    NSArray *allCities =[NSKeyedUnarchiver unarchiveObjectWithFile:[archiveURL path]];
    if (allCities) {
        [EventManager sharedManager].allCities = allCities;
    }
    [[EventManager sharedManager] downloadCities];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL skipTutorial = [standardDefaults boolForKey:@"SkipTutorial"];
    
    //skip tutorial
    if (skipTutorial){
        [self performSegueWithIdentifier:@"showSplitController" sender:self];
    } else {
        [standardDefaults setBool:YES forKey:@"SkipTutorial"];
        [self performSegueWithIdentifier:@"showTutorial" sender:self]; 
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
