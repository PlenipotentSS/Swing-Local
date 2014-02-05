//
//  GoogleCalendarManager.m
//  Swing Local
//
//  Created by Stevenson on 2/5/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "GoogleCalendarManager.h"
#import <GTLUtilities.h>
#import <GTMHTTPFetcherLogging.h>
#import <GTMOAuth2ViewControllerTouch.h>

// Keychain item name for saving the user's authentication information
NSString *const kKeychainItemName = @"CalendarSwingLocal: Swing Local Calendar";

@implementation GoogleCalendarManager

+(GoogleCalendarManager*) sharedManager
{
    static dispatch_once_t pred;
    static GoogleCalendarManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[GoogleCalendarManager alloc] init];
    });
    
    return shared;
}

-(id) init
{
    self = [super init];
    if (self) {
    NSString *googleClientID = @"";
    NSString *googleClientSecret = @"";
        GTMOAuth2Authentication *auth;
        //    auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID: clientSecret:<#(NSString *)#> error:<#(NSError *__autoreleasing *)#>
        
        
        //            authForGoogleFromKeychainForName:kKeychainItemName
        //                                                              clientID:clientID
        //                                                          clientSecret:clientSecret];
        _calendarService.authorizer = auth;
    }
    return self;
}

@end
