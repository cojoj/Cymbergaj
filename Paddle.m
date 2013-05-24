//
//  Paddle.m
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#import "Paddle.h"

#define NO_MOVE 0

@implementation Paddle

- (id)initWithView:(UIView *)paddle Boundary:(CGRect)rect MaxSpeed:(float)max {
    self = [super init];
    if (self) {
        //Własna inicjalizacja
        view = paddle;
        boundary = rect;
        _maxSpeed = max;
    }
    return self;
}


- (void)reset {
    pos.x = boundary.origin.x + boundary.size.width / 2;
    pos.y = boundary.origin.y + boundary.size.height / 2;
    view.center = pos;
}

- (void)move:(CGPoint)pt {
    //Dostosowanie pozycji X, aby paletka pozostała w zdefiniowanym prostokącie
    if (pt.x < boundary.origin.x) {
        pt.x = boundary.origin.x;
    } else if (pt.x > boundary.origin.x + boundary.size.width) {
        pt.x = boundary.origin.x + boundary.size.width;
    }
    
    //Dostosowanie pozycji Y, aby paletka pozostała w zdefiniowanym prostokącie
    if (pt.y < boundary.origin.y) {
        pt.y = boundary.origin.y;
    } else if (pt.y > boundary.origin.y + boundary.size.height) {
        pt.y = boundary.origin.y + boundary.size.height;
    }
    
    //Uaktualnienie położenia
    pos = pt;
}

- (CGPoint)center {
    return view.center;
}

- (BOOL)intersects:(CGRect)rect {
    return CGRectIntersectsRect(view.frame, rect);
}

- (float)distance:(CGPoint)pt {
    float diffx = (view.center.x) - (pt.x);
    float diffy = (view.center.y) - (pt.y);
    return sqrt(diffx*diffx + diffy*diffy);
}

- (void)animate {
    //Sprawdzenie, czy konieczne jest przesunięcie krążka
    if (CGPointEqualToPoint(view.center, pos) == false) {
        //Obliczenie odległości, o jaką trzeba przesunąć krążek
        float d = [self distance:pos];
        
        //Sprawdzenie maksymalnej odległości, jaką moze pokonać paletka
        if (d > self.maxSpeed) {
            //Zmodyfikowanie położenia na maksymalną dozwoloną
            float r = atan2(pos.y - view.center.y, pos.x - view.center.x);
            float x = view.center.x + cos(r) * [self maxSpeed];
            float y = view.center.y + sin(r) * [self maxSpeed];
            view.center = CGPointMake(x, y);
            [self setSpeed:[self maxSpeed]];
        } else {
            //Ustawienie położenia paletki, ponieważ nie przekracza prędkości maksymalnej
            view.center = pos;
            [self setSpeed:d];
        }
    } else {
        //Brak ruchu
        [self setSpeed:NO_MOVE];
    }
}

@end
