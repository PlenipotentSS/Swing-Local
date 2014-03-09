//
//  SSAppDelegate.m
//  Swing Local
//
//  Created by Stevenson on 2/1/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSAppDelegate.h"
#import <uservoice-iphone-sdk/UserVoice.h>
#import "RootViewController.h"
#import "EventManager.h"
#import "GoogleCalendarManager.h"
#import <Crashlytics/Crashlytics.h>

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Set this up once when your application launches
    UVConfig *config = [UVConfig configWithSite:@"swinglocal.uservoice.com"];
    config.forumId = 239827;
    [UserVoice initialize:config];
    [Crashlytics startWithAPIKey:@"7bb362af92e487f1f93c82a87e0beacc5172ff1f"];
    
    application.applicationIconBadgeNumber = 0;
//    
//    // Handle launching from a notification
//    UILocalNotification *localNotif =
//    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (!self.localNotificationManager) {
        self.localNotificationManager = [[LocalNotificationManager alloc] init];
    }
    [self.localNotificationManager cancelNotification];
    [self.localNotificationManager scheduleNotification];
    
    
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    NSLog(@"Recieved Notification %@",notif);
    
    [self.localNotificationManager cancelNotification];
    [self.localNotificationManager scheduleNotification];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[EventManager sharedManager] downloadCities];
    [self.localNotificationManager cancelNotification];
    [self.localNotificationManager scheduleNotification];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
