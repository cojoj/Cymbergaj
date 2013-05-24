//
//  Puck.h
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paddle.h"

@interface Puck : NSObject

{
    UIView *view;           //Widok krążka kontroluje ten obiekt
    CGRect rect[3];         //Zawiera prostokąt ograniczajacy pole gry oraz obydwu bramek
    int box;                //Prostokąt, w którym mieści się krążek
}

@property (assign, nonatomic) float maxSpeed;   //Maksymalna prędkość krążka
@property (assign, nonatomic) float speed;      //Aktualna prędkość krążka
@property (assign, nonatomic) float dx;         //Aktualny kierunek krążka
@property (assign, nonatomic) float dy;         //Aktualny kierunek krążka
@property (assign, nonatomic) int winner;       //Definicja zwycięzcy: 0=nikt, 1=gracz 1 zdobył punkt, 2=gracz 2 zdobył punkt

- (id)initWithPuck:(UIView*)puck Boundary:(CGRect)boundary Goal1:(CGRect)goal1 Goal2:(CGRect)goal2 MaxSpeed:(float)max; //Inicjalizacja krążka
- (void)reset;                                  //Wyzerowanie położenia i umieszczenie krążka w środku prostokąta ograniczającego
- (CGPoint)center;                              //Zwrot aktualnego położenia centrum krążka
- (bool)animate;                                //Animacja krążka i zwrot wartości true w przypadku uderzenia w ścianę
- (bool)handleCollision:(Paddle*)paddle;        //Sprawdzenie, czy wyśtąpiła kolizja z paletką i na tej podstawie zmiana ścieżki ruchu krążka

@end
