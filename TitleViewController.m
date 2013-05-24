//
//  TitleViewController.m
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import "TitleViewController.h"
#import "CymbergajViewController.h"
#import "CymbergajAppDelegate.h"

@implementation TitleViewController

- (IBAction)startGameButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"startGameSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"startGameSegue"]) {
        CymbergajViewController *cymb = [segue destinationViewController];
        [cymb setSelectedDifficultyLevel:[(UIButton *)sender tag]];
        CymbergajAppDelegate *app = (CymbergajAppDelegate *)[UIApplication sharedApplication].delegate;
        [app playGame];
    }
}

@end
