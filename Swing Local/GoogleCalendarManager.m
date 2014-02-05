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
        if (!_calendarService.authorizer) {
            NSError *error;
            GTMOAuth2Authentication *auth;
            auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:Google_API_Client_ID clientSecret:Google_API_Client_Secret error:&error];
            if (!error) {
                NSLog(@"%@",auth);
                _calendarService.authorizer = auth;
            } else {
                //send alert to tell user auth failed and can't load data
                NSLog(@"Google Auth Error: %@",error);
            }
        }
    }
    return self;
}

#pragma mark Fetch Calendar List

- (void)fetchCalendarList
{
    self.calendarList = nil;
    self.calendarListFetchError = nil;
    
    GTLServiceCalendar *service = self.calendarService;
    
    //queries the user's calendar list
    //need to query a specific calendar id
    GTLQueryCalendar *query = [GTLQueryCalendar queryForCalendarListList];
    
    //fetch owned? - if this user owns the calendar?
    //set to static variable to say I do own this calendar?
    query.minAccessRole = kGTLCalendarMinAccessRoleOwner;
    
    self.calendarListTicket = [service executeQuery:query
                                  completionHandler:^(GTLServiceTicket *ticket,
                                                      id calendarList, NSError *error) {
                                      // Callback
                                      self.calendarList = calendarList;
                                      self.calendarListFetchError = error;
                                      self.calendarListTicket = nil;
                                      
                                      [self updateUI];
                                  }];
    [self updateUI];
}

-(void) updateUI
{
    
}


@end
