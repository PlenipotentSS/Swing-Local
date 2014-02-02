//
//  HomeView.h
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeView : UIView

//button to select a city for first run
@property (nonatomic) IBOutlet UIButton *citySelectButton;

//button to change city after selected
@property (nonatomic) IBOutlet UIButton *changeCityButton;

//array of all city keys from API
@property (nonatomic) NSArray *cityKeys;

//setup view
-(void) setup;

//action to start selecting city
-(IBAction)selectCity:(id)sender;

//action to change from selected city
-(IBAction)changeCity:(id)sender;


@end
