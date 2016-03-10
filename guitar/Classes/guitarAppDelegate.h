//
//  guitarAppDelegate.h
//  guitar
//
//  Created by user on 15/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOutputBus 0
#define kInputBus 1
#define SAMPLE_RATE 44100
#define MAX_CANALES	6

extern float _freq_ant[MAX_CANALES];
extern float _freq[MAX_CANALES];
extern float _volumen[MAX_CANALES];
extern int _sample_ndx[MAX_CANALES];
extern int _index;

// samples actual
extern short int *_pcm;
extern int _cant_samples;
extern float _freq_base;
// sample principal
extern short int *_pcm1;
extern int _cant_samples1;
extern float _freq_base1;
// sample secundario
extern short int *_pcm2;
extern int _cant_samples2;
extern float _freq_base2;
// sample auxiliar
extern short int *_pcm3;
extern int _cant_samples3;
extern float _freq_base3;

#define MAQ_RUIDO			0
#define MAQ_RUIDO_2			1
#define MAQ_RUIDO_3			2

#define MAQ_PIANO			10
#define MAQ_GUITAR			11


extern char _tipo_maquina;


@class guitarViewController;

@interface guitarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    guitarViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet guitarViewController *viewController;

@end

