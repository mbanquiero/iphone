//
//  guitarView.h
//  guitar
//
//  Created by user on 15/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAX_DEDOS		4



@interface guitarView : UIView {
	
	float elapsed_time;
	NSTimer *timer;
	long cur_time;

	int cant_dedos;
	CGPoint pos_ini[MAX_DEDOS];
	CGPoint pos_ant[MAX_DEDOS];
	CGPoint pos_dedo[MAX_DEDOS];
	UITouch *dedo[MAX_DEDOS];
	double time_dedo[MAX_DEDOS];
	double time_ini_dedo[MAX_DEDOS];
	

	float timer_vibrando[6];
	float freq_cuerda[6];
	bool acepta_punteo[6];
	float volumen_cuerda[6];
	char traste[6]; 
	char chord[50][6];
	char *chord_name[50];
	int cant_chords;
	int chord_sel;
	char guitar_sel;
	
	int d_cuerda;
	
	int redraw;

}



-(void) actualizar;


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
