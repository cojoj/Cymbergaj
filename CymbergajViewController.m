//
//  CymbergajViewController.m
//  Cymbergaj
//
//  Created by Mateusz Zajac on 17.04.2013.
//  Copyright (c) 2013 Mateusz Zając. All rights reserved.
//

#define MAX_SCORE 3
#define SOUND_WALL 0
#define SOUND_PADDLE 1
#define SOUND_SCORE 2
#define MAX_SPEED 15

#import "CymbergajViewController.h"
#import "CymbergajAppDelegate.h"

@implementation CymbergajViewController

#pragma mark -- Border Boxes

struct CGRect gPlayerBox[] = {
    //x, y          szerokość,  wysokość
    {40, 40,        320-80,     240-40-32},     //Prostokąt gracza 1
    {40, 240+33,    320-80,     240-40-32}      //Prostokąt gracza 2;
};

//Krążek znajduje się w poniższym prostokącie
struct CGRect gPuckBox = {
    //  x,  y,  width,  height
    28, 28, 320-56, 480-56
};

//Prostokąty pól bramkowych
struct CGRect gGoalBox[] = {
    {102, -20, 116, 49},    //Pole wygranej pierwszego gracza
    {102, 451, 116, 49}     //Pole wygranej drugiego gracza
};

#pragma mark - Touch methods implementation

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //Iteracja przez elementy dotknięcia
    for (UITouch *touch in touches) {
        //Pobranie miejsca dotknięcia palcem w widoku
        CGPoint touchPoint = [touch locationInView:self.view];
        
        //Sprawdzenie, która połowa ekranu została dotknięta, i przypisanie
        //dotknięcia do określonej paletki, jeśli nie zostało jeszcze przypisane
        if (paddle1.touch == nil && touchPoint.y < 240 && self.computer == 0) {
            touchPoint.y += 48;
            paddle1.touch = touch;
            [paddle1 move:touchPoint];
        } else if (paddle2.touch == nil) {
            touchPoint.y -= 32;
            paddle2.touch = touch;
            [paddle2 move:touchPoint];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //Iteracja przez elementy dotknięcia
    for (UITouch *touch in touches) {
        //Pobranie miejsca dotkniecia palcem widoku
        CGPoint touchPoint = [touch locationInView:self.view];
        
        //Sprawdzenie, która połowa ekranu została dotknięta, i przypisanie
        //dotknięcia do określonej paletki, jeśli nie zostało jeszcze przypisane
        if (paddle1.touch == touch) {
            touchPoint.y += 48;
            [paddle1 move:touchPoint];
        } else if (paddle2.touch == touch) {
            touchPoint.y -= 32;
            [paddle2 move:touchPoint];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Iteracja poprzez element dotknięcia
    for (UITouch *touch in touches) {
        if (paddle1.touch == touch) {
            paddle1.touch = nil;
        } else if (paddle2.touch == touch) {
            paddle2.touch = nil;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Shake method

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) {
        //NSLog(@"shake shake baby");
        UIAlertView *shakeAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Czy chcesz zakończyć grę?" delegate:self cancelButtonTitle:@"Nie" otherButtonTitles:@"Tak", nil];
        [self stop];
        [shakeAlert show];
    }
}

#pragma mark - Implemntation of public methods

- (void)pause {
    [self stop];
}

- (void)resume {
    [self displayMessage:@"Gra wstrzymana"];
}

#pragma mark - Implementation of private methods

//Animacja krążka i wykrywanie kolizji
- (void)animate {
    //Przesunięcie paletek
    [paddle1 animate];
    [paddle2 animate];
    
    if (self.computer) {
        [self computerAI];
    }
    
    //Obsługa kolizji z paletkami, kolizja powoduje zwrot wartości TRUE
    if ([puck handleCollision:paddle1] || [puck handleCollision:paddle2]) {
        //Odtworzenie dźwięku zderzenia z paletką
        [self playSound:SOUND_PADDLE];
    }
    
    //Animacja krążka, uderzenie w ścianę zwraca wartość TRUE
    if ([puck animate]) {
        [self playSound:SOUND_WALL];
    }
    
    //Sprawdzenie, czy gracz zdobył gola
    if ([self checkGoal]) {
        [self playSound:SOUND_SCORE];
    }
}

- (void)reset {
    //Wyzerowanie stanu gracza-komputera
    state = 0;
    //Wyzerowanie paletek
    [paddle1 reset];
    [paddle2 reset];
    [puck reset];
}

- (void)start {
    if (timer == nil) {
        //Utworzenie stopera animacji
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES];
    }
    
    //Wyświetlenie piłeczki
    [self.viewPuck setHidden:NO];
}

- (void)stop {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    //Ukrycie piłeczki
    [self.viewPuck setHidden:YES];
}

- (void)displayMessage:(NSString*) msg {
    //Jednocześnie może być wyświetlony jeden komunikat
    if (alert) {
        return;
    }
    
    //Wstrzymanie animacji
    [self stop];
    
    //Utwoerzenie i wyświetlenie okna komunikatu
    alert = [[UIAlertView alloc] initWithTitle:@"Wynik" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

//Metoda odpowiedzialna z wybór ilości rund oraz ewentualny powrót do menu głównego w celu ponownego wyboru trybu rozgrywki
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            maxRounds = 2;
            [self reset];
            [self start];
            break;
        case 1:
            maxRounds = 3;
            [self reset];
            [self start];
            break;
        case 2:
            maxRounds = 5;
            [self reset];
            [self start];
            break;
        case 3:
            maxRounds = 10;
            [self reset];
            [self start];
            break;
        case 4:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

- (void)newGame {
    [self reset];
    
    //Wyzerowanie punktacji
    self.viewScore1.text = [NSString stringWithFormat:@"0"];
    self.viewScore2.text = [NSString stringWithFormat:@"0"];
    
    //Wyświetlenie okienka z wyborem długości gry
    UIActionSheet *numberOfRoundsSheet = [[UIActionSheet alloc] initWithTitle:@"Do ilu chcesz zagrać?"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Powrót do menu"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"2", @"3", @"5", @"10", nil];
    [numberOfRoundsSheet showInView:self.view];
}

- (int)gameOver {
    if ([self.viewScore1.text intValue] >= maxRounds) {
        return 1;
    }
    if ([self.viewScore2.text intValue] >= maxRounds) {
        return 2;
    }
    return 0;
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Okno zostało zamknięte, więc można rozpocząc grę
    alert = nil;
    
    //Sprawdzenie, czy należy powrócić na ekran tytułowy
    if ([self gameOver]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self reset];
            [self start];
            break;
            
        case 1:
            [self stop];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

- (BOOL)checkGoal {
    //Sprawdzenie, czy piłeczka wykracza poza ekran. Jeżeli tak, zerujemy rundę
    if (puck.winner != 0) {
        //Pobranie wartości liczbowej z etykiery punktacji
        int s1 = [self.viewScore1.text intValue];
        int s2 = [self.viewScore2.text intValue];
        
        //Przydzielenie punktu odpowiedniemu graczowi
        if (puck.winner == 2) {
            ++s2;
        } else {
            ++s1;
        }
        
        //Uaktualnienie etykiery punktacji
        self.viewScore1.text = [NSString stringWithFormat:@"%u", s1];
        self.viewScore2.text = [NSString stringWithFormat:@"%u", s2];
        
        //Sprawdzenie zwycięzcy
        if ([self gameOver] == 1) {
            //Ogłoszenie zwycięzcy
            [self displayMessage:@"Wygrał gracz numer 1!"];
        } else if ([self gameOver] == 2) {
            [self displayMessage:@"Wygrał gracz numer 2!"];
        } else {
            //Wyzerowanie rundy
            [self reset];
        }
        
        //Zwrócenie wartości TRUE w przypadku zdobycia punktu
        return TRUE;
    }
    //Brak punktu
    return FALSE;
}

#pragma mark - Sound methods

//Wczytanie efektu dźwiękowego do tablicy dźwięków
- (void)loadSound:(NSString*)name Slot:(int)slot {
    if (sounds[slot] != 0) {
        return;
    }
    
    //Utworzenie scieżki dostępu do pliku dźwięku
    NSString *sndPath = [[NSBundle mainBundle] pathForResource:name ofType:@"wav" inDirectory:@"/"];
    
    //Utworzenie identyfikatora dla dźwięku znajdującego się w slocie
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:sndPath], &sounds[slot]);
}

- (void)initSounds {
    [self loadSound:@"wall" Slot:SOUND_WALL];
    [self loadSound:@"paddle" Slot:SOUND_PADDLE];
    [self loadSound:@"score" Slot:SOUND_SCORE];
}

- (void)playSound:(int)slot {
    AudioServicesPlaySystemSound(sounds[slot]);
}

#pragma mark - Computer AI

- (void)computerAI {
    if (state == AI_START) {
        if (paddle2.speed > 0 || (arc4random() % (100/self.computer)) == 1) {
            state = AI_WAIT;
        }
    } else if (state == AI_WAIT) {
        if ([paddle1 intersects:self.viewPuck.frame]) {
            //Przejście do stanu znudzenia, aby paletka została umieszczona w losowo wybranym położeniu
            state = AI_BORED;
            return;
        }
        //Zaczekaj do zatrzymania paletki
        else if (paddle1.speed == 0) {
            
            //Przywrócenie prędkości do wartości domyślnej
            paddle1.maxSpeed = MAX_SPEED;
            
            //Wybierz liczbę z zakresu 0 do 9
            int r = arc4random() % ((4 - self.computer) * 4);
            
            //Jeżeli wybrana została liczba 1, wówczas następuje przejście do nowego stanu
            if (r == 1) {
                //Jeżeli krążek znajduje się na naszej połowie i nie porusza się zbyt szybko, wówczas przejdź do stanu ataku
                //Jeżeli krążek porusza się do góry ze znaczną prędkością, przejdź do stanu obrony
                //W przeciwnym razie przejdź do stanu znudzony
                if (puck.center.y <= 240 && puck.speed < self.computer) {
                    if (self.computer == 1) {
                        state = AI_OFFENSE2;
                    } else {
                        state = AI_OFFENSE;
                    }
                }else if (puck.speed >= 1 && puck.dy < 0) {
                    state = AI_DEFENSE;
                } else {
                    state = AI_BORED;
                }
            }
        }
    } else if (state == AI_DEFENSE) {
        //Przesunięcie krążka do pozycji X i zmiejszenie odległości od bramki
        float offset = ((puck.center.x - 160) / 160.0) * 40.0;
        [paddle1 move:CGPointMake(puck.center.x - offset, (puck.center.y / 2))];
        if (puck.speed < 1 || puck.dy > 0) {
            state = AI_WAIT;
        }
        
        if (self.computer == 1) {
            paddle1.maxSpeed = MAX_SPEED / 3;
        } else if (self.computer == 2) {
            paddle1.maxSpeed = MAX_SPEED * 2/5;
        } else if (self.computer == 3) {
            paddle1.maxSpeed = MAX_SPEED / 2;
        }
    } else if (state == AI_OFFENSE) {
        if (self.computer < 3) {
            paddle1.maxSpeed = MAX_SPEED / 2;
        }
        //Wybór nowego położenia X w odległości od -64 do +64 od centrum krążka
        float x = puck.center.x - 64 + (arc4random() % 129);
        float y = puck.center.y - 64 - (arc4random() % 64);
        [paddle1 move:CGPointMake(x, y)];
        state = AI_OFFENSE2;
    } else if (state == AI_OFFENSE2) {
        if (self.computer == 1) {
            paddle1.maxSpeed = MAX_SPEED / 2;
        } else if (self.computer == 2) {
            paddle1.maxSpeed = MAX_SPEED * 3/4;
        }
        
        //Uderzenie krążka
        [paddle1 move:puck.center];
        state = AI_WAIT;
    } else if (state == AI_BORED) {
        //Komputer jest znudzony i przesuwa paletkę do losowo wybranego położenia
        if (paddle1.speed == 0) {
            
            //Zmiana prędkości paletki na podstawie poziomu trudności
            [paddle1 setSpeed:3 + self.computer];
            
            //Zmiana wielkości obszaru: (20) na poziomie średnim i (40) na trudnym
            int inset = (self.computer - 1) * 20;
            
            //Przesunięcie paleltki paddle1 do losowo wybranego położenia na połowie gracza 1
            float x = (gPlayerBox[0].origin.x + inset)+ arc4random() % (int)(gPlayerBox[0].size.width - inset*2);
            float y = gPlayerBox[0].origin.y + arc4random() % (int)(gPlayerBox[0].size.height - inset);
            [paddle1 move:CGPointMake(x, y)];
            state = AI_WAIT;
        }
    }
}


#pragma mark - View lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSounds];
    paddle1 = [[Paddle alloc] initWithView:self.viewPaddle1 Boundary:gPlayerBox[0] MaxSpeed:MAX_SPEED];
    paddle2 = [[Paddle alloc] initWithView:self.viewPaddle2 Boundary:gPlayerBox[1] MaxSpeed:MAX_SPEED];
    puck = [[Puck alloc] initWithPuck:self.viewPuck Boundary:gPuckBox Goal1:gGoalBox[0] Goal2:gGoalBox[1] MaxSpeed:MAX_SPEED];
    [self newGame];
        
    [self setComputer:self.selectedDifficultyLevel];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
