//
//  HomeView.h
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsView.h"

@interface HomeView : UIView

//array of all city keys from API
@property (nonatomic) NSArray *cityKeys;

//news view
@property (nonatomic) NewsView *newsView;

//setup view
-(void) setup;

//action to start selecting city
-(IBAction)selectCity:(id)sender;

//action to change from selected city
-(IBAction)changeCity:(id)sender;


@end
