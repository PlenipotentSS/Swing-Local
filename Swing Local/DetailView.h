//
//  DetailView.h
//  Swing Local
//
//  Created by Stevenson on 2/6/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Occurrence.h"
#import <FXBlurView.h>

@interface DetailView : FXBlurView

@property (nonatomic, weak) Occurrence *thisOccurrence;

@end
