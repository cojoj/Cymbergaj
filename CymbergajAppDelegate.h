//
//  CymbergajAppDelegate.h
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CymbergajViewController.h"

@interface CymbergajAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CymbergajViewController *gameController;

-(void)playGame;

@end
