//
//  NSDate+SwingLocal.h
//  Swing Local
//
//  Created by Stevenson on 2/7/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SwingLocal)

+(BOOL)dateA:(NSDate*)dateA isSameDayAsDateB:(NSDate*)dateB;

+(BOOL)dateA: (NSDate*)dateA isBeforeDateB:(NSDate*)dateB;

@end
