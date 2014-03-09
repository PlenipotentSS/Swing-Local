//
//  LocalNotificationManager.h
//  Swing Local
//
//  Created by Stevenson on 2/10/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject

-(void) scheduleNotification;
-(void) cancelNotification;

@end
