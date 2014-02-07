//
//  SSMasterViewController.h
//  SplitPeekViewController
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MenuState{
    MenuCompletelyOpened,
    MenuOpened,
    MenuCompletelyHidden
}MenuState;

@interface SplitViewController : UIViewController

@property (nonatomic) MenuState menuStateInView;

@property (strong, nonatomic) UINavigationController *frontViewController;
@property (strong, nonatomic) UINavigationController *backViewController;

-(void)showMenuFullScreen;
-(void)showMenuSplit;
-(void)hideMenu;
@end
