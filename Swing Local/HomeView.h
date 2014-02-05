//
//  HomeView.h
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsView.h"
#import "UIColor+SwingLocal.h"
#import "HomePageManager.h"
#import "HollowButton.h"
#import "EventsTableView.h"
#import "EventsTableViewModel.h"

@interface HomeView : UIView

//wrapper view
@property (weak, nonatomic) IBOutlet UIView *wrapper;

//button to select a city for first run
@property (weak, nonatomic) IBOutlet UIButton *citySelectButton;

//button to change city after selected
@property (weak, nonatomic) IBOutlet HollowButton *changeCityButton;

//button to change city after selected
@property (weak, nonatomic) IBOutlet HollowButton *addCityToSavedCitiesButton;

//content Header view to display tonight's dances
@property (weak, nonatomic) IBOutlet UIView *contentHeader;

//title header of current view
@property (weak, nonatomic) IBOutlet UILabel *title;

//original origin of changeCity Button
@property (nonatomic) CGPoint changeCityOrigin;

//footer view for any separate swipe gestures
@property (weak, nonatomic) UIView *footerView;


//setup view
-(void) setup;

-(void) animateShowingContent;

@end
