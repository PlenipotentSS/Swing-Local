//
//  GoogleCalendarManager.h
//  Swing Local
//
//  Created by Stevenson on 2/5/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTLCalendar.h>

@interface GoogleCalendarManager : NSObject

@property (readonly) GTLServiceCalendar *calendarService;

+(GoogleCalendarManager*) sharedManager;

@end
