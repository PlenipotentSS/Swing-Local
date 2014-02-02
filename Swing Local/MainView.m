//
//  MainView.m
//  Local Swing Calendar
//
//  Created by Stevenson on 1/31/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "MainView.h"
#import "HomeView.h"
#import "UIColor+SwingLocal.h"

@interface MainView ()


@end

@implementation MainView

-(void) setup {
    self.backgroundColor = [UIColor burntScheme];
}

-(void) setCurrentView:(UIView *)currentView {
    if (_currentView) {
        [[[self views] lastObject] removeFromSuperview];
    }
    _currentView = currentView;
    [self addSubview:_currentView];
    [(HomeView*)_currentView setup];
    [_currentView becomeFirstResponder];
    _currentView.userInteractionEnabled = YES;
}

@end
