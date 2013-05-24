//
//  Puck.m
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import "Puck.h"

@implementation Puck

- (id)initWithPuck:(UIView *)puck Boundary:(CGRect)boundary Goal1:(CGRect)goal1 Goal2:(CGRect)goal2 MaxSpeed:(float)max {
    self = [super init];
    
    if (self) {
        //Inicjalizacja prostokątów ograniczających
        view = puck;
        rect[0] = boundary;
        rect[1] = goal1;
        rect[2] = goal2;
        [self setMaxSpeed:max];
    }
    
    return self;
}

//Wyzerowanie położenia początkowego
- (void)reset {
    //Wybór losowego położenia, w którym znajdzie się krążek
    float x = rect[1].origin.x + arc4random() % ((int) rect[1].size.width);
    float y = rect[0].origin.x + rect[0].size.height / 2;
    view.center = CGPointMake(x, y);
    
    box = 0;
    [self setSpeed:0];
    [self setDx:0];
    [self setDy:0];
    [self setWinner:0];
}

- (CGPoint)center {
    return view.center;
}

- (bool)animate {
    //Jeżeli mamy zwycięzcę, animacja jest niepotrzebna
    if (self.winner != 0) {
        return false;
    }
    
    bool hit = false;
    
    //Spowolnienie prędkości krążka
    if (self.speed > 0) {
        [self setSpeed:(self.speed * 0.99)];
        if (self.speed < 0.1) {
            [self setSpeed:0.1];
        }
    }
    
    //Przesunięcie krążka do nowego położenia na podstawie bieżącego kierunku i prędkości
    CGPoint pos = CGPointMake(view.center.x + self.dx * self.speed, view.center.y + self.dy * self.speed);
    
    //Sprawdzenie, czy krążek znajduje się w polu bramkowym
    if (box == 0 && CGRectContainsPoint(rect[1], pos)) {
        //Krążek znajduje się w polu bramkowym gracza 1
        box = 1;
    } else if (box == 0 && CGRectContainsPoint(rect[2], pos)) {
        //Krążek znajduje się w polu bramkowym gracza 2
        box = 2;
    } else if (CGRectContainsPoint(rect[box], pos) == false) {
        //Obsługa zderzeń ze ścianami w bieżącym prostokącie ograniczającym
        if (view.center.x < rect[box].origin.x) {
            pos.x = rect[box].origin.x;
            [self setDx:fabs(self.dx)];
            hit = true;
        } else if (pos.x > rect[box].origin.x + rect[box].size.width) {
            pos.x = rect[box].origin.x + rect[box].size.width;
            [self setDx:-fabs(self.dx)];
            hit = true;
        }
        
        if (pos.y < rect[box].origin.y) {
            pos.y = rect[box].origin.y;
            [self setDy:fabs(self.dy)];
            hit = true;
            //Sprawdzenie wygranej
            if (box == 1) {
                [self setWinner:2];
            }
        } else if (pos.y > rect[box].origin.y + rect[box].size.height) {
            pos.y = rect[box].origin.y + rect[box].size.height;
            [self setDy:-fabs(self.dy)];
            hit = true;
            //Sprawdzenie wygranej
            if (box == 2) {
                [self setWinner:1];
            }
        }
    }
    view.center = pos;
    return hit;
}

//Sprawdzenie, czy wystąpiła kolizja z paletką
- (bool)handleCollision:(Paddle *)paddle {
    //Maksymalna odległość między krażkiem i paletką
    static float maxDistance = 52;
    
    //Pobranie bieżącej odległości od punktu centralnego prostokąta
    float currentDistance = [paddle distance:view.center];
    
    //Sprawdzenie, czy doszło do kontaktu obiektów
    if (currentDistance <= maxDistance) {
        //Zmiana kierunku ruchu krążka
        [self setDx:((view.center.x - paddle.center.x) / 32.0)];
        [self setDy:((view.center.y - paddle.center.y) / 32.0)];
        
        //Dostosowanie prędkości krążka w celu odzwierciedlenia prędkości bieżącej i prędkości paletki
        [self setSpeed:(0.2 + self.speed / 2.0 + paddle.speed)];
        
        //Ograniczenie prędkości maksymalnej
        if (self.speed > self.maxSpeed) {
            [self setSpeed:self.maxSpeed];
        }
        
        //Umieszczenie krążka w odległości wiekszej niż promień paletki, aby zderzenie nie zostało wykryte po raz kolejny
        float r = atan2(self.dy, self.dx);
        float x = paddle.center.x + cos(r) * (maxDistance+1);
        float y = paddle.center.y + sin(r) * (maxDistance+1);
        view.center = CGPointMake(x,y);
        return true;
    }
    return false;
}

@end
