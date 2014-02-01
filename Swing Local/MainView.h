//
//  MainView.h
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainView : UIView

@property (nonatomic) NSArray* views;
@property (nonatomic) UIView *currentView;

-(void) setup;

@end
