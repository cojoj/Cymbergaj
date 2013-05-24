//
//  Paddle.h
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Paddle : NSObject

{
    UIView *view;                           //Widok paletki z bieżącą pozycją
    CGRect boundary;                        //Prostokąc ograniczający ruch
    CGPoint pos;                            //Położenie, do którego zmierza paletka
}

@property (weak, nonatomic) UITouch *touch;            //Dotknięcie przypisane danej paletce
@property (assign, nonatomic) float speed;             //Prędkość bieżąca paletki
@property (assign, nonatomic) float maxSpeed;          //Prędkość maksymalna paletki

- (id)initWithView:(UIView *)paddle Boundary:(CGRect)rect MaxSpeed:(float)max; //Inicjalizacja obiektu
- (void)reset;                                                                 //Wyzerowanie położenia do środka prostokąta ograniczającego ruch
- (void)move:(CGPoint)pt;                                                      //Miejsce, do którego powinna zostać przesunięta paletka
- (CGPoint)center;                                                             //Punkt centralny paletki
- (BOOL)intersects:(CGRect)rect;                                               //Sprawdzenie, czy paletka przecina się z prostokątem
- (float)distance:(CGPoint)pt;                                                 //Ustalenie odległości dzialącej bieżace położenie paletki i punktu
- (void)animate;                                                               //Animacja widoku krążka do kolejnego położenia bez przekraczania prędkości maksymalnej

@end
