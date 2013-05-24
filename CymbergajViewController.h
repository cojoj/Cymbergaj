//
//  CymbergajViewController.h
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import "Paddle.h"
#import "Puck.h"

enum
{
    AI_START,
    AI_WAIT,
    AI_BORED,
    AI_DEFENSE,
    AI_OFFENSE,
    AI_OFFENSE2
};

@interface CymbergajViewController : UIViewController <UIActionSheetDelegate>
{
    //Obiekty Paddle i Puck
    Paddle *paddle1;
    Paddle *paddle2;
    Puck *puck;
    
    //Przechowywanie stanu, w którym obecnie znajduje się gracz-komputer
    int state;
    int maxRounds;
    
    SystemSoundID sounds[3];
    NSTimer *timer;
    UIAlertView *alert;
}

@property (nonatomic)NSUInteger selectedDifficultyLevel;
@property (assign) int computer;
@property (strong, nonatomic) IBOutlet UIView *viewPaddle1;
@property (strong, nonatomic) IBOutlet UIView *viewPaddle2;
@property (strong, nonatomic) IBOutlet UIView *viewPuck;
@property (strong, nonatomic) IBOutlet UILabel *viewScore1;
@property (strong, nonatomic) IBOutlet UILabel *viewScore2;

- (void)resume;
- (void)pause;

@end
