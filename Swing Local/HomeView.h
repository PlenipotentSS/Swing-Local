//
//  HomeView.h
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeView : UIView

@property (nonatomic) IBOutlet UIButton *citySelectButton;
@property (nonatomic) IBOutlet UIButton *changeCityButton;

-(void) setup;

-(IBAction)selectCity:(id)sender;

-(IBAction)changeCity:(id)sender;


@end
